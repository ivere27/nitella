#[cfg(target_os = "linux")]
mod linux {
    use rustix::io_uring::{
        io_uring_cqe, io_uring_enter, io_uring_params, io_uring_setup, io_uring_sqe,
        io_uring_user_data, IoringEnterFlags, IoringFeatureFlags, IoringOp, IoringPollFlags,
        SpliceFlags,
    };
    use std::ffi::c_void;
    use std::io;
    use std::net::{Shutdown, SocketAddr, TcpListener, TcpStream};
    use std::os::fd::{AsFd, AsRawFd, OwnedFd, RawFd};
    use std::ptr;
    use std::sync::atomic::{fence, Ordering};
    use std::thread;

    const IORING_OFF_SQ_RING: libc::off_t = 0;
    const IORING_OFF_CQ_RING: libc::off_t = 0x8000000;
    const IORING_OFF_SQES: libc::off_t = 0x10000000;
    const RING_ENTRIES: u32 = 32;
    const MAX_SPLICE: u32 = 1 << 20;
    const SPLICE_FLAGS: u32 = libc::SPLICE_F_MOVE as u32;

    #[derive(Clone)]
    struct Config {
        listen: SocketAddr,
        backend: SocketAddr,
    }

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

    #[derive(Clone, Copy)]
    struct Cqe {
        user_data: u64,
        res: i32,
    }

    struct IoUring {
        fd: OwnedFd,
        sq_ring: *mut c_void,
        sq_ring_len: usize,
        cq_ring: *mut c_void,
        cq_ring_len: usize,
        sqes: *mut io_uring_sqe,
        sqes_len: usize,
        single_mmap: bool,
        sq_head: *mut u32,
        sq_tail: *mut u32,
        sq_ring_mask: *mut u32,
        sq_ring_entries: *mut u32,
        sq_array: *mut u32,
        cq_head: *mut u32,
        cq_tail: *mut u32,
        cq_ring_mask: *mut u32,
        cqes: *mut io_uring_cqe,
        pending: u32,
    }

    impl IoUring {
        fn new(entries: u32) -> io::Result<Self> {
            let mut params = io_uring_params::default();
            let fd = unsafe { io_uring_setup(entries, &mut params) }.map_err(rustix_to_io)?;

            let sq_ring_len =
                params.sq_off.array as usize + params.sq_entries as usize * size_of::<u32>();
            let cq_ring_len = params.cq_off.cqes as usize
                + params.cq_entries as usize * size_of::<io_uring_cqe>();
            let single_mmap = params.features.contains(IoringFeatureFlags::SINGLE_MMAP);
            let mapped_ring_len = if single_mmap {
                sq_ring_len.max(cq_ring_len)
            } else {
                sq_ring_len
            };

            let sq_ring = mmap_ring(fd.as_raw_fd(), mapped_ring_len, IORING_OFF_SQ_RING)?;
            let cq_ring = if single_mmap {
                sq_ring
            } else {
                mmap_ring(fd.as_raw_fd(), cq_ring_len, IORING_OFF_CQ_RING)?
            };
            let sqes_len = params.sq_entries as usize * size_of::<io_uring_sqe>();
            let sqes = mmap_ring(fd.as_raw_fd(), sqes_len, IORING_OFF_SQES)?.cast::<io_uring_sqe>();

            let sq_head = ring_ptr::<u32>(sq_ring, params.sq_off.head);
            let sq_tail = ring_ptr::<u32>(sq_ring, params.sq_off.tail);
            let sq_ring_mask = ring_ptr::<u32>(sq_ring, params.sq_off.ring_mask);
            let sq_ring_entries = ring_ptr::<u32>(sq_ring, params.sq_off.ring_entries);
            let sq_array = ring_ptr::<u32>(sq_ring, params.sq_off.array);
            let cq_head = ring_ptr::<u32>(cq_ring, params.cq_off.head);
            let cq_tail = ring_ptr::<u32>(cq_ring, params.cq_off.tail);
            let cq_ring_mask = ring_ptr::<u32>(cq_ring, params.cq_off.ring_mask);
            let cqes = ring_ptr::<io_uring_cqe>(cq_ring, params.cq_off.cqes);

            Ok(Self {
                fd,
                sq_ring,
                sq_ring_len: mapped_ring_len,
                cq_ring,
                cq_ring_len,
                sqes,
                sqes_len,
                single_mmap,
                sq_head,
                sq_tail,
                sq_ring_mask,
                sq_ring_entries,
                sq_array,
                cq_head,
                cq_tail,
                cq_ring_mask,
                cqes,
                pending: 0,
            })
        }

