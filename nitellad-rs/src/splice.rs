#![cfg(target_os = "linux")]

use std::collections::HashMap;
use std::io;
use std::net::{Shutdown, TcpStream};
use std::os::fd::{AsRawFd, RawFd};
use std::sync::atomic::{AtomicU64, AtomicUsize, Ordering};
use std::sync::{mpsc, Arc, Mutex};
use std::thread;

use crate::stats::{ActiveConnEntry, StatsService};
use tokio::sync::oneshot;
use tracing::error;

const SPLICE_FLAGS: libc::c_uint = libc::SPLICE_F_MOVE | libc::SPLICE_F_NONBLOCK;
const MAX_SPLICE: usize = 1 << 20;
const EVENT_TOKEN: u64 = u64::MAX;
const EPOLL_CLOSE_EVENTS: u32 = (libc::EPOLLERR | libc::EPOLLHUP | libc::EPOLLRDHUP) as u32;
const EPOLL_SOCKET_EVENTS: u32 =
    (libc::EPOLLIN | libc::EPOLLOUT | libc::EPOLLET) as u32 | EPOLL_CLOSE_EVENTS;
const EPOLL_EVENT_EVENTS: u32 = libc::EPOLLIN as u32;
const EPOLL_BATCH: usize = 1024;

static GLOBAL_REACTOR: Mutex<Option<Arc<SpliceReactor>>> = Mutex::new(None);

struct Pipe {
    read_fd: RawFd,
    write_fd: RawFd,
}

impl Pipe {
    fn new() -> io::Result<Self> {
        let mut fds = [0; 2];
        let rc = unsafe { libc::pipe2(fds.as_mut_ptr(), libc::O_CLOEXEC | libc::O_NONBLOCK) };
        if rc != 0 {
            return Err(io::Error::last_os_error());
        }
        Ok(Self {
            read_fd: fds[0],
            write_fd: fds[1],
        })
    }
}

impl Drop for Pipe {
    fn drop(&mut self) {
        unsafe {
            libc::close(self.read_fd);
            libc::close(self.write_fd);
        }
    }
}

struct EventFd {
    fd: RawFd,
}

impl EventFd {
    fn new() -> io::Result<Self> {
        let fd = unsafe { libc::eventfd(0, libc::EFD_CLOEXEC | libc::EFD_NONBLOCK) };
        if fd < 0 {
            return Err(io::Error::last_os_error());
        }
        Ok(Self { fd })
    }

    fn fd(&self) -> RawFd {
        self.fd
    }

    fn wake(&self) -> io::Result<()> {
        let value = 1_u64;
        loop {
            let rc = unsafe {
                libc::write(
                    self.fd,
                    &value as *const u64 as *const libc::c_void,
                    std::mem::size_of::<u64>(),
                )
            };
            if rc == std::mem::size_of::<u64>() as libc::ssize_t {
                return Ok(());
            }
            if rc >= 0 {
                return Err(io::Error::new(
                    io::ErrorKind::WriteZero,
                    "short eventfd write",
                ));
            }

            let err = io::Error::last_os_error();
            if is_interrupted(&err) {
                continue;
            }
            if is_wait_again(&err) {
                return Ok(());
            }
            return Err(err);
        }
    }

    fn drain(&self) -> io::Result<()> {
        let mut value = 0_u64;
        loop {
            let rc = unsafe {
                libc::read(
                    self.fd,
                    &mut value as *mut u64 as *mut libc::c_void,
                    std::mem::size_of::<u64>(),
                )
            };
            if rc == std::mem::size_of::<u64>() as libc::ssize_t {
                continue;
            }
            if rc == 0 {
                return Ok(());
            }
            if rc > 0 {
                return Err(io::Error::new(
                    io::ErrorKind::UnexpectedEof,
                    "short eventfd read",
                ));
            }

            let err = io::Error::last_os_error();
            if is_interrupted(&err) {
                continue;
            }
            if is_wait_again(&err) {
                return Ok(());
            }
            return Err(err);
        }
    }
}

impl Drop for EventFd {
    fn drop(&mut self) {
        unsafe {
            libc::close(self.fd);
        }
    }
}

struct Epoll {
    fd: RawFd,
}

impl Epoll {
    fn new() -> io::Result<Self> {
        let fd = unsafe { libc::epoll_create1(libc::EPOLL_CLOEXEC) };
        if fd < 0 {
            return Err(io::Error::last_os_error());
        }
        Ok(Self { fd })
    }

