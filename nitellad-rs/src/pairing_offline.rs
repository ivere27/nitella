use crate::cert_utils;
use anyhow::Result;
use base64::{engine::general_purpose, Engine as _};
use hyper::header::{CONTENT_TYPE, COOKIE, LOCATION, SET_COOKIE};
use hyper::server::conn::Http;
use hyper::service::service_fn;
use hyper::{Body, Request, Response, StatusCode};
use qrcodegen::{QrCode, QrCodeEcc};
use rand::Rng;
use rustls::pki_types::{CertificateDer, PrivateKeyDer, PrivatePkcs8KeyDer};
use sha2::{Digest, Sha256};
use std::collections::HashSet;
use std::convert::Infallible;
use std::net::SocketAddr;
use std::path::Path;
use std::sync::{Arc, Mutex};
use std::time::Duration;
use tokio::fs;
use tokio::net::TcpListener;
use tokio::sync::oneshot;
use tokio_rustls::TlsAcceptor;

pub const DEFAULT_PAIRING_TIMEOUT: Duration = Duration::from_secs(3 * 60);

pub struct OfflinePairing {
    data_dir: String,
    node_name: String,
}

impl OfflinePairing {
    pub fn new(data_dir: String, node_name: String) -> Self {
        Self {
            data_dir,
            node_name,
        }
    }

    pub async fn run(&self, port: Option<u16>, timeout: Duration) -> Result<()> {
        fs::create_dir_all(&self.data_dir).await?;

        // 1. Load or generate identity. Go reuses node.key when present.
        println!("Generating Identity...");
        let (_key_pem, key_pair) =
            cert_utils::load_or_generate_node_key(Path::new(&self.data_dir)).await?;
        let csr_pem = cert_utils::generate_csr(key_pair, &self.node_name)?;

        // 2. Generate QR Code Payload. Field names match Go's pairing.QRPayload.
        let fingerprint = derive_fingerprint(csr_pem.as_bytes());
        let payload = serde_json::json!({
            "t": "csr",
            "csr": general_purpose::STANDARD.encode(csr_pem.as_bytes()),
            "fp": fingerprint,
            "nid": self.node_name
        });
        let payload_str = serde_json::to_string(&payload)?;

        if let Some(p) = port {
            self.run_web(p, &payload_str, &csr_pem, timeout).await
        } else {
            self.run_terminal(&payload_str).await
        }
    }

    async fn run_terminal(&self, payload_str: &str) -> Result<()> {
        self.print_qr(payload_str);
        println!(
            "
Or copy this JSON:
{}",
            payload_str
        );

        println!("\nPaste the response JSON below:");

        let mut input = String::new();
        std::io::stdin().read_line(&mut input)?;

        // Process received cert
        self.save_cert(&input).await?;
        Ok(())
    }

    async fn run_web(
        &self,
        port: u16,
        payload_str: &str,
        csr_pem: &str,
        timeout: Duration,
    ) -> Result<()> {
        self.print_qr(payload_str);
        let cpace_words = generate_pairing_code();
        println!(
            "
Or copy this JSON:
{}",
            payload_str
        );
        println!("\nCPACE Words: {}", cpace_words);

        // 3. Start Web Server
        let addr = SocketAddr::from(([0, 0, 0, 0], port));
        println!(
            "
Starting Pairing Web UI at http://{}",
            addr
        );

        let (tx, rx) = oneshot::channel::<String>(); // Channel to receive cert from web handler
        let state = Arc::new(PairingWebState {
            tx: Arc::new(Mutex::new(Some(tx))),
            csr: csr_pem.to_string(),
            payload: payload_str.to_string(),
            cpace_words,
            sessions: Arc::new(Mutex::new(HashSet::new())),
        });

        let listener = TcpListener::bind(addr).await?;
        let acceptor = create_pairing_tls_acceptor()?;
        let server = async move {
            loop {
                let (stream, _) = listener.accept().await?;
                let acceptor = acceptor.clone();
                let state = state.clone();
                tokio::spawn(async move {
                    let Ok(tls_stream) = acceptor.accept(stream).await else {
                        return;
                    };
                    let service = service_fn(move |req| {
                        let state = state.clone();
                        async move { handle_request(req, state).await }
                    });
                    let _ = Http::new().serve_connection(tls_stream, service).await;
                });
            }
            #[allow(unreachable_code)]
            Ok::<(), anyhow::Error>(())
        };

        let timeout = if timeout.is_zero() {
            DEFAULT_PAIRING_TIMEOUT
        } else {
            timeout
        };

        // Race server, completion channel, and timeout.
        tokio::select! {
            result = server => {
                result?;
            },
            Ok(cert_json) = rx => {
                // Process received cert
                self.save_cert(&cert_json).await?;
            },
            _ = tokio::time::sleep(timeout) => {
                anyhow::bail!("pairing timeout after {:?}", timeout);
            }
        }

        Ok(())
    }

