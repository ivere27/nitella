use anyhow::Result;
use std::path::Path;
use tokio::fs;

pub async fn ensure_admin_certs(data_dir: &str) -> Result<(String, String)> {
    let cert_path = Path::new(data_dir).join("admin.crt");
    let key_path = Path::new(data_dir).join("admin.key");
    let ca_path = Path::new(data_dir).join("admin_ca.crt");

    fs::create_dir_all(data_dir).await?;

    if cert_path.exists() && key_path.exists() {
        return Ok((
            cert_path.to_string_lossy().to_string(),
            key_path.to_string_lossy().to_string(),
        ));
    }

    // Generate CA
    let mut ca_params = rcgen::CertificateParams::new(vec!["Nitella Admin CA".to_string()]);
    ca_params.alg = &rcgen::PKCS_ED25519;
    ca_params.is_ca = rcgen::IsCa::Ca(rcgen::BasicConstraints::Constrained(0));
    let ca_cert = rcgen::Certificate::from_params(ca_params)?;
    let ca_pem = ca_cert.serialize_pem()?;

    let ca_key_path = Path::new(data_dir).join("admin_ca.key");

    fs::write(&ca_path, &ca_pem).await?;
    fs::write(&ca_key_path, ca_cert.serialize_private_key_pem()).await?;

    // Generate Server Cert
    let mut server_params = rcgen::CertificateParams::new(vec!["localhost".to_string(), "127.0.0.1".to_string()]);
    server_params.alg = &rcgen::PKCS_ED25519;
    let server_cert = rcgen::Certificate::from_params(server_params)?;
    let server_cert_pem = server_cert.serialize_pem_with_signer(&ca_cert)?;
    let server_key_pem = server_cert.serialize_private_key_pem();

    fs::write(&cert_path, &server_cert_pem).await?;
    fs::write(&key_path, &server_key_pem).await?;

    Ok((
        cert_path.to_string_lossy().to_string(),
        key_path.to_string_lossy().to_string(),
    ))
}