    fn add(&self, fd: RawFd, token: u64, events: u32) -> io::Result<()> {
        let mut event = libc::epoll_event { events, u64: token };
        let rc = unsafe { libc::epoll_ctl(self.fd, libc::EPOLL_CTL_ADD, fd, &mut event) };
        if rc == 0 {
            return Ok(());
        }

        let err = io::Error::last_os_error();
        if err.raw_os_error() == Some(libc::EEXIST) {
            return self.modify(fd, token, events);
        }
        Err(err)
    }

    fn modify(&self, fd: RawFd, token: u64, events: u32) -> io::Result<()> {
        let mut event = libc::epoll_event { events, u64: token };
        let rc = unsafe { libc::epoll_ctl(self.fd, libc::EPOLL_CTL_MOD, fd, &mut event) };
        if rc == 0 {
            return Ok(());
        }
        Err(io::Error::last_os_error())
    }

    fn wait(&self, events: &mut [libc::epoll_event]) -> io::Result<usize> {
        loop {
            let rc = unsafe {
                libc::epoll_wait(
                    self.fd,
                    events.as_mut_ptr(),
                    events.len() as libc::c_int,
                    -1,
                )
            };
            if rc >= 0 {
                return Ok(rc as usize);
            }

            let err = io::Error::last_os_error();
            if is_interrupted(&err) {
                continue;
            }
            return Err(err);
        }
    }
}

impl Drop for Epoll {
    fn drop(&mut self) {
        unsafe {
            libc::close(self.fd);
        }
    }
}

#[derive(Clone, Copy)]
enum SocketSide {
    Client,
    Backend,
}

impl SocketSide {
    fn bit(self) -> u64 {
        match self {
            Self::Client => 0,
            Self::Backend => 1,
        }
    }

    fn from_bit(bit: u64) -> Self {
        if bit == 0 {
            Self::Client
        } else {
            Self::Backend
        }
    }
}

struct Direction {
    src_fd: RawFd,
    dst_fd: RawFd,
    pipe: Pipe,
    bytes_in_pipe: usize,
    bytes_written: u64,
    done: bool,
    live_stats: Option<DirectionLiveStats>,
}

impl Direction {
    fn new(
        src_fd: RawFd,
        dst_fd: RawFd,
        live_stats: Option<DirectionLiveStats>,
    ) -> io::Result<Self> {
        Ok(Self {
            src_fd,
            dst_fd,
            pipe: Pipe::new()?,
            bytes_in_pipe: 0,
            bytes_written: 0,
            done: false,
            live_stats,
        })
    }

    fn references(&self, fd: RawFd) -> bool {
        self.src_fd == fd || self.dst_fd == fd
    }

    fn drain(&mut self) -> io::Result<bool> {
        let mut progressed = false;
        loop {
            let mut step_progressed = false;
            step_progressed |= self.drain_to_destination()?;
            step_progressed |= self.drain_from_source()?;
            step_progressed |= self.drain_to_destination()?;

            if !step_progressed {
                return Ok(progressed);
            }
            progressed = true;
        }
    }

    fn drain_from_source(&mut self) -> io::Result<bool> {
        if self.done || self.bytes_in_pipe > 0 {
            return Ok(false);
        }

        loop {
            match splice_raw(self.src_fd, self.pipe.write_fd, MAX_SPLICE) {
                Ok(0) => {
                    self.finish();
                    return Ok(true);
                }
                Ok(n) => {
                    self.bytes_in_pipe = n;
                    return Ok(true);
                }
                Err(err) if is_interrupted(&err) => continue,
                Err(err) if is_wait_again(&err) => return Ok(false),
                Err(err) if is_connection_closed(&err) => {
                    self.finish();
                    return Ok(true);
                }
                Err(err) => return Err(err),
            }
        }
    }

    fn drain_to_destination(&mut self) -> io::Result<bool> {
        let mut progressed = false;
        while !self.done && self.bytes_in_pipe > 0 {
            match splice_raw(self.pipe.read_fd, self.dst_fd, self.bytes_in_pipe) {
                Ok(0) => {
                    self.finish();
                    return Ok(true);
                }
                Ok(n) => {
                    self.bytes_in_pipe -= n;
                    self.bytes_written += n as u64;
                    if let Some(live_stats) = &self.live_stats {
                        live_stats.record(n as u64);
                    }
                    progressed = true;
                }
                Err(err) if is_interrupted(&err) => {}
                Err(err) if is_wait_again(&err) => return Ok(progressed),
                Err(err) if is_connection_closed(&err) => {
                    self.finish();
                    return Ok(true);
                }
                Err(err) => return Err(err),
            }
        }
        Ok(progressed)
    }

