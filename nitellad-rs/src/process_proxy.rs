use tokio::process::Command;
use tonic::transport::{Channel, Endpoint, Uri};
use tower::service_fn;
use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::{info, error};
use std::os::unix::io::{FromRawFd};
use std::time::Duration;

use crate::proto::process::process_control_client::ProcessControlClient;
use crate::proto::process::*;
use crate::proto::process::*;
use crate::proto::proxy::{CreateProxyRequest, ProxyStatus, Rule, ActiveConnection};

#[derive(Clone)]
pub struct ProcessProxyListener {
    id: String,
    client: Arc<RwLock<Option<ProcessControlClient<Channel>>>>,
    child_pid: Arc<RwLock<Option<u32>>>,
}

impl ProcessProxyListener {
    pub fn new(id: String) -> Self {
        Self {
            id,
            client: Arc::new(RwLock::new(None)),
            child_pid: Arc::new(RwLock::new(None)),
        }
    }

    pub async fn start(&self, req: &CreateProxyRequest) -> anyhow::Result<()> {
        let (parent_fd, child_fd) = unsafe {
            let mut fds = [0i32; 2];
            if libc::socketpair(libc::AF_UNIX, libc::SOCK_STREAM, 0, fds.as_mut_ptr()) < 0 {
                return Err(anyhow::anyhow!("Failed to create socketpair"));
            }
            (fds[0], fds[1])
        };

        let exe = std::env::current_exe()?;
        let mut cmd = Command::new(exe);
        cmd.arg("child")
           .arg("--id").arg(&self.id)
           .arg("--name").arg(&req.name)
           .arg("--listen").arg(&req.listen_addr);
        
        if !req.default_backend.is_empty() {
            cmd.arg("--backend").arg(&req.default_backend);
        }

        unsafe {
            cmd.pre_exec(move || {
                if child_fd != 3 {
                    if libc::dup2(child_fd, 3) < 0 {
                        return Err(std::io::Error::last_os_error());
                    }
                    libc::close(child_fd);
                }
                libc::close(parent_fd);
                Ok(())
            });
        }

        let child = cmd.spawn()?;
        let pid = child.id().unwrap_or(0);
        *self.child_pid.write().await = Some(pid);
        
        unsafe { libc::close(child_fd) };

        let channel = Endpoint::try_from("http://[::]:50051")?
            .connect_with_connector(service_fn(move |_: Uri| {
                let s = unsafe { std::os::unix::net::UnixStream::from_raw_fd(libc::dup(parent_fd)) };
                let _ = s.set_nonblocking(true);
                let tokio_stream = tokio::net::UnixStream::from_std(s).unwrap();
                async move { Ok::<_, std::io::Error>(tokio_stream) }
            }))
            .await?;
        
        let mut client = ProcessControlClient::new(channel);
        
        tokio::time::sleep(Duration::from_millis(500)).await;

        let start_req = StartListenerRequest {
            id: self.id.clone(),
            name: req.name.clone(),
            listen_addr: req.listen_addr.clone(),
            default_backend: req.default_backend.clone(),
            default_action: req.default_action,
            ..Default::default()
        };

        if let Err(e) = client.start_listener(start_req).await {
            error!("Failed to start listener in child: {}", e);
            return Err(e.into());
        }

        *self.client.write().await = Some(client);
        
        info!("Started process proxy {} (PID: {:?})", req.name, pid);
        Ok(())
    }

    pub async fn stop(&self) -> anyhow::Result<()> {
        let mut client_lock = self.client.write().await;
        if let Some(client) = client_lock.as_mut() {
            let _ = client.stop_listener(StopListenerRequest {}).await;
        }
        
        let mut pid_lock = self.child_pid.write().await;
        if let Some(pid) = *pid_lock {
            unsafe { libc::kill(pid as i32, libc::SIGTERM) };
            *pid_lock = None;
        }
        Ok(())
    }

    pub async fn get_status(&self) -> ProxyStatus {
        let mut client_lock = self.client.write().await;
        if let Some(client) = client_lock.as_mut() {
            if let Ok(resp) = client.get_metrics(GetMetricsRequest {}).await {
                if let Some(status) = resp.into_inner().status {
                    return status;
                }
            }
        }
        ProxyStatus {
            proxy_id: self.id.clone(),
            running: false,
            ..Default::default()
        }
    }

    pub async fn add_rule(&self, rule: Rule) -> anyhow::Result<()> {
        let mut client_lock = self.client.write().await;
        if let Some(client) = client_lock.as_mut() {
             client.add_rule(AddRuleRequest {
                 rule: Some(rule),
             }).await?;
             Ok(())
        } else {
            Err(anyhow::anyhow!("Child not connected"))
        }
    }

    pub async fn remove_rule(&self, rule_id: String) -> anyhow::Result<()> {
        let mut client_lock = self.client.write().await;
        if let Some(client) = client_lock.as_mut() {
             client.remove_rule(RemoveRuleRequest {
                 rule_id,
             }).await?;
             Ok(())
        } else {
            Err(anyhow::anyhow!("Child not connected"))
        }
    }

    pub async fn get_active_connections(&self) -> anyhow::Result<Vec<ActiveConnection>> {
        let mut client_lock = self.client.write().await;
        if let Some(client) = client_lock.as_mut() {
            let resp = client.get_active_connections(GetActiveConnectionsRequest {}).await?;
            Ok(resp.into_inner().connections)
        } else {
            Ok(vec![])
        }
    }

    pub async fn close_connection(&self, conn_id: String) -> anyhow::Result<()> {
        let mut client_lock = self.client.write().await;
        if let Some(client) = client_lock.as_mut() {
             client.close_connection(CloseConnectionRequest { conn_id }).await?;
             Ok(())
        } else {
            Ok(())
        }
    }
    
    pub async fn close_all_connections(&self) -> anyhow::Result<()> {
        let mut client_lock = self.client.write().await;
        if let Some(client) = client_lock.as_mut() {
             client.close_all_connections(CloseAllConnectionsRequest {}).await?;
             Ok(())
        } else {
            Ok(())
        }
    }
}