        fn push(&mut self, sqe: io_uring_sqe) -> io::Result<()> {
            let head = unsafe { ptr::read_volatile(self.sq_head) };
            let tail = unsafe { ptr::read_volatile(self.sq_tail) };
            let entries = unsafe { ptr::read_volatile(self.sq_ring_entries) };
            if tail.wrapping_sub(head) >= entries {
                return Err(io::Error::new(
                    io::ErrorKind::WouldBlock,
                    "io_uring submission queue is full",
                ));
            }

            let mask = unsafe { ptr::read_volatile(self.sq_ring_mask) };
            let index = tail & mask;
            unsafe {
                ptr::write(self.sqes.add(index as usize), sqe);
                ptr::write_volatile(self.sq_array.add(index as usize), index);
            }
            fence(Ordering::Release);
            unsafe {
                ptr::write_volatile(self.sq_tail, tail.wrapping_add(1));
            }
            self.pending += 1;
            Ok(())
        }

        fn submit_pending(&mut self) -> io::Result<()> {
            let mut left = self.pending;
            while left > 0 {
                let submitted =
                    loop {
                        match unsafe {
                            io_uring_enter(self.fd.as_fd(), left, 0, IoringEnterFlags::empty())
                        } {
                            Ok(n) => break n,
                            Err(err) if err.raw_os_error() == libc::EINTR => continue,
                            Err(err) => {
                                let err = rustix_to_io(err);
                                return Err(io::Error::new(
                            err.kind(),
                            format!("io_uring_enter submit failed with {left} pending SQEs: {err}"),
                        ));
                            }
                        }
                    };
                if submitted == 0 {
                    return Err(io::Error::new(
                        io::ErrorKind::WriteZero,
                        "io_uring_enter submitted zero SQEs",
                    ));
                }
                left -= submitted;
            }
            self.pending = 0;
            Ok(())
        }

        fn wait_cqe(&mut self) -> io::Result<Cqe> {
            loop {
                if let Some(cqe) = self.peek_cqe() {
                    return Ok(cqe);
                }

                loop {
                    match unsafe {
                        io_uring_enter(self.fd.as_fd(), 0, 1, IoringEnterFlags::GETEVENTS)
                    } {
                        Ok(_) => break,
                        Err(err) if err.raw_os_error() == libc::EINTR => continue,
                        Err(err) => {
                            let err = rustix_to_io(err);
                            return Err(io::Error::new(
                                err.kind(),
                                format!("io_uring_enter wait failed: {err}"),
                            ));
                        }
                    }
                }
            }
        }

        fn peek_cqe(&mut self) -> Option<Cqe> {
            let head = unsafe { ptr::read_volatile(self.cq_head) };
            let tail = unsafe { ptr::read_volatile(self.cq_tail) };
            if head == tail {
                return None;
            }

            fence(Ordering::Acquire);
            let mask = unsafe { ptr::read_volatile(self.cq_ring_mask) };
            let index = head & mask;
            let cqe = unsafe { &*self.cqes.add(index as usize) };
            let out = Cqe {
                user_data: cqe.user_data.u64_(),
                res: cqe.res,
            };
            unsafe {
                ptr::write_volatile(self.cq_head, head.wrapping_add(1));
            }
            Some(out)
        }
    }