    fn finish(&mut self) {
        if !self.done {
            shutdown_write_fd(self.dst_fd);
            self.bytes_in_pipe = 0;
            self.done = true;
        }
    }
}

#[derive(Clone)]
pub struct SpliceStats {
    entry: Arc<ActiveConnEntry>,
    stats: Arc<StatsService>,
}

impl SpliceStats {
    pub fn new(entry: Arc<ActiveConnEntry>, stats: Arc<StatsService>) -> Self {
        Self { entry, stats }
    }
}

#[derive(Clone)]
struct DirectionLiveStats {
    splice_stats: SpliceStats,
    inbound: bool,
}

impl DirectionLiveStats {
    fn record(&self, delta: u64) {
        if self.inbound {
            self.splice_stats
                .stats
                .update_bytes(&self.splice_stats.entry.id, delta, 0);
        } else {
            self.splice_stats
                .stats
                .update_bytes(&self.splice_stats.entry.id, 0, delta);
        }
    }
}

struct ConnState {
    id: u64,
    client: TcpStream,
    backend: TcpStream,
    directions: [Direction; 2],
}

impl ConnState {
    fn new(
        id: u64,
        client: TcpStream,
        backend: TcpStream,
        stats: Option<SpliceStats>,
    ) -> io::Result<Self> {
        client.set_nonblocking(true)?;
        backend.set_nonblocking(true)?;

        let client_fd = client.as_raw_fd();
        let backend_fd = backend.as_raw_fd();
        let inbound_stats = stats.clone().map(|splice_stats| DirectionLiveStats {
            splice_stats,
            inbound: true,
        });
        let outbound_stats = stats.map(|splice_stats| DirectionLiveStats {
            splice_stats,
            inbound: false,
        });
        Ok(Self {
            id,
            client,
            backend,
            directions: [
                Direction::new(client_fd, backend_fd, inbound_stats)?,
                Direction::new(backend_fd, client_fd, outbound_stats)?,
            ],
        })
    }

    fn register(&self, epoll: &Epoll) -> io::Result<()> {
        epoll.add(
            self.client.as_raw_fd(),
            socket_token(self.id, SocketSide::Client),
            EPOLL_SOCKET_EVENTS,
        )?;
        epoll.add(
            self.backend.as_raw_fd(),
            socket_token(self.id, SocketSide::Backend),
            EPOLL_SOCKET_EVENTS,
        )
    }

    fn handle_event(&mut self, side: SocketSide, events: u32) -> io::Result<()> {
        let fd = self.fd(side);
        let close_or_error = (events & EPOLL_CLOSE_EVENTS) != 0;
        let progressed = self.drive()?;
        if close_or_error && !progressed {
            self.finish_fd(fd);
        }
        Ok(())
    }

    fn drive(&mut self) -> io::Result<bool> {
        let mut progressed = false;
        loop {
            let mut step_progressed = false;
            step_progressed |= self.directions[0].drain()?;
            step_progressed |= self.directions[1].drain()?;

            if !step_progressed {
                return Ok(progressed);
            }
            progressed = true;
        }
    }

    fn finish_fd(&mut self, fd: RawFd) {
        for direction in self
            .directions
            .iter_mut()
            .filter(|direction| direction.references(fd))
        {
            direction.finish();
        }
    }

    fn shutdown_both(&self) {
        let _ = self.client.shutdown(Shutdown::Both);
        let _ = self.backend.shutdown(Shutdown::Both);
    }

    fn fd(&self, side: SocketSide) -> RawFd {
        match side {
            SocketSide::Client => self.client.as_raw_fd(),
            SocketSide::Backend => self.backend.as_raw_fd(),
        }
    }

    fn is_done(&self) -> bool {
        self.directions.iter().all(|direction| direction.done)
    }

    fn bytes(&self) -> (u64, u64) {
        (
            self.directions[0].bytes_written,
            self.directions[1].bytes_written,
        )
    }
}

