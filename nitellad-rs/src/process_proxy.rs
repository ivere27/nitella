#[cfg(unix)]
use std::os::unix::io::FromRawFd;
use std::sync::Arc;
#[cfg(unix)]
use std::time::Duration;
#[cfg(unix)]
use tokio::process::{Child, Command};
use tokio::sync::RwLock;
use tonic::transport::Channel;
#[cfg(unix)]
use tonic::transport::{Endpoint, Uri};
#[cfg(unix)]
use tower::service_fn;
#[cfg(unix)]
use tracing::{error, info, warn};

use crate::proto::process::process_control_client::ProcessControlClient;
use crate::proto::process::*;
#[cfg(unix)]
use crate::proto::proxy::MockConfig;
use crate::proto::proxy::{ActiveConnection, CreateProxyRequest, ProxyStatus, Rule};

#[derive(Clone)]
pub struct ProcessProxyListener {
    id: String,
    client: Arc<RwLock<Option<ProcessControlClient<Channel>>>>,
    #[cfg(unix)]
    child: Arc<RwLock<Option<Child>>>,
}

impl ProcessProxyListener {
    pub fn new(id: String) -> Self {
        Self {
            id,
            client: Arc::new(RwLock::new(None)),
            #[cfg(unix)]
            child: Arc::new(RwLock::new(None)),
        }
    }

    pub async fn start(&self, req: &CreateProxyRequest) -> anyhow::Result<()> {
        #[cfg(not(unix))]
        {
            let _ = req;
            return Err(anyhow::anyhow!(
                "process mode requires Unix socketpair transport on this build"
            ));
        }

        #[cfg(unix)]
        {
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
                .arg("--id")
                .arg(&self.id)
                .arg("--name")
                .arg(&req.name)
                .arg("--listen")
                .arg(&req.listen_addr);

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

            let mut child = cmd.spawn()?;
            let pid = child.id().unwrap_or(0);

            unsafe { libc::close(child_fd) };

            let channel = match Endpoint::try_from("http://[::]:50051")?
                .connect_with_connector(service_fn(move |_: Uri| {
                    let s = unsafe {
                        std::os::unix::net::UnixStream::from_raw_fd(libc::dup(parent_fd))
                    };
                    let _ = s.set_nonblocking(true);
                    let tokio_stream = tokio::net::UnixStream::from_std(s).unwrap();
                    async move { Ok::<_, std::io::Error>(tokio_stream) }
                }))
                .await
            {
                Ok(channel) => channel,
                Err(e) => {
                    Self::terminate_child(&mut child).await;
                    return Err(e.into());
                }
            };

            let mut client = ProcessControlClient::new(channel);

            tokio::time::sleep(Duration::from_millis(500)).await;

            let start_req = StartListenerRequest {
                id: self.id.clone(),
                name: req.name.clone(),
                listen_addr: req.listen_addr.clone(),
                default_backend: req.default_backend.clone(),
                default_action: req.default_action,
                default_mock: Some(MockConfig {
                    preset: req.default_mock,
                    ..Default::default()
                }),
                cert_pem: req.cert_pem.clone(),
                key_pem: req.key_pem.clone(),
                ca_pem: req.ca_pem.clone(),
                client_auth_type: req.client_auth_type,
                fallback_action: req.fallback_action,
                fallback_mock: req.fallback_mock,
                ..Default::default()
            };

            if let Err(e) = client.start_listener(start_req).await {
                error!("Failed to start listener in child: {}", e);
                Self::terminate_child(&mut child).await;
                return Err(e.into());
            }

            *self.client.write().await = Some(client);
            *self.child.write().await = Some(child);

            info!("Started process proxy {} (PID: {:?})", req.name, pid);
            Ok(())
        }
    }

    pub async fn stop(&self) -> anyhow::Result<()> {
        let mut client_lock = self.client.write().await;
        if let Some(client) = client_lock.as_mut() {
            let _ = client.stop_listener(StopListenerRequest {}).await;
        }
        *client_lock = None;
        drop(client_lock);

        #[cfg(unix)]
        {
            let mut child_lock = self.child.write().await;
            if let Some(mut child) = child_lock.take() {
                Self::terminate_child(&mut child).await;
            }
        }
        Ok(())
    }

    #[cfg(unix)]
    async fn terminate_child(child: &mut Child) {
        let pid = child.id();
        if let Some(pid) = pid {
            unsafe { libc::kill(pid as i32, libc::SIGTERM) };
        }

        match tokio::time::timeout(Duration::from_secs(2), child.wait()).await {
            Ok(Ok(status)) => {
                info!("Process proxy child {:?} exited with {}", pid, status);
            }
            Ok(Err(e)) => {
                warn!("Failed waiting for process proxy child {:?}: {}", pid, e);
            }
            Err(_) => {
                warn!(
                    "Process proxy child {:?} did not exit after SIGTERM; killing",
                    pid
                );
                if let Err(e) = child.kill().await {
                    warn!("Failed killing process proxy child {:?}: {}", pid, e);
                }
            }
        }
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
            client.add_rule(AddRuleRequest { rule: Some(rule) }).await?;
            Ok(())
        } else {
            Err(anyhow::anyhow!("Child not connected"))
        }
    }

    pub async fn remove_rule(&self, rule_id: String) -> anyhow::Result<()> {
        let mut client_lock = self.client.write().await;
        if let Some(client) = client_lock.as_mut() {
            client.remove_rule(RemoveRuleRequest { rule_id }).await?;
            Ok(())
        } else {
            Err(anyhow::anyhow!("Child not connected"))
        }
    }

    pub async fn get_active_connections(&self) -> anyhow::Result<Vec<ActiveConnection>> {
        let mut client_lock = self.client.write().await;
        if let Some(client) = client_lock.as_mut() {
            let resp = client
                .get_active_connections(GetActiveConnectionsRequest {})
                .await?;
            Ok(resp.into_inner().connections)
        } else {
            Ok(vec![])
        }
    }

    pub async fn close_connection(&self, conn_id: String) -> anyhow::Result<()> {
        let mut client_lock = self.client.write().await;
        if let Some(client) = client_lock.as_mut() {
            client
                .close_connection(CloseConnectionRequest { conn_id })
                .await?;
            Ok(())
        } else {
            Ok(())
        }
    }

    pub async fn close_all_connections(&self) -> anyhow::Result<()> {
        let mut client_lock = self.client.write().await;
        if let Some(client) = client_lock.as_mut() {
            client
                .close_all_connections(CloseAllConnectionsRequest {})
                .await?;
            Ok(())
        } else {
            Ok(())
        }
    }
}
