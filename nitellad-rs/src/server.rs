use tonic::{Request, Response, Status};
use tokio::sync::{RwLock, broadcast, mpsc};
use tokio_stream::wrappers::ReceiverStream;
use std::sync::Arc;
use crate::proto::proxy::HealthStatus;
use tracing::{info, error};

use crate::proto::process::process_control_server::ProcessControl;
use crate::proto::process::*;
use crate::proto::proxy::ProxyStatus;
use crate::proxy::EmbeddedListener;
use crate::rules::RuleEngine;
use crate::geoip::GeoIPService;
use crate::stats::StatsService;
use crate::approval::ApprovalManager;
use crate::proto::common::{ActionType, MockPreset};

pub struct NitellaProcessServer {
    rule_engine: Arc<RwLock<RuleEngine>>,
    geoip: Arc<GeoIPService>,
    stats: Arc<StatsService>,
    
    proxy_listener: Arc<RwLock<Option<Arc<EmbeddedListener>>>>,
    shutdown_tx: broadcast::Sender<()>,
    event_tx: broadcast::Sender<Event>,
}

impl NitellaProcessServer {
    pub fn new(
        rule_engine: Arc<RwLock<RuleEngine>>, 
        geoip: Arc<GeoIPService>,
        stats: Arc<StatsService>,
        event_tx: broadcast::Sender<Event>
    ) -> Self {
        let (shutdown_tx, _) = broadcast::channel(1);
        
        Self {
            rule_engine,
            geoip,
            stats,
            proxy_listener: Arc::new(RwLock::new(None)),
            shutdown_tx,
            event_tx,
        }
    }
}

#[tonic::async_trait]
impl ProcessControl for NitellaProcessServer {
    async fn start_listener(&self, request: Request<StartListenerRequest>) -> Result<Response<StartListenerResponse>, Status> {
        let req = request.into_inner();
        info!("Starting listener '{}' on {}", req.name, req.listen_addr);

        let mut lock = self.proxy_listener.write().await;
        if lock.is_some() {
            return Ok(Response::new(StartListenerResponse {
                success: false,
                error_message: "Listener already running".to_string(),
            }));
        }

        let backend = req.default_backend;
        let listener = Arc::new(EmbeddedListener::new(
            req.id,
            req.name,
            req.listen_addr,

            backend,
            self.geoip.clone(),
            self.rule_engine.clone(), // local
            Arc::new(RwLock::new(RuleEngine::new(vec![]))), // global (empty in child)
            self.stats.clone(),
            Arc::new(ApprovalManager::new()),
            Arc::new(std::sync::atomic::AtomicI32::new(HealthStatus::Unknown as i32)),
            req.default_action,
            req.default_mock.map(|m| m.preset).unwrap_or(0),
            req.fallback_action,
            req.fallback_mock,
        ));

        let listener_clone = listener.clone();
        let mut rx = self.shutdown_tx.subscribe();
        
        tokio::spawn(async move {
            tokio::select! {
                res = listener_clone.run() => {
                    if let Err(e) = res {
                        error!("Listener failed: {}", e);
                    }
                }
                _ = rx.recv() => {
                    info!("Listener shutting down signal received");
                }
            }
        });

        *lock = Some(listener);

        Ok(Response::new(StartListenerResponse {
            success: true,
            error_message: "".to_string(),
        }))
    }

    async fn stop_listener(&self, _request: Request<StopListenerRequest>) -> Result<Response<StopListenerResponse>, Status> {
        info!("Stopping listener");
        let mut lock = self.proxy_listener.write().await;
        if lock.is_some() {
            let _ = self.shutdown_tx.send(());
            *lock = None;
        }
        Ok(Response::new(StopListenerResponse { success: true }))
    }