/// Copies a raw TCP pair with Linux splice using a standalone epoll loop.
///
/// Production raw TCP proxying uses `SpliceReactor`; this helper keeps the
/// single-connection state machine directly testable.
pub fn copy_bidirectional_splice(client: TcpStream, backend: TcpStream) -> io::Result<(u64, u64)> {
    let epoll = Epoll::new()?;
    let mut conn = ConnState::new(1, client, backend, None)?;
    conn.register(&epoll)?;
    conn.drive()?;

    let mut events = [libc::epoll_event { events: 0, u64: 0 }; 16];
    while !conn.is_done() {
        let ready = epoll.wait(&mut events)?;
        for event in events.iter().take(ready) {
            let Some((conn_id, side)) = decode_socket_token(event.u64) else {
                continue;
            };
            if conn_id == conn.id {
                conn.handle_event(side, event.events)?;
            }
        }
    }

    Ok(conn.bytes())
}

#[derive(Clone)]
pub struct SpliceCancel {
    id: u64,
    shard: ShardHandle,
}

impl SpliceCancel {
    pub fn cancel(&self) -> io::Result<()> {
        self.shard.send(Command::Cancel { id: self.id })
    }
}

pub struct SpliceJob {
    completion: oneshot::Receiver<io::Result<(u64, u64)>>,
    cancel: SpliceCancel,
}

impl SpliceJob {
    pub fn cancel_handle(&self) -> SpliceCancel {
        self.cancel.clone()
    }

    pub async fn wait(self) -> io::Result<(u64, u64)> {
        self.completion
            .await
            .map_err(|err| io::Error::other(format!("splice reactor dropped completion: {err}")))?
    }
}

pub struct SpliceReactor {
    shards: Vec<ShardHandle>,
    next_shard: AtomicUsize,
    next_id: AtomicU64,
}

impl SpliceReactor {
    pub fn global() -> io::Result<Arc<Self>> {
        let mut guard = GLOBAL_REACTOR
            .lock()
            .map_err(|_| io::Error::other("splice reactor lock poisoned"))?;
        if let Some(reactor) = guard.as_ref() {
            return Ok(reactor.clone());
        }

        let reactor = Arc::new(Self::new(default_shard_count())?);
        *guard = Some(reactor.clone());
        Ok(reactor)
    }

    fn new(shard_count: usize) -> io::Result<Self> {
        let shard_count = shard_count.max(1);
        let mut shards = Vec::with_capacity(shard_count);
        for idx in 0..shard_count {
            shards.push(ShardHandle::start(idx)?);
        }

        Ok(Self {
            shards,
            next_shard: AtomicUsize::new(0),
            next_id: AtomicU64::new(1),
        })
    }

    pub fn submit(
        &self,
        client: TcpStream,
        backend: TcpStream,
        stats: Option<SpliceStats>,
    ) -> io::Result<SpliceJob> {
        let id = self.next_id.fetch_add(1, Ordering::Relaxed);
        let idx = self.next_shard.fetch_add(1, Ordering::Relaxed) % self.shards.len();
        let shard = self.shards[idx].clone();
        let (completion, completion_rx) = oneshot::channel();

        shard.send(Command::Submit {
            id,
            client,
            backend,
            stats,
            completion,
        })?;

        Ok(SpliceJob {
            completion: completion_rx,
            cancel: SpliceCancel { id, shard },
        })
    }
}

#[derive(Clone)]
struct ShardHandle {
    commands: mpsc::Sender<Command>,
    wake: Arc<EventFd>,
}

impl ShardHandle {
    fn start(idx: usize) -> io::Result<Self> {
        let epoll = Epoll::new()?;
        let wake = Arc::new(EventFd::new()?);
        epoll.add(wake.fd(), EVENT_TOKEN, EPOLL_EVENT_EVENTS)?;

        let (commands, command_rx) = mpsc::channel();
        let thread_wake = wake.clone();
        thread::Builder::new()
            .name(format!("nitella-splice-{idx}"))
            .spawn(move || {
                let mut shard = ReactorShard {
                    epoll,
                    wake: thread_wake,
                    commands: command_rx,
                    conns: HashMap::new(),
                };
                if let Err(err) = shard.run() {
                    let message = err.to_string();
                    error!("splice reactor shard {idx} stopped: {message}");
                    shard.fail_all(message);
                }
            })?;

        Ok(Self { commands, wake })
    }