    fn print_qr(&self, data: &str) {
        let qr = QrCode::encode_text(data, QrCodeEcc::Low).unwrap();
        // Print ASCII
        for y in 0..qr.size() {
            for x in 0..qr.size() {
                if qr.get_module(x, y) {
                    print!("##");
                } else {
                    print!("  ");
                }
            }
            println!("");
        }
    }

    async fn save_cert(&self, json_str: &str) -> Result<()> {
        let json_str = normalize_submitted_payload(json_str);
        let data: serde_json::Value = serde_json::from_str(&json_str)?;
        let payload_type = data
            .get("t")
            .or_else(|| data.get("type"))
            .and_then(|v| v.as_str())
            .unwrap_or("");
        if payload_type != "cert" {
            anyhow::bail!("expected certificate response, got '{}'", payload_type);
        }

        let mut saved_cert = false;
        if let Some(cert) = data.get("cert").and_then(|v| v.as_str()) {
            let cert = decode_pem_field(cert)?;
            cert_utils::write_cert_pem(&Path::new(&self.data_dir).join("node.crt"), &cert, 0o600)
                .await?;
            saved_cert = true;
        }
        if let Some(ca) = data
            .get("ca")
            .or_else(|| data.get("ca_cert"))
            .and_then(|v| v.as_str())
        {
            let ca = decode_pem_field(ca)?;
            cert_utils::write_cert_pem(&Path::new(&self.data_dir).join("cli_ca.crt"), &ca, 0o644)
                .await?;
        }
        if saved_cert {
            println!("Certificate saved!");
        }
        Ok(())
    }
}

struct PairingWebState {
    tx: Arc<Mutex<Option<oneshot::Sender<String>>>>,
    csr: String,
    cpace_words: String,
    payload: String,
    sessions: Arc<Mutex<HashSet<String>>>,
}