    impl Drop for IoUring {
        fn drop(&mut self) {
            unsafe {
                libc::munmap(self.sqes.cast::<c_void>(), self.sqes_len);
                if self.single_mmap {
                    libc::munmap(self.sq_ring, self.sq_ring_len);
                } else {
                    libc::munmap(self.sq_ring, self.sq_ring_len);
                    libc::munmap(self.cq_ring, self.cq_ring_len);
                }
            }
        }
    }

    #[derive(Clone, Copy)]
    enum Op {
        SpliceFromSource = 1,
        SpliceToDestination = 2,
        PollSource = 3,
        PollDestination = 4,
    }

    impl Op {
        fn from_u64(value: u64) -> Option<Self> {
            match value {
                1 => Some(Self::SpliceFromSource),
                2 => Some(Self::SpliceToDestination),
                3 => Some(Self::PollSource),
                4 => Some(Self::PollDestination),
                _ => None,
            }
        }
    }

    #[derive(Clone, Copy)]
    enum Need {
        Work,
        PollSource,
        PollDestination,
    }

    struct Direction {
        src_fd: RawFd,
        dst_fd: RawFd,
        pipe: Pipe,
        bytes_in_pipe: usize,
        bytes_written: u64,
        done: bool,
        in_flight: bool,
        need: Need,
    }

    impl Direction {
        fn new(src_fd: RawFd, dst_fd: RawFd) -> io::Result<Self> {
            Ok(Self {
                src_fd,
                dst_fd,
                pipe: Pipe::new()?,
                bytes_in_pipe: 0,
                bytes_written: 0,
                done: false,
                in_flight: false,
                need: Need::Work,
            })
        }

        fn schedule(&mut self, ring: &mut IoUring, index: usize) -> io::Result<()> {
            if self.done || self.in_flight {
                return Ok(());
            }

            match self.need {
                Need::PollSource => {
                    ring.push(poll_sqe(
                        self.src_fd,
                        poll_source_flags(),
                        encode_user_data(index, Op::PollSource),
                    ))?;
                }
                Need::PollDestination => {
                    ring.push(poll_sqe(
                        self.dst_fd,
                        poll_destination_flags(),
                        encode_user_data(index, Op::PollDestination),
                    ))?;
                }
                Need::Work if self.bytes_in_pipe > 0 => {
                    ring.push(splice_sqe(
                        self.pipe.read_fd,
                        self.dst_fd,
                        self.bytes_in_pipe as u32,
                        encode_user_data(index, Op::SpliceToDestination),
                    ))?;
                }
                Need::Work => {
                    ring.push(splice_sqe(
                        self.src_fd,
                        self.pipe.write_fd,
                        MAX_SPLICE,
                        encode_user_data(index, Op::SpliceFromSource),
                    ))?;
                }
            }

            self.in_flight = true;
            Ok(())
        }

        fn complete(&mut self, op: Op, res: i32) -> io::Result<()> {
            self.in_flight = false;
            match op {
                Op::PollSource | Op::PollDestination => self.complete_poll(res),
                Op::SpliceFromSource => self.complete_splice_from_source(res),
                Op::SpliceToDestination => self.complete_splice_to_destination(res),
            }
        }

        fn complete_poll(&mut self, res: i32) -> io::Result<()> {
            if res < 0 {
                let err = io::Error::from_raw_os_error(-res);
                if is_connection_closed(&err) {
                    self.finish();
                    return Ok(());
                }
                return Err(err);
            }
            self.need = Need::Work;
            Ok(())
        }

        fn complete_splice_from_source(&mut self, res: i32) -> io::Result<()> {
            if res == 0 {
                self.finish();
                return Ok(());
            }
            if res > 0 {
                self.bytes_in_pipe = res as usize;
                self.need = Need::Work;
                return Ok(());
            }

            let err = io::Error::from_raw_os_error(-res);
            if is_wait_again(&err) {
                self.need = Need::PollSource;
                return Ok(());
            }
            if is_connection_closed(&err) {
                self.finish();
                return Ok(());
            }
            Err(io::Error::new(
                err.kind(),
                format!("splice from source failed: {err}"),
            ))
        }