    fn send(&self, command: Command) -> io::Result<()> {
        self.commands.send(command).map_err(|_| {
            io::Error::new(io::ErrorKind::BrokenPipe, "splice reactor shard stopped")
        })?;
        self.wake.wake()
    }
}

enum Command {
    Submit {
        id: u64,
        client: TcpStream,
        backend: TcpStream,
        stats: Option<SpliceStats>,
        completion: oneshot::Sender<io::Result<(u64, u64)>>,
    },
    Cancel {
        id: u64,
    },
}

struct ReactorConn {
    state: ConnState,
    completion: oneshot::Sender<io::Result<(u64, u64)>>,
}

struct ReactorShard {
    epoll: Epoll,
    wake: Arc<EventFd>,
    commands: mpsc::Receiver<Command>,
    conns: HashMap<u64, ReactorConn>,
}

impl ReactorShard {
    fn run(&mut self) -> io::Result<()> {
        let mut events = vec![libc::epoll_event { events: 0, u64: 0 }; EPOLL_BATCH];
        loop {
            self.drain_commands();
            let ready = self.epoll.wait(&mut events)?;
            for event in events.iter().take(ready) {
                if event.u64 == EVENT_TOKEN {
                    self.wake.drain()?;
                    self.drain_commands();
                    continue;
                }
                self.handle_socket_event(event.u64, event.events);
            }
        }
    }

    fn drain_commands(&mut self) {
        loop {
            match self.commands.try_recv() {
                Ok(command) => self.handle_command(command),
                Err(mpsc::TryRecvError::Empty) => break,
                Err(mpsc::TryRecvError::Disconnected) => break,
            }
        }
    }

    fn handle_command(&mut self, command: Command) {
        match command {
            Command::Submit {
                id,
                client,
                backend,
                stats,
                completion,
            } => self.submit(id, client, backend, stats, completion),
            Command::Cancel { id } => self.cancel(id),
        }
    }

    fn submit(
        &mut self,
        id: u64,
        client: TcpStream,
        backend: TcpStream,
        stats: Option<SpliceStats>,
        completion: oneshot::Sender<io::Result<(u64, u64)>>,
    ) {
        let mut state = match ConnState::new(id, client, backend, stats) {
            Ok(state) => state,
            Err(err) => {
                let _ = completion.send(Err(err));
                return;
            }
        };

        if let Err(err) = state.register(&self.epoll).and_then(|_| state.drive()) {
            let _ = completion.send(Err(err));
            return;
        }

        if state.is_done() {
            let _ = completion.send(Ok(state.bytes()));
            return;
        }

        self.conns.insert(id, ReactorConn { state, completion });
    }

    fn cancel(&mut self, id: u64) {
        if let Some(conn) = self.conns.remove(&id) {
            conn.state.shutdown_both();
            let _ = conn.completion.send(Ok((0, 0)));
        }
    }

    fn handle_socket_event(&mut self, token: u64, events: u32) {
        let Some((id, side)) = decode_socket_token(token) else {
            return;
        };

        let completion = {
            let Some(conn) = self.conns.get_mut(&id) else {
                return;
            };

            match conn.state.handle_event(side, events) {
                Ok(()) if conn.state.is_done() => Some(Ok(conn.state.bytes())),
                Ok(()) => None,
                Err(err) => Some(Err(err)),
            }
        };

        if let Some(result) = completion {
            self.complete(id, result);
        }
    }

    fn complete(&mut self, id: u64, result: io::Result<(u64, u64)>) {
        if let Some(conn) = self.conns.remove(&id) {
            let _ = conn.completion.send(result);
        }
    }

    fn fail_all(&mut self, message: String) {
        for (_, conn) in self.conns.drain() {
            let _ = conn.completion.send(Err(io::Error::other(message.clone())));
        }
    }
}

fn default_shard_count() -> usize {
    thread::available_parallelism()
        .map(|threads| threads.get().max(2))
        .unwrap_or(2)
}

fn socket_token(conn_id: u64, side: SocketSide) -> u64 {
    (conn_id << 1) | side.bit()
}

fn decode_socket_token(token: u64) -> Option<(u64, SocketSide)> {
    if token == EVENT_TOKEN {
        return None;
    }
    Some((token >> 1, SocketSide::from_bit(token & 1)))
}

