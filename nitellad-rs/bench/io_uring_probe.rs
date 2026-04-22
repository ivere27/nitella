#[cfg(target_os = "linux")]
mod linux {
    use rustix::io_uring::{
        io_uring_params, io_uring_probe, io_uring_probe_op, io_uring_register, io_uring_setup,
        IoringOp, IoringOpFlags, IoringRegisterOp,
    };
    use std::ffi::c_void;
    use std::os::fd::AsRawFd;

    const PROBE_OPS: usize = 256;

    #[repr(C)]
    struct Probe {
        header: io_uring_probe,
        ops: [io_uring_probe_op; PROBE_OPS],
    }

    impl Default for Probe {
        fn default() -> Self {
            Self {
                header: io_uring_probe::default(),
                ops: [io_uring_probe_op::default(); PROBE_OPS],
            }
        }
    }

    pub fn run() -> Result<(), Box<dyn std::error::Error>> {
        let mut params = io_uring_params::default();
        let ring = unsafe { io_uring_setup(8, &mut params)? };
        let mut probe = Probe::default();

        unsafe {
            io_uring_register(
                &ring,
                IoringRegisterOp::RegisterProbe,
                (&mut probe as *mut Probe).cast::<c_void>(),
                PROBE_OPS as u32,
            )?;
        }

        let ops_len = usize::from(probe.header.ops_len).min(PROBE_OPS);
        let splice = probe
            .ops
            .iter()
            .take(ops_len)
            .find(|op| op.op == IoringOp::Splice);
        let splice_supported = splice
            .map(|op| op.flags.contains(IoringOpFlags::SUPPORTED))
            .unwrap_or(false);

        println!("io_uring fd: {}", ring.as_raw_fd());
        println!("setup features: {:?}", params.features);
        println!("probe ops: {}", ops_len);
        println!(
            "IORING_OP_SPLICE: {}",
            if splice_supported {
                "supported"
            } else {
                "not supported"
            }
        );

        if splice_supported {
            Ok(())
        } else {
            Err("kernel did not report IORING_OP_SPLICE support".into())
        }
    }
}

#[cfg(target_os = "linux")]
fn main() -> Result<(), Box<dyn std::error::Error>> {
    linux::run()
}

#[cfg(not(target_os = "linux"))]
fn main() {
    eprintln!("io_uring is Linux-only");
    std::process::exit(1);
}