async fn handle_request(
    req: Request<Body>,
    state: Arc<PairingWebState>,
) -> Result<Response<Body>, Infallible> {
    if req.method() == hyper::Method::POST && req.uri().path() == "/verify" {
        let full_body = hyper::body::to_bytes(req.into_body())
            .await
            .unwrap_or_default();
        let body_str = String::from_utf8_lossy(&full_body);
        let words = extract_form_field(&body_str, "cpace_words");
        if !words.eq_ignore_ascii_case(state.cpace_words.trim()) {
            return Ok(json_response(
                StatusCode::OK,
                r#"{"success":false,"error":"Invalid CPACE words"}"#,
            ));
        }
        let token = uuid::Uuid::new_v4().to_string();
        if let Ok(mut sessions) = state.sessions.lock() {
            sessions.insert(token.clone());
        }
        let mut resp = json_response(StatusCode::OK, r#"{"success":true,"redirect":"/pairing"}"#);
        resp.headers_mut().insert(
            SET_COOKIE,
            format!("pairing_session={token}; Path=/; HttpOnly; Secure; SameSite=Strict")
                .parse()
                .unwrap(),
        );
        return Ok(resp);
    }

    if req.method() == hyper::Method::POST && req.uri().path() == "/submit" {
        if !validate_session(&req, &state.sessions) {
            return Ok(text_response(StatusCode::UNAUTHORIZED, "Unauthorized"));
        }
        let full_body = hyper::body::to_bytes(req.into_body()).await.unwrap();
        let body_str = String::from_utf8(full_body.to_vec()).unwrap();

        if let Ok(mut lock) = state.tx.lock() {
            if let Some(sender) = lock.take() {
                let _ = sender.send(body_str);
            }
        }
        return Ok(Response::new(Body::from(
            "Pairing Complete. You can close this window.",
        )));
    }

    if req.method() == hyper::Method::GET && req.uri().path() == "/pairing" {
        if !validate_session(&req, &state.sessions) {
            let mut resp = Response::new(Body::empty());
            *resp.status_mut() = StatusCode::FOUND;
            resp.headers_mut()
                .insert(LOCATION, "/".parse().expect("valid redirect"));
            return Ok(resp);
        }
        return Ok(pairing_page(&state));
    }

    if req.method() == hyper::Method::GET && req.uri().path() == "/qr.png" {
        return Ok(text_response(StatusCode::OK, &state.payload));
    }

    Ok(index_page())
}

fn index_page() -> Response<Body> {
    let html = r#"
    <!doctype html>
    <html><head><meta charset="utf-8"><title>Nitella Node Pairing</title></head>
    <body style="font-family:system-ui,sans-serif;max-width:720px;margin:40px auto;line-height:1.4">
      <h1>Node Pairing</h1>
      <p>Enter the CPACE words from the nitellad terminal.</p>
      <form action="/verify" method="post">
        <input type="text" name="cpace_words" style="width:100%;font-size:18px;padding:8px">
        <button type="submit">Continue</button>
      </form>
    </body></html>
    "#;
    html_response(html)
}

fn pairing_page(state: &PairingWebState) -> Response<Body> {
    let html = format!(
        r#"
    <!doctype html>
    <html><head><meta charset="utf-8"><title>Nitella Node Pairing</title></head>
    <body style="font-family:system-ui,sans-serif;max-width:860px;margin:40px auto;line-height:1.4">
      <h1>Node Pairing</h1>
      <p><strong>CPACE Words:</strong> <code>{}</code></p>
      <p><strong>CSR Fingerprint:</strong> <code>{}</code></p>
      <h2>QR Payload</h2>
      <pre style="white-space:pre-wrap;border:1px solid #ccc;padding:12px">{}</pre>
      <h2>CSR PEM</h2>
      <pre style="white-space:pre-wrap;border:1px solid #ccc;padding:12px">{}</pre>
      <form action="/submit" method="post">
        <textarea name="response" placeholder="Paste response JSON here" style="width:100%;height:180px"></textarea>
        <button type="submit">Submit</button>
      </form>
    </body></html>
    "#,
        state.cpace_words,
        derive_fingerprint(state.csr.as_bytes()),
        state.payload,
        state.csr
    );
    html_response(&html)
}

fn html_response(html: &str) -> Response<Body> {
    let mut resp = Response::new(Body::from(html.to_string()));
    resp.headers_mut()
        .insert(CONTENT_TYPE, "text/html; charset=utf-8".parse().unwrap());
    resp
}

fn text_response(status: StatusCode, body: &str) -> Response<Body> {
    let mut resp = Response::new(Body::from(body.to_string()));
    *resp.status_mut() = status;
    resp
}

fn json_response(status: StatusCode, body: &str) -> Response<Body> {
    let mut resp = text_response(status, body);
    resp.headers_mut()
        .insert(CONTENT_TYPE, "application/json".parse().unwrap());
    resp
}

fn validate_session(req: &Request<Body>, sessions: &Arc<Mutex<HashSet<String>>>) -> bool {
    let Some(cookie) = req.headers().get(COOKIE).and_then(|v| v.to_str().ok()) else {
        return false;
    };
    let token = cookie.split(';').find_map(|part| {
        let part = part.trim();
        part.strip_prefix("pairing_session=")
    });
    let Some(token) = token else {
        return false;
    };
    sessions
        .lock()
        .map(|sessions| sessions.contains(token))
        .unwrap_or(false)
}

fn create_pairing_tls_acceptor() -> Result<TlsAcceptor> {
    let cert = rcgen::generate_simple_self_signed(vec!["localhost".to_string()])?;
    let cert_der = CertificateDer::from(cert.serialize_der()?);
    let key_der = PrivateKeyDer::Pkcs8(PrivatePkcs8KeyDer::from(cert.serialize_private_key_der()));
    let config = rustls::ServerConfig::builder()
        .with_no_client_auth()
        .with_single_cert(vec![cert_der], key_der)?;
    Ok(TlsAcceptor::from(Arc::new(config)))
}

fn derive_fingerprint(data: &[u8]) -> String {
    let hash = Sha256::digest(data);
    const EMOJIS: &[&str] = &[
        "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵",
        "🐔", "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🐛", "🦋",
        "🐌", "🐞", "🌸", "🌺", "🌻", "🌹", "🌷", "🌼", "🌿", "🍀", "🍎", "🍊", "🍋", "🍇", "🍓",
        "🍒", "🍑", "🥝", "🌙", "⭐", "🌟", "✨", "⚡", "🔥", "🌈", "☀️", "🎸", "🎹", "🎺", "🎷",
        "🥁", "🎻", "🎤", "🎧",
    ];
    let mut result = String::new();
    for i in 0..4 {
        result.push_str(EMOJIS[(hash[i * 2] as usize) % EMOJIS.len()]);
    }
    result
}

fn decode_pem_field(value: &str) -> Result<Vec<u8>> {
    if value.contains("BEGIN ") {
        return Ok(value.as_bytes().to_vec());
    }
    Ok(general_purpose::STANDARD.decode(value.trim())?)
}

fn normalize_submitted_payload(input: &str) -> String {
    let trimmed = input.trim();
    if let Some(encoded) = trimmed.strip_prefix("response=") {
        return form_url_decode(encoded);
    }
    trimmed.to_string()
}

fn extract_form_field(body: &str, name: &str) -> String {
    for part in body.split('&') {
        let Some((key, value)) = part.split_once('=') else {
            continue;
        };
        if key == name {
            return form_url_decode(value).trim().to_string();
        }
    }
    String::new()
}

fn form_url_decode(value: &str) -> String {
    let mut out = Vec::with_capacity(value.len());
    let bytes = value.as_bytes();
    let mut i = 0;
    while i < bytes.len() {
        match bytes[i] {
            b'+' => {
                out.push(b' ');
                i += 1;
            }
            b'%' if i + 2 < bytes.len() => {
                let hex = &value[i + 1..i + 3];
                if let Ok(v) = u8::from_str_radix(hex, 16) {
                    out.push(v);
                    i += 3;
                } else {
                    out.push(bytes[i]);
                    i += 1;
                }
            }
            b => {
                out.push(b);
                i += 1;
            }
        }
    }
    String::from_utf8_lossy(&out).to_string()
}

fn generate_pairing_code() -> String {
    const WORDS: &[&str] = &[
        "apple", "bridge", "castle", "delta", "ember", "forest", "garden", "harbor", "island",
        "jungle", "kitten", "lemon", "magnet", "nebula", "orange", "planet", "quartz", "river",
        "silver", "tiger", "velvet", "window", "yellow", "zebra",
    ];
    let mut rng = rand::thread_rng();
    format!(
        "{}-{}-{}",
        rng.gen_range(0..10),
        WORDS[rng.gen_range(0..WORDS.len())],
        WORDS[rng.gen_range(0..WORDS.len())]
    )
}