        fn complete_splice_to_destination(&mut self, res: i32) -> io::Result<()> {
            if res == 0 {
                self.finish();
                return Ok(());
            }
            if res > 0 {
                let n = res as usize;
                self.bytes_in_pipe = self.bytes_in_pipe.saturating_sub(n);
                self.bytes_written += n as u64;
                self.need = Need::Work;
                return Ok(());
            }

            let err = io::Error::from_raw_os_error(-res);
            if is_wait_again(&err) {
                self.need = Need::PollDestination;
                return Ok(());
            }
            if is_connection_closed(&err) {
                self.finish();
                return Ok(());
            }
            Err(io::Error::new(
                err.kind(),
                format!("splice to destination failed: {err}"),
            ))
        }

        fn finish(&mut self) {
            if !self.done {
                unsafe {
                    libc::shutdown(self.dst_fd, libc::SHUT_WR);
                }
                self.bytes_in_pipe = 0;
                self.done = true;
            }
        }
    }

    fn copy_bidirectional_io_uring_splice(
        client: TcpStream,
        backend: TcpStream,
    ) -> io::Result<(u64, u64)> {
        client.set_nonblocking(true)?;
        backend.set_nonblocking(true)?;
        let _ = client.set_nodelay(true);
        let _ = backend.set_nodelay(true);

        let client_fd = client.as_raw_fd();
        let backend_fd = backend.as_raw_fd();
        let mut ring = IoUring::new(RING_ENTRIES)?;
        let mut directions = [
            Direction::new(client_fd, backend_fd)?,
            Direction::new(backend_fd, client_fd)?,
        ];

        schedule_all(&mut directions, &mut ring)?;
        ring.submit_pending()?;

        while !directions.iter().all(|direction| direction.done) {
            let cqe = ring.wait_cqe()?;
            let (index, op) = decode_user_data(cqe.user_data)?;
            directions[index].complete(op, cqe.res)?;
            schedule_all(&mut directions, &mut ring)?;
            ring.submit_pending()?;
        }

        let _ = client.shutdown(Shutdown::Both);
        let _ = backend.shutdown(Shutdown::Both);
        Ok((directions[0].bytes_written, directions[1].bytes_written))
    }

    fn schedule_all(directions: &mut [Direction; 2], ring: &mut IoUring) -> io::Result<()> {
        for (index, direction) in directions.iter_mut().enumerate() {
            direction.schedule(ring, index)?;
        }
        Ok(())
    }

    fn splice_sqe(fd_in: RawFd, fd_out: RawFd, len: u32, user_data: u64) -> io_uring_sqe {
        let mut sqe = io_uring_sqe::default();
        sqe.opcode = IoringOp::Splice;
        sqe.fd = fd_out;
        sqe.off_or_addr2.off = u64::MAX;
        sqe.addr_or_splice_off_in.splice_off_in = u64::MAX;
        sqe.len.len = len;
        sqe.op_flags.splice_flags = SpliceFlags::from_bits_retain(SPLICE_FLAGS);
        sqe.user_data = io_uring_user_data::from_u64(user_data);
        sqe.splice_fd_in_or_file_index_or_addr_len.splice_fd_in = fd_in;
        sqe
    }

    fn poll_sqe(fd: RawFd, flags: IoringPollFlags, user_data: u64) -> io_uring_sqe {
        let mut sqe = io_uring_sqe::default();
        sqe.opcode = IoringOp::PollAdd;
        sqe.fd = fd;
        sqe.op_flags.poll32_events = flags.bits();
        sqe.user_data = io_uring_user_data::from_u64(user_data);
        sqe
    }

    fn poll_source_flags() -> IoringPollFlags {
        IoringPollFlags::from_bits_retain(
            (libc::POLLIN | libc::POLLRDHUP | libc::POLLERR | libc::POLLHUP) as u32,
        )
    }

    fn poll_destination_flags() -> IoringPollFlags {
        IoringPollFlags::from_bits_retain((libc::POLLOUT | libc::POLLERR | libc::POLLHUP) as u32)
    }

