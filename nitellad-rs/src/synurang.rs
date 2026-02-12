#[cfg(unix)]
use std::os::fd::FromRawFd;
#[cfg(unix)]

use tracing::{info, error};

/// Retrieves the Synurang IPC transport.
/// 
/// Synurang (Go) passes the IPC socket to the child process via File Descriptor 3 on Unix systems.
/// This function attempts to adopt FD 3 as a UnixStream (connected socket).
pub fn get_ipc_transport() -> Option<tokio::net::UnixStream> {
    #[cfg(unix)]
    {
        let fd = 3;
        // Safety: We assume the parent process (Synurang/Go) has passed us a valid connected socket at FD 3.
        let stream = unsafe { std::os::unix::net::UnixStream::from_raw_fd(fd) };
        
        match stream.peer_addr() {
            Ok(_) => {
                info!("Synurang: Inherited IPC socket on FD 3");
                if let Err(e) = stream.set_nonblocking(true) {
                    error!("Synurang: Failed to set non-blocking on FD 3: {}", e);
                    return None;
                }
                match tokio::net::UnixStream::from_std(stream) {
                    Ok(s) => Some(s),
                    Err(e) => {
                        error!("Synurang: Failed to convert FD 3 to Tokio stream: {}", e);
                        None
                    }
                }
            },
            Err(e) => {
                // If it's a valid socket but not connected, peer_addr might fail?
                // For socketpair, it should be connected.
                // But let's log and try anyway if error is minor?
                // Actually peer_addr on unnamed unix socket might return Ok(addr) where addr is unnamed.
                // If error, likely not a socket.
                error!("Synurang: FD 3 issue (peer_addr check): {}", e);
                None
            }
        }
    }
    #[cfg(not(unix))]
    {
        error!("Synurang: Non-Unix IPC (Windows) not yet implemented in Rust adapter.");
        None
    }
}
