use std::io::{self, Read, Write};
use std::net::{Shutdown, SocketAddr, TcpListener, TcpStream};
use std::sync::Arc;
use std::thread;
use std::time::Duration;

const BODY: &[u8] = b"Hello from backend";
const MAX_HEADER_BYTES: usize = 64 * 1024;
const RESPONSE_CHUNK_BYTES: usize = 64 * 1024;
const MAX_BULK_RESPONSE_BYTES: usize = 1024 * 1024 * 1024;
const MAX_STREAM_CHUNKS: usize = 16 * 1024;
const MAX_STREAM_CHUNK_BYTES: usize = 1024 * 1024;
const MAX_STREAM_DELAY_MS: u64 = 10_000;

fn parse_port() -> u16 {
    let mut args = std::env::args().skip(1);
    let mut port = 9090_u16;

    while let Some(arg) = args.next() {
        match arg.as_str() {
            "-port" | "--port" => {
                let Some(value) = args.next() else {
                    eprintln!("missing value for {arg}");
                    std::process::exit(2);
                };
                port = value.parse().unwrap_or_else(|_| {
                    eprintln!("invalid port: {value}");
                    std::process::exit(2);
                });
            }
            "-h" | "--help" => {
                println!("Usage: bench_backend [-port PORT]");
                std::process::exit(0);
            }
            other => {
                eprintln!("unknown argument: {other}");
                std::process::exit(2);
            }
        }
    }

    port
}

fn static_response() -> Arc<Vec<u8>> {
    let mut response = format!(
        "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: {}\r\nConnection: keep-alive\r\n\r\n",
        BODY.len()
    )
    .into_bytes();
    response.extend_from_slice(BODY);
    Arc::new(response)
}

fn find_header_end(buf: &[u8]) -> Option<usize> {
    buf.windows(4).position(|window| window == b"\r\n\r\n")
}

fn request_wants_close(headers: &[u8]) -> bool {
    headers
        .windows("connection: close".len())
        .any(|window| window.eq_ignore_ascii_case(b"connection: close"))
}

fn request_path(headers: &[u8]) -> &str {
    let Some(line_end) = headers.iter().position(|b| *b == b'\r' || *b == b'\n') else {
        return "/";
    };
    let line = &headers[..line_end];
    let mut parts = line.split(|b| *b == b' ');
    let _method = parts.next();
    let Some(path) = parts.next() else {
        return "/";
    };
    std::str::from_utf8(path).unwrap_or("/")
}

fn parse_limited_usize(value: Option<&str>, default: usize, max: usize) -> usize {
    value
        .and_then(|s| s.parse::<usize>().ok())
        .filter(|n| *n > 0)
        .map(|n| n.min(max))
        .unwrap_or(default)
}

fn parse_limited_u64(value: Option<&str>, default: u64, max: u64) -> u64 {
    value
        .and_then(|s| s.parse::<u64>().ok())
        .map(|n| n.min(max))
        .unwrap_or(default)
}

fn write_fixed_bytes(stream: &mut TcpStream, size: usize) -> io::Result<()> {
    let size = size.min(MAX_BULK_RESPONSE_BYTES);
    let header = format!(
        "HTTP/1.1 200 OK\r\nContent-Type: application/octet-stream\r\nContent-Length: {size}\r\nConnection: keep-alive\r\n\r\n"
    );
    stream.write_all(header.as_bytes())?;

    let chunk = vec![b'x'; RESPONSE_CHUNK_BYTES.min(size.max(1))];
    let mut remaining = size;
    while remaining > 0 {
        let n = remaining.min(chunk.len());
        stream.write_all(&chunk[..n])?;
        remaining -= n;
    }
    Ok(())
}

fn write_chunked_stream(
    stream: &mut TcpStream,
    chunks: usize,
    chunk_size: usize,
    delay_ms: u64,
) -> io::Result<()> {
    let chunks = chunks.min(MAX_STREAM_CHUNKS);
    let chunk_size = chunk_size.min(MAX_STREAM_CHUNK_BYTES);
    let delay_ms = delay_ms.min(MAX_STREAM_DELAY_MS);
    let chunk = vec![b's'; chunk_size];

    stream.write_all(
        b"HTTP/1.1 200 OK\r\nContent-Type: application/octet-stream\r\nTransfer-Encoding: chunked\r\nConnection: keep-alive\r\n\r\n",
    )?;

    for _ in 0..chunks {
        write!(stream, "{chunk_size:x}\r\n")?;
        stream.write_all(&chunk)?;
        stream.write_all(b"\r\n")?;
        if delay_ms > 0 {
            thread::sleep(Duration::from_millis(delay_ms));
        }
    }

    stream.write_all(b"0\r\n\r\n")
}

fn write_response_for_path(stream: &mut TcpStream, response: &[u8], path: &str) -> io::Result<()> {
    if let Some(size) = path.strip_prefix("/bytes/") {
        let size = parse_limited_usize(Some(size), BODY.len(), MAX_BULK_RESPONSE_BYTES);
        return write_fixed_bytes(stream, size);
    }

    if let Some(spec) = path.strip_prefix("/stream/") {
        let mut parts = spec.split('/');
        let chunks = parse_limited_usize(parts.next(), 128, MAX_STREAM_CHUNKS);
        let chunk_size = parse_limited_usize(parts.next(), 8 * 1024, MAX_STREAM_CHUNK_BYTES);
        let delay_ms = parse_limited_u64(parts.next(), 0, MAX_STREAM_DELAY_MS);
        return write_chunked_stream(stream, chunks, chunk_size, delay_ms);
    }

    stream.write_all(response)
}

fn handle_connection(mut stream: TcpStream, response: Arc<Vec<u8>>) -> io::Result<()> {
    let _ = stream.set_nodelay(true);

    let mut read_buf = [0_u8; 8192];
    let mut pending = Vec::with_capacity(8192);

    loop {
        let n = match stream.read(&mut read_buf) {
            Ok(0) => return Ok(()),
            Ok(n) => n,
            Err(e) if e.kind() == io::ErrorKind::Interrupted => continue,
            Err(e) => return Err(e),
        };

        pending.extend_from_slice(&read_buf[..n]);
        if pending.len() > MAX_HEADER_BYTES {
            return Ok(());
        }

        while let Some(header_end) = find_header_end(&pending) {
            let request_len = header_end + 4;
            let close_after_response = request_wants_close(&pending[..header_end]);
            let path = request_path(&pending[..header_end]).to_owned();
            pending.drain(..request_len);
            write_response_for_path(&mut stream, &response, &path)?;

            if close_after_response {
                let _ = stream.shutdown(Shutdown::Both);
                return Ok(());
            }
        }
    }
}

fn main() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let addr = SocketAddr::from(([0, 0, 0, 0], parse_port()));
    let listener = TcpListener::bind(addr)?;
    let response = static_response();

    eprintln!("Static TCP backend listening on {addr}");
    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                let response = response.clone();
                thread::spawn(move || {
                    if let Err(e) = handle_connection(stream, response) {
                        if e.kind() != io::ErrorKind::ConnectionReset
                            && e.kind() != io::ErrorKind::BrokenPipe
                        {
                            eprintln!("backend connection error: {e}");
                        }
                    }
                });
            }
            Err(e) => eprintln!("backend accept error: {e}"),
        }
    }

    Ok(())
}
