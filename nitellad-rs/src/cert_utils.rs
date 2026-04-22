use anyhow::Result;
use rcgen::{Certificate, CertificateParams, DistinguishedName, DnType, KeyPair};
use std::path::Path;
use tokio::fs;

pub struct NodeIdentity {
    pub key_pem: String,
    pub cert_pem: String,
}

pub fn generate_node_key() -> Result<(String, KeyPair)> {
    // Generate Ed25519 keypair
    let key_pair = KeyPair::generate(&rcgen::PKCS_ED25519)?;
    let key_pem = key_pair.serialize_pem();
    Ok((key_pem, key_pair))
}

pub async fn load_or_generate_node_key(data_dir: &Path) -> Result<(String, KeyPair)> {
    fs::create_dir_all(data_dir).await?;
    let key_path = data_dir.join("node.key");

    if let Ok(existing_pem) = fs::read_to_string(&key_path).await {
        if let Ok(key_pair) = KeyPair::from_pem(&existing_pem) {
            return Ok((existing_pem, key_pair));
        }
    }

    let (key_pem, key_pair) = generate_node_key()?;
    write_private_key_pem(&key_path, &key_pem).await?;
    Ok((key_pem, key_pair))
}

pub async fn write_private_key_pem(path: &Path, pem: &str) -> Result<()> {
    fs::write(path, pem).await?;
    set_mode(path, 0o600).await?;
    Ok(())
}

pub async fn write_cert_pem(path: &Path, pem: &[u8], mode: u32) -> Result<()> {
    fs::write(path, pem).await?;
    set_mode(path, mode).await?;
    Ok(())
}

#[cfg(unix)]
async fn set_mode(path: &Path, mode: u32) -> Result<()> {
    use std::os::unix::fs::PermissionsExt;
    fs::set_permissions(path, std::fs::Permissions::from_mode(mode)).await?;
    Ok(())
}

#[cfg(not(unix))]
async fn set_mode(_path: &Path, _mode: u32) -> Result<()> {
    Ok(())
}

pub fn generate_csr(key_pair: KeyPair, node_name: &str) -> Result<String> {
    let mut params = CertificateParams::new(vec![node_name.to_string()]);
    params.alg = &rcgen::PKCS_ED25519;

    // Set Common Name
    let mut dn = DistinguishedName::new();
    dn.push(DnType::CommonName, node_name);
    params.distinguished_name = dn;
    params.key_pair = Some(key_pair);

    // Generate CSR
    let cert = Certificate::from_params(params)?;
    let csr_der = cert.serialize_request_der()?;

    let pem = pem::encode(&pem::Pem::new("CERTIFICATE REQUEST", csr_der));
    Ok(pem)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn unique_temp_dir(name: &str) -> std::path::PathBuf {
        std::env::temp_dir().join(format!("nitellad-rs-{name}-{}", uuid::Uuid::new_v4()))
    }

    #[tokio::test]
    async fn load_or_generate_node_key_reuses_existing_key() {
        let dir = unique_temp_dir("node-key-reuse");

        let (first_pem, _) = load_or_generate_node_key(&dir).await.unwrap();
        let (second_pem, _) = load_or_generate_node_key(&dir).await.unwrap();

        assert_eq!(first_pem, second_pem);

        let _ = fs::remove_dir_all(dir).await;
    }

    #[tokio::test]
    async fn load_or_generate_node_key_replaces_invalid_key() {
        let dir = unique_temp_dir("node-key-invalid");
        fs::create_dir_all(&dir).await.unwrap();
        fs::write(dir.join("node.key"), "not a key").await.unwrap();

        let (key_pem, key_pair) = load_or_generate_node_key(&dir).await.unwrap();
        assert!(key_pem.contains("BEGIN PRIVATE KEY"));
        assert!(generate_csr(key_pair, "test-node")
            .unwrap()
            .contains("BEGIN CERTIFICATE REQUEST"));

        let _ = fs::remove_dir_all(dir).await;
    }

    #[cfg(unix)]
    #[tokio::test]
    async fn load_or_generate_node_key_writes_private_permissions() {
        use std::os::unix::fs::PermissionsExt;

        let dir = unique_temp_dir("node-key-mode");
        let _ = load_or_generate_node_key(&dir).await.unwrap();

        let mode = fs::metadata(dir.join("node.key"))
            .await
            .unwrap()
            .permissions()
            .mode()
            & 0o777;
        assert_eq!(mode, 0o600);

        let _ = fs::remove_dir_all(dir).await;
    }
}