    fn encode_user_data(index: usize, op: Op) -> u64 {
        ((index as u64) << 8) | op as u64
    }

    fn decode_user_data(value: u64) -> io::Result<(usize, Op)> {
        let index = (value >> 8) as usize;
        let op = Op::from_u64(value & 0xff).ok_or_else(|| {
            io::Error::new(
                io::ErrorKind::InvalidData,
                format!("unknown io_uring user data op: {value}"),
            )
        })?;
        if index >= 2 {
            return Err(io::Error::new(
                io::ErrorKind::InvalidData,
                format!("unknown io_uring direction index: {index}"),
            ));
        }
        Ok((index, op))
    }

    fn parse_config() -> Config {
        let mut listen = "0.0.0.0:8081".parse().unwrap();
        let mut backend = "127.0.0.1:9090".parse().unwrap();
        let mut args = std::env::args().skip(1);

        while let Some(arg) = args.next() {
            match arg.as_str() {
                "--listen" => {
                    let Some(value) = args.next() else {
                        eprintln!("missing value for --listen");
                        std::process::exit(2);
                    };
                    listen = value.parse().unwrap_or_else(|_| {
                        eprintln!("invalid --listen address: {value}");
                        std::process::exit(2);
                    });
                }
                "--backend" => {
                    let Some(value) = args.next() else {
                        eprintln!("missing value for --backend");
                        std::process::exit(2);
                    };
                    backend = value.parse().unwrap_or_else(|_| {
                        eprintln!("invalid --backend address: {value}");
                        std::process::exit(2);
                    });
                }
                "-h" | "--help" => {
                    println!("Usage: io_uring_splice_proxy [--listen ADDR] [--backend ADDR]");
                    std::process::exit(0);
                }
                other => {
                    eprintln!("unknown argument: {other}");
                    std::process::exit(2);
                }
            }
        }

        Config { listen, backend }
    }

    fn handle_connection(client: TcpStream, backend_addr: SocketAddr) -> io::Result<(u64, u64)> {
        let backend = TcpStream::connect(backend_addr)?;
        copy_bidirectional_io_uring_splice(client, backend)
    }

    fn mmap_ring(fd: RawFd, len: usize, offset: libc::off_t) -> io::Result<*mut c_void> {
        let ptr = unsafe {
            libc::mmap(
                ptr::null_mut(),
                len,
                libc::PROT_READ | libc::PROT_WRITE,
                libc::MAP_SHARED | libc::MAP_POPULATE,
                fd,
                offset,
            )
        };
        if ptr == libc::MAP_FAILED {
            return Err(io::Error::last_os_error());
        }
        Ok(ptr)
    }

    fn ring_ptr<T>(base: *mut c_void, offset: u32) -> *mut T {
        unsafe { base.cast::<u8>().add(offset as usize).cast::<T>() }
    }

    fn rustix_to_io(err: rustix::io::Errno) -> io::Error {
        io::Error::from_raw_os_error(err.raw_os_error())
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

    pub fn run() -> io::Result<()> {
        let config = parse_config();
        let listener = TcpListener::bind(config.listen)?;
        eprintln!(
            "io_uring splice prototype listening on {}, backend {}",
            config.listen, config.backend
        );

        for stream in listener.incoming() {
            match stream {
                Ok(stream) => {
                    let backend = config.backend;
                    thread::spawn(move || {
                        if let Err(err) = handle_connection(stream, backend) {
                            if err.kind() != io::ErrorKind::ConnectionReset
                                && err.kind() != io::ErrorKind::BrokenPipe
                            {
                                eprintln!("io_uring splice connection error: {err}");
                            }
                        }
                    });
                }
                Err(err) => eprintln!("accept error: {err}"),
            }
        }

        Ok(())
    }
}

#[cfg(target_os = "linux")]
fn main() -> std::io::Result<()> {
    linux::run()
}

#[cfg(not(target_os = "linux"))]
fn main() {
    eprintln!("io_uring is Linux-only");
    std::process::exit(1);
}
