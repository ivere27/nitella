use anyhow::{anyhow, Context, Result};
use rustls::client::danger::{HandshakeSignatureValid, ServerCertVerifier};
use rustls::pki_types::{CertificateDer, ServerName, UnixTime};
use rustls::{ClientConfig, DigitallySignedStruct, SignatureScheme};
use std::net::ToSocketAddrs;
use std::sync::Arc;
use tokio::net::TcpStream;
use tokio_rustls::{rustls, TlsConnector};
use x509_parser::prelude::*;

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
    let socket_addr = clean_addr
        .to_socket_addrs()?
        .next()
        .ok_or(anyhow!("Could not resolve address"))?;

    // Connect TCP
    let stream = TcpStream::connect(socket_addr)
        .await
        .context("Failed to connect TCP")?;

    // Prepare TLS with NoVerifier
    let config = ClientConfig::builder()
        .dangerous()
        .with_custom_certificate_verifier(Arc::new(NoVerifier))
        .with_no_client_auth();

    let connector = TlsConnector::from(Arc::new(config));

    // Domain name extraction (simplified)
    let domain_str = clean_addr.split(':').next().unwrap_or("localhost");
    let domain = ServerName::try_from(domain_str.to_string())
        .unwrap_or(ServerName::try_from("localhost".to_string()).unwrap());

    // Connect TLS
    let tls_stream = connector
        .connect(domain, stream)
        .await
        .context("Failed to connect TLS")?;

    // Get peer certificates
    let (_, session) = tls_stream.get_ref();
    let peer_certs = session
        .peer_certificates()
        .ok_or(anyhow!("No certificates presented"))?;

    if peer_certs.is_empty() {
        return Err(anyhow!("Empty certificate chain"));
    }

    // Find CA (last cert or the only one, handling self-signed leaf)
    let ca_cert = select_ca_cert(peer_certs)?;

    // Convert to PEM
    let pem = ::pem::encode(&::pem::Pem::new("CERTIFICATE", ca_cert.to_vec()));

    // Compute fingerprint and emoji
    let (fingerprint, emoji_hash) = crate::crypto::compute_spki_fingerprint_and_emoji(&ca_cert)?;
    let (subject, expires) = cert_subject_and_expiry(ca_cert)?;

    Ok(HubCAInfo {
        ca_pem: pem.into_bytes(),
        fingerprint,
        emoji_hash,
        subject,
        expires,
    })
}

fn cert_subject_and_expiry(cert_der: &[u8]) -> Result<(String, String)> {
    let (_, cert) =
        X509Certificate::from_der(cert_der).map_err(|e| anyhow!("Failed to parse X509: {}", e))?;
    let subject = cert
        .subject()
        .iter_common_name()
        .next()
        .and_then(|cn| cn.as_str().ok())
        .unwrap_or("")
        .to_string();
    let expires =
        chrono::DateTime::<chrono::Utc>::from_timestamp(cert.validity().not_after.timestamp(), 0)
            .ok_or_else(|| anyhow!("Invalid certificate expiration"))?
            .format("%Y-%m-%d")
            .to_string();

    Ok((subject, expires))
}

fn select_ca_cert<'a>(peer_certs: &'a [CertificateDer<'_>]) -> Result<&'a [u8]> {
    for cert in peer_certs.iter().rev() {
        if let Ok((_, parsed)) = X509Certificate::from_der(cert.as_ref()) {
            if parsed.tbs_certificate.is_ca() {
                return Ok(cert.as_ref());
            }
        }
    }

    peer_certs
        .last()
        .map(|cert| cert.as_ref())
        .ok_or_else(|| anyhow!("Empty certificate chain"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn cert_subject_and_expiry_matches_go_format() {
        let mut params = rcgen::CertificateParams::new(vec!["hub.local".to_string()]);
        params.distinguished_name = rcgen::DistinguishedName::new();
        params
            .distinguished_name
            .push(rcgen::DnType::CommonName, "hub.local");
        params.not_after = rcgen::date_time_ymd(2032, 5, 17);
        let cert = rcgen::Certificate::from_params(params).unwrap();
        let der = cert.serialize_der().unwrap();

        let (subject, expires) = cert_subject_and_expiry(&der).unwrap();

        assert_eq!(subject, "hub.local");
        assert_eq!(expires, "2032-05-17");
    }

    #[test]
    fn select_ca_cert_matches_go_chain_selection() {
        let mut ca_params = rcgen::CertificateParams::new(vec!["hub-ca.local".to_string()]);
        ca_params.is_ca = rcgen::IsCa::Ca(rcgen::BasicConstraints::Constrained(0));
        let ca_cert = rcgen::Certificate::from_params(ca_params).unwrap();
        let ca_der = ca_cert.serialize_der().unwrap();

        let leaf_cert = rcgen::Certificate::from_params(rcgen::CertificateParams::new(vec![
            "leaf.local".to_string(),
        ]))
        .unwrap();
        let leaf_der = leaf_cert.serialize_der().unwrap();

        let trailing_leaf = rcgen::Certificate::from_params(rcgen::CertificateParams::new(vec![
            "trailing-leaf.local".to_string(),
        ]))
        .unwrap();
        let trailing_leaf_der = trailing_leaf.serialize_der().unwrap();

        let chain = vec![
            CertificateDer::from(leaf_der),
            CertificateDer::from(ca_der.clone()),
            CertificateDer::from(trailing_leaf_der),
        ];

        let selected = select_ca_cert(&chain).unwrap();

        assert_eq!(selected, ca_der.as_slice());
    }
}
