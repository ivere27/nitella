use anyhow::Result;
use std::path::Path;
use tokio::fs;

pub async fn ensure_admin_certs(data_dir: &str) -> Result<(String, String)> {
    // Match Go nitellad's on-disk admin TLS contract. Older Rust builds used
    // admin.crt/admin.key; migrate those filenames forward without touching CA
    // material so existing clients can keep trusting admin_ca.crt.
    let cert_path = Path::new(data_dir).join("admin_server.crt");
    let key_path = Path::new(data_dir).join("admin_server.key");
    let ca_path = Path::new(data_dir).join("admin_ca.crt");
    let ca_key_path = Path::new(data_dir).join("admin_ca.key");

    fs::create_dir_all(data_dir).await?;

    if cert_path.exists() && key_path.exists() {
        return Ok((
            cert_path.to_string_lossy().to_string(),
            key_path.to_string_lossy().to_string(),
        ));
    }

    let legacy_cert_path = Path::new(data_dir).join("admin.crt");
    let legacy_key_path = Path::new(data_dir).join("admin.key");
    if legacy_cert_path.exists() && legacy_key_path.exists() {
        fs::copy(&legacy_cert_path, &cert_path).await?;
        fs::copy(&legacy_key_path, &key_path).await?;
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
    let ca_key_pem = ca_cert.serialize_private_key_pem();

    write_with_mode(&ca_path, ca_pem.as_bytes(), 0o644).await?;
    write_with_mode(&ca_key_path, ca_key_pem.as_bytes(), 0o600).await?;

    // Generate Server Cert
    let mut server_params =
        rcgen::CertificateParams::new(vec!["localhost".to_string(), "127.0.0.1".to_string()]);
    server_params.alg = &rcgen::PKCS_ED25519;
    let server_cert = rcgen::Certificate::from_params(server_params)?;
    let server_cert_pem = server_cert.serialize_pem_with_signer(&ca_cert)?;
    let server_key_pem = server_cert.serialize_private_key_pem();

    write_with_mode(&cert_path, server_cert_pem.as_bytes(), 0o644).await?;
    write_with_mode(&key_path, server_key_pem.as_bytes(), 0o600).await?;

    Ok((
        cert_path.to_string_lossy().to_string(),
        key_path.to_string_lossy().to_string(),
    ))
}

async fn write_with_mode(path: &Path, contents: &[u8], mode: u32) -> Result<()> {
    fs::write(path, contents).await?;
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

#[cfg(test)]
mod tests {
    use super::*;

    fn unique_temp_dir(name: &str) -> std::path::PathBuf {
        std::env::temp_dir().join(format!("nitellad-rs-{name}-{}", uuid::Uuid::new_v4()))
    }

    #[tokio::test]
    async fn ensure_admin_certs_uses_go_compatible_filenames() {
        let dir = unique_temp_dir("admin-certs");
        let (cert, key) = ensure_admin_certs(dir.to_str().unwrap()).await.unwrap();

        assert!(cert.ends_with("admin_server.crt"));
        assert!(key.ends_with("admin_server.key"));
        assert!(dir.join("admin_server.crt").exists());
        assert!(dir.join("admin_server.key").exists());
        assert!(dir.join("admin_ca.crt").exists());
        assert!(dir.join("admin_ca.key").exists());
        assert!(!dir.join("admin.crt").exists());
        assert!(!dir.join("admin.key").exists());

        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let ca_key_mode = fs::metadata(dir.join("admin_ca.key"))
                .await
                .unwrap()
                .permissions()
                .mode()
                & 0o777;
            let server_key_mode = fs::metadata(dir.join("admin_server.key"))
                .await
                .unwrap()
                .permissions()
                .mode()
                & 0o777;
            assert_eq!(ca_key_mode, 0o600);
            assert_eq!(server_key_mode, 0o600);
        }

        let _ = fs::remove_dir_all(dir).await;
    }

    #[tokio::test]
    async fn ensure_admin_certs_migrates_legacy_rust_filenames() {
        let dir = unique_temp_dir("admin-certs-legacy");
        fs::create_dir_all(&dir).await.unwrap();
        fs::write(dir.join("admin.crt"), "legacy-cert")
            .await
            .unwrap();
        fs::write(dir.join("admin.key"), "legacy-key")
            .await
            .unwrap();

        let (cert, key) = ensure_admin_certs(dir.to_str().unwrap()).await.unwrap();

        assert!(cert.ends_with("admin_server.crt"));
        assert!(key.ends_with("admin_server.key"));
        assert_eq!(
            fs::read_to_string(dir.join("admin_server.crt"))
                .await
                .unwrap(),
            "legacy-cert"
        );
        assert_eq!(
            fs::read_to_string(dir.join("admin_server.key"))
                .await
                .unwrap(),
            "legacy-key"
        );

        let _ = fs::remove_dir_all(dir).await;
    }
}