fn splice_raw(from_fd: RawFd, to_fd: RawFd, len: usize) -> io::Result<usize> {
    let n = unsafe {
        libc::splice(
            from_fd,
            std::ptr::null_mut(),
            to_fd,
            std::ptr::null_mut(),
            len,
            SPLICE_FLAGS,
        )
    };
    if n < 0 {
        return Err(io::Error::last_os_error());
    }
    Ok(n as usize)
}

fn is_interrupted(err: &io::Error) -> bool {
    err.raw_os_error() == Some(libc::EINTR)
}

fn is_wait_again(err: &io::Error) -> bool {
    matches!(err.raw_os_error(), Some(code) if code == libc::EAGAIN || code == libc::EWOULDBLOCK)
}

fn is_connection_closed(err: &io::Error) -> bool {
    matches!(
        err.raw_os_error(),
        Some(libc::EPIPE) | Some(libc::ECONNRESET) | Some(libc::ENOTCONN)
    )
}

fn shutdown_write_fd(fd: RawFd) {
    unsafe {
        libc::shutdown(fd, libc::SHUT_WR);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::{Read, Write};
    use std::net::TcpListener;
    use std::time::Duration;

    #[test]
    fn socket_token_round_trips() {
        let (id, side) = decode_socket_token(socket_token(42, SocketSide::Backend)).unwrap();
        assert_eq!(id, 42);
        assert_eq!(side.bit(), SocketSide::Backend.bit());
        assert!(decode_socket_token(EVENT_TOKEN).is_none());
    }

    #[test]
    fn per_connection_splice_copies_both_directions() {
        let (mut client, proxy_client, backend, proxy_backend) = proxy_test_streams();

        let copy_thread =
            thread::spawn(move || copy_bidirectional_splice(proxy_client, proxy_backend));
        let backend_thread = echo_ping_as_pong(backend);

        assert_ping_pong(&mut client);

        backend_thread.join().unwrap();
        let (bytes_in, bytes_out) = copy_thread.join().unwrap().unwrap();
        assert_eq!(bytes_in, 4);
        assert_eq!(bytes_out, 4);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 2)]
    async fn reactor_splice_copies_both_directions() {
        let (mut client, proxy_client, backend, proxy_backend) = proxy_test_streams();
        let reactor = SpliceReactor::new(2).unwrap();
        let job = reactor.submit(proxy_client, proxy_backend, None).unwrap();
        let backend_thread = echo_ping_as_pong(backend);

        assert_ping_pong(&mut client);

        backend_thread.join().unwrap();
        let (bytes_in, bytes_out) = tokio::time::timeout(Duration::from_secs(5), job.wait())
            .await
            .unwrap()
            .unwrap();
        assert_eq!(bytes_in, 4);
        assert_eq!(bytes_out, 4);
    }

    fn proxy_test_streams() -> (TcpStream, TcpStream, TcpStream, TcpStream) {
        let client_listener = TcpListener::bind("127.0.0.1:0").unwrap();
        let client_addr = client_listener.local_addr().unwrap();
        let client = TcpStream::connect(client_addr).unwrap();
        let (proxy_client, _) = client_listener.accept().unwrap();

        let backend_listener = TcpListener::bind("127.0.0.1:0").unwrap();
        let backend_addr = backend_listener.local_addr().unwrap();
        let proxy_backend = TcpStream::connect(backend_addr).unwrap();
        let (backend, _) = backend_listener.accept().unwrap();

        client
            .set_read_timeout(Some(Duration::from_secs(5)))
            .unwrap();
        backend
            .set_read_timeout(Some(Duration::from_secs(5)))
            .unwrap();

        (client, proxy_client, backend, proxy_backend)
    }

    fn echo_ping_as_pong(mut backend: TcpStream) -> thread::JoinHandle<()> {
        thread::spawn(move || {
            let mut request = [0_u8; 4];
            backend.read_exact(&mut request).unwrap();
            assert_eq!(&request, b"ping");
            backend.write_all(b"pong").unwrap();
            let _ = backend.shutdown(Shutdown::Both);
        })
    }

    fn assert_ping_pong(client: &mut TcpStream) {
        client.write_all(b"ping").unwrap();
        let mut response = [0_u8; 4];
        client.read_exact(&mut response).unwrap();
        assert_eq!(&response, b"pong");
        let _ = client.shutdown(Shutdown::Both);
    }
}
