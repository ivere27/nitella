use anyhow::{Result};
use rcgen::{CertificateParams, KeyPair, DistinguishedName, DnType, Certificate};

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