    async fn get_metrics(&self, _request: Request<GetMetricsRequest>) -> Result<Response<GetMetricsResponse>, Status> {
        let (active, total, b_in, b_out) = self.stats.get_summary(None);
        
        let lock = self.proxy_listener.read().await;
        let running = lock.is_some();
        let listen_addr = if let Some(l) = lock.as_ref() {
            l.get_bound_addr().await
        } else {
            "".to_string()
        };

        Ok(Response::new(GetMetricsResponse {
            status: Some(ProxyStatus {
                running,
                active_connections: active,
                total_connections: total,
                bytes_in: b_in,
                bytes_out: b_out,
                listen_addr,
                ..Default::default()
            }),
        }))
    }

    async fn add_rule(&self, request: Request<AddRuleRequest>) -> Result<Response<AddRuleResponse>, Status> {
        let req = request.into_inner();
        if let Some(rule) = req.rule {
            let mut engine = self.rule_engine.write().await;
            let mut current = engine.get_rules();
            current.retain(|r| r.id != rule.id);
            current.push(rule);
            engine.update_rules(current);
        }
        Ok(Response::new(AddRuleResponse { success: true, error_message: "".to_string() }))
    }

    async fn remove_rule(&self, request: Request<RemoveRuleRequest>) -> Result<Response<RemoveRuleResponse>, Status> {
        let req = request.into_inner();
        let mut engine = self.rule_engine.write().await;
        let mut current = engine.get_rules();
        current.retain(|r| r.id != req.rule_id);
        engine.update_rules(current);
        Ok(Response::new(RemoveRuleResponse { success: true }))
    }

    async fn list_rules(&self, _request: Request<ListRulesRequest>) -> Result<Response<ListRulesResponse>, Status> {
        let engine = self.rule_engine.read().await;
        Ok(Response::new(ListRulesResponse { rules: engine.get_rules() }))
    }

    async fn get_active_connections(&self, _request: Request<GetActiveConnectionsRequest>) -> Result<Response<GetActiveConnectionsResponse>, Status> {
        let conns = self.stats.get_active_connections(None);
        Ok(Response::new(GetActiveConnectionsResponse { connections: conns }))
    }

    async fn close_connection(&self, request: Request<CloseConnectionRequest>) -> Result<Response<CloseConnectionResponse>, Status> {
        let req = request.into_inner();
        let lock = self.proxy_listener.read().await;
        if let Some(l) = lock.as_ref() {
            l.close_connection(&req.conn_id);
            Ok(Response::new(CloseConnectionResponse { success: true, error_message: "".to_string() }))
        } else {
            Ok(Response::new(CloseConnectionResponse { success: false, error_message: "No active listener".to_string() }))
        }
    }

    async fn close_all_connections(&self, _request: Request<CloseAllConnectionsRequest>) -> Result<Response<CloseAllConnectionsResponse>, Status> {
        let lock = self.proxy_listener.read().await;
        if let Some(l) = lock.as_ref() {
            l.close_all_connections();
            Ok(Response::new(CloseAllConnectionsResponse { success: true, error_message: "".to_string() }))
         } else {
            Ok(Response::new(CloseAllConnectionsResponse { success: false, error_message: "No active listener".to_string() }))
        }
    }

    async fn health_check(&self, _request: Request<HealthCheckRequest>) -> Result<Response<HealthCheckResponse>, Status> {
        let (active, _, _, _) = self.stats.get_summary(None);
        Ok(Response::new(HealthCheckResponse {
            status: "ok".to_string(),
            active_connections: active as i32,
        }))
    }

    type StreamEventsStream = ReceiverStream<Result<Event, Status>>;

    async fn stream_events(&self, _request: Request<StreamEventsRequest>) -> Result<Response<Self::StreamEventsStream>, Status> {
        let (tx, rx) = mpsc::channel(100);
        let mut broadcast_rx = self.event_tx.subscribe();

        tokio::spawn(async move {
            while let Ok(event) = broadcast_rx.recv().await {
                if tx.send(Ok(event)).await.is_err() {
                    break;
                }
            }
        });

        Ok(Response::new(ReceiverStream::new(rx)))
    }
}