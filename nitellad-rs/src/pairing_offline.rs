use crate::cert_utils;
use anyhow::Result;
use hyper::service::{make_service_fn, service_fn};
use hyper::{Body, Request, Response, Server};
use qrcodegen::{QrCode, QrCodeEcc};
use std::convert::Infallible;
use std::net::SocketAddr;
use std::path::Path;
use std::sync::{Arc, Mutex};
use tokio::fs;
use tokio::sync::oneshot;

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

    pub async fn run(&self, port: Option<u16>) -> Result<()> {
        fs::create_dir_all(&self.data_dir).await?;

        // 1. Generate Identity
        println!("Generating Identity...");
        let (key_pem, key_pair) = cert_utils::generate_node_key()?;
        let csr_pem = cert_utils::generate_csr(key_pair, &self.node_name)?;

        fs::write(Path::new(&self.data_dir).join("node.key"), &key_pem).await?;

        // 2. Generate QR Code Payload
        // Format: JSON { "type": "csr", "csr": "..." }
        let payload = serde_json::json!({
            "type": "csr",
            "node_id": self.node_name,
            "csr": csr_pem
        });
        let payload_str = serde_json::to_string(&payload)?;

        if let Some(p) = port {
            self.run_web(p, &payload_str, &csr_pem).await
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

    async fn run_web(&self, port: u16, payload_str: &str, csr_pem: &str) -> Result<()> {
        self.print_qr(payload_str);
        println!(
            "
Or copy this JSON:
{}",
            payload_str
        );

        // 3. Start Web Server
        let addr = SocketAddr::from(([0, 0, 0, 0], port));
        println!(
            "
Starting Pairing Web UI at http://{}",
            addr
        );

        let (tx, rx) = oneshot::channel::<String>(); // Channel to receive cert from web handler
        let tx = Arc::new(Mutex::new(Some(tx)));

        let make_svc = make_service_fn(move |_conn| {
            let tx = tx.clone();
            let csr_clone = csr_pem.to_string();
            async move {
                Ok::<_, Infallible>(service_fn(move |req: Request<Body>| {
                    let tx = tx.clone();
                    let csr_clone = csr_clone.clone();
                    handle_request(req, tx, csr_clone)
                }))
            }
        });

        let server = Server::bind(&addr).serve(make_svc);

        // Race server and completion channel
        tokio::select! {
            _ = server => {},
            Ok(cert_json) = rx => {
                // Process received cert
                self.save_cert(&cert_json).await?;
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
        let data: serde_json::Value = serde_json::from_str(json_str)?;
        if let Some(cert) = data.get("cert").and_then(|v| v.as_str()) {
            fs::write(Path::new(&self.data_dir).join("node.crt"), cert).await?;
            println!("Certificate saved!");
        }
        if let Some(ca) = data.get("ca_cert").and_then(|v| v.as_str()) {
            fs::write(Path::new(&self.data_dir).join("cli_ca.crt"), ca).await?;
        }
        Ok(())
    }
}

async fn handle_request(
    req: Request<Body>,
    tx: Arc<Mutex<Option<oneshot::Sender<String>>>>,
    csr: String,
) -> Result<Response<Body>, Infallible> {
    if req.method() == hyper::Method::POST && req.uri().path() == "/submit" {
        let full_body = hyper::body::to_bytes(req.into_body()).await.unwrap();
        let body_str = String::from_utf8(full_body.to_vec()).unwrap();

        if let Ok(mut lock) = tx.lock() {
            if let Some(sender) = lock.take() {
                let _ = sender.send(body_str);
            }
        }
        return Ok(Response::new(Body::from(
            "Pairing Complete. You can close this window.",
        )));
    }

    // Serve simple UI
    let html = format!(
        r#"
    <html><body>
    <h1>Nitella Pairing</h1>
    <p>Scan this QR with Mobile App or CLI</p>
    <pre>{}</pre>
    <form action="/submit" method="post">
        <textarea name="response" placeholder="Paste response JSON here"></textarea>
        <button type="submit">Submit</button>
    </form>
    </body></html>
    "#,
        csr
    ); // Simplified UI, real one would show QR image

    Ok(Response::new(Body::from(html)))
}
