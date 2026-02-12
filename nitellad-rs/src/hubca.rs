use std::sync::Arc;
use std::net::ToSocketAddrs;
use tokio::net::TcpStream;
use tokio_rustls::{TlsConnector, rustls};
use anyhow::{Result, Context, anyhow};
use sha2::{Sha256, Digest};
use rustls::client::danger::{ServerCertVerifier, HandshakeSignatureValid};
use rustls::pki_types::{CertificateDer, ServerName, UnixTime};
use rustls::{DigitallySignedStruct, SignatureScheme, ClientConfig};

#[derive(Debug, Clone)]
pub struct HubCAInfo {
    pub ca_pem: Vec<u8>,
    pub fingerprint: String,
    pub emoji_hash: String,
    pub subject: String,
    pub expires: String,
}

#[derive(Debug)]
struct NoVerifier;

impl ServerCertVerifier for NoVerifier {
    fn verify_server_cert(
        &self,
        _end_entity: &CertificateDer<'_>,
        _intermediates: &[CertificateDer<'_>],
        _server_name: &ServerName<'_>,
        _ocsp_response: &[u8],
        _now: UnixTime,
    ) -> Result<rustls::client::danger::ServerCertVerified, rustls::Error> {
        Ok(rustls::client::danger::ServerCertVerified::assertion())
    }

    fn verify_tls12_signature(
        &self,
        _message: &[u8],
        _cert: &CertificateDer<'_>,
        _dss: &DigitallySignedStruct,
    ) -> Result<HandshakeSignatureValid, rustls::Error> {
        Ok(HandshakeSignatureValid::assertion())
    }

    fn verify_tls13_signature(
        &self,
        _message: &[u8],
        _cert: &CertificateDer<'_>,
        _dss: &DigitallySignedStruct,
    ) -> Result<HandshakeSignatureValid, rustls::Error> {
        Ok(HandshakeSignatureValid::assertion())
    }

    fn supported_verify_schemes(&self) -> Vec<SignatureScheme> {
        vec![
            SignatureScheme::RSA_PKCS1_SHA1,
            SignatureScheme::ECDSA_SHA1_Legacy,
            SignatureScheme::RSA_PKCS1_SHA256,
            SignatureScheme::ECDSA_NISTP256_SHA256,
            SignatureScheme::RSA_PKCS1_SHA384,
            SignatureScheme::ECDSA_NISTP384_SHA384,
            SignatureScheme::RSA_PKCS1_SHA512,
            SignatureScheme::ECDSA_NISTP521_SHA512,
            SignatureScheme::RSA_PSS_SHA256,
            SignatureScheme::RSA_PSS_SHA384,
            SignatureScheme::RSA_PSS_SHA512,
            SignatureScheme::ED25519,
            SignatureScheme::ED448,
        ]
    }
}

pub async fn probe_hub_ca(hub_addr: &str) -> Result<HubCAInfo> {
    // Ensure host:port
    let addr_str = if !hub_addr.contains(":") {
        format!("{}:443", hub_addr)
    } else {
        hub_addr.to_string()
    };
    
    // Remove protocol prefix if present
    let clean_addr = addr_str.replace("http://", "").replace("https://", "");

    // Resolve DNS
    let socket_addr = clean_addr.to_socket_addrs()?.next().ok_or(anyhow!("Could not resolve address"))?;
    
    // Connect TCP
    let stream = TcpStream::connect(socket_addr).await.context("Failed to connect TCP")?;

    // Prepare TLS with NoVerifier
    let config = ClientConfig::builder()
        .dangerous()
        .with_custom_certificate_verifier(Arc::new(NoVerifier))
        .with_no_client_auth();
        
    let connector = TlsConnector::from(Arc::new(config));
    
    // Domain name extraction (simplified)
    let domain_str = clean_addr.split(':').next().unwrap_or("localhost");
    let domain = ServerName::try_from(domain_str.to_string()).unwrap_or(ServerName::try_from("localhost".to_string()).unwrap());

    // Connect TLS
    let tls_stream = connector.connect(domain, stream).await.context("Failed to connect TLS")?;
    
    // Get peer certificates
    let (_, session) = tls_stream.get_ref();
    let peer_certs = session.peer_certificates().ok_or(anyhow!("No certificates presented"))?;
    
    if peer_certs.is_empty() {
        return Err(anyhow!("Empty certificate chain"));
    }
    
    // Find CA (last cert or the only one, handling self-signed leaf)
    let ca_cert = peer_certs.last().unwrap();
    
    // Convert to PEM
    let pem = pem::encode(&pem::Pem::new("CERTIFICATE", ca_cert.to_vec()));
    
    // Compute fingerprint and emoji
    let (fingerprint, emoji_hash) = crate::crypto::compute_spki_fingerprint_and_emoji(&ca_cert)?;
    
    Ok(HubCAInfo {
        ca_pem: pem.into_bytes(),
        fingerprint,
        emoji_hash,
        subject: "".to_string(), // Parsing subject requires ASN.1 parser, skipping for minimal deps
        expires: "".to_string(), // Skipping for minimal deps
    })
}
