use aes_gcm::{Aes256Gcm, KeyInit, aead::Aead, Nonce};
use sha2::{Sha256, Sha512, Digest};
use hkdf::Hkdf;
use x25519_dalek::{PublicKey as X25519PublicKey, StaticSecret};
use ed25519_dalek::{VerifyingKey, SigningKey, Signer};
use anyhow::{Result, anyhow};
use rand::{RngCore, thread_rng};
use crate::proto::common::{EncryptedPayload, CryptoAlgorithm};
use hex;
use x509_parser::prelude::*;

const EMOJIS: &[&str] = &[
	"🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼",
	"🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔",
	"🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺",
	"🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞",
	"🐜", "🦟", "🦗", "🕷", "🦂", "🐢", "🐍", "🦎",
	"🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡",
	"🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊", "🐅",
	"🐆", "🦓", "🦍", "🦧", "🐘", "🦛", "🦏", "🐪",
];

// Reconstruct standard ASN.1 SPKI header for Ed25519 (OID 1.3.101.112)
// SEQUENCE { SEQUENCE { OID 1.3.101.112 } BIT STRING { key } }
const ED25519_SPKI_PREFIX: &[u8] = &[
    0x30, 0x2a, // SEQUENCE, 42 bytes
    0x30, 0x05, // SEQUENCE, 5 bytes
    0x06, 0x03, // OID, 3 bytes
    0x2b, 0x65, 0x70, // 1.3.101.112
    0x03, 0x21, // BIT STRING, 33 bytes
    0x00        // Unused bits
];

pub fn compute_spki_fingerprint_and_emoji(cert_der: &[u8]) -> Result<(String, String)> {
    let (_, x509) = X509Certificate::from_der(cert_der).map_err(|e| anyhow!("Failed to parse X509: {}", e))?;
    
    // Check if Ed25519
    let oid = x509.tbs_certificate.subject_pki.algorithm.algorithm.to_string();
    let is_ed25519 = oid == "1.3.101.112";

    let spki_bytes = if is_ed25519 {
        // Construct SPKI from raw key bytes
        let key_bits = &x509.tbs_certificate.subject_pki.subject_public_key;
        let key_bytes = key_bits.data.as_ref();
        
        if key_bytes.len() == 32 {
            let mut buf = Vec::with_capacity(ED25519_SPKI_PREFIX.len() + key_bytes.len());
            buf.extend_from_slice(ED25519_SPKI_PREFIX);
            buf.extend_from_slice(key_bytes);
            buf
        } else {
             // Fallback to cert hash if key length mismatch
             // This shouldn't happen for valid Ed25519 certs
             return Ok((
                 hex::encode(Sha256::digest(cert_der)),
                 hash_to_emojis(&Sha256::digest(cert_der))
             ));
        }
    } else {
        // For non-Ed25519, we don't have easy SPKI reconstruction in this simplified logic.
        // Fallback to Cert Hash (Fingerprint of the whole cert).
        // User will have to live with mismatch if using RSA, or verify against Cert Trace.
        // But Nitella implies Ed25519 mostly.
        return Ok((
             hex::encode(Sha256::digest(cert_der)),
             hash_to_emojis(&Sha256::digest(cert_der))
         ));
    };

    let hash = Sha256::digest(&spki_bytes);
    let hex_fingerprint = hex::encode(hash);
    let emoji = hash_to_emojis(&hash);
    
    Ok((hex_fingerprint, emoji))
}

fn hash_to_emojis(hash: &[u8]) -> String {
    if hash.len() < 4 {
        return "❓ ❓ ❓ ❓".to_string();
    }
    let mut parts = Vec::new();
    for i in 0..4 {
        let idx = (hash[i] as usize) % EMOJIS.len();
        parts.push(EMOJIS[idx].to_string());
    }
    parts.join(" ")
}

pub fn decrypt(
    payload: &EncryptedPayload,
    recipient_priv_key: &SigningKey,
) -> Result<Vec<u8>> {
    // 1. Convert Ed25519 Priv Key (Seed) to X25519 StaticSecret
    let x25519_priv = ed25519_priv_to_x25519(recipient_priv_key);

    // 2. Parse Ephemeral Pub Key
    if payload.ephemeral_pubkey.len() != 32 {
        return Err(anyhow!("Invalid ephemeral public key length"));
    }
    let mut eph_bytes = [0u8; 32];
    eph_bytes.copy_from_slice(&payload.ephemeral_pubkey);
    let ephemeral_pub = X25519PublicKey::from(eph_bytes);

    // 3. Compute Shared Secret
    let shared_secret = x25519_priv.diffie_hellman(&ephemeral_pub);

    // 4. Derive AES Key using HKDF
    // We need our own X25519 Public Key for the info string
    let recipient_pub_ed = recipient_priv_key.verifying_key();
    let recipient_pub_x = ed25519_pub_to_x25519(&recipient_pub_ed)?;
    
    let aes_key = derive_key(shared_secret.as_bytes(), ephemeral_pub.as_bytes(), recipient_pub_x.as_bytes())?;

    // 5. Decrypt
    if payload.nonce.len() != 12 {
        return Err(anyhow!("Invalid nonce length"));
    }
    let nonce = Nonce::from_slice(&payload.nonce);
    let cipher = Aes256Gcm::new_from_slice(&aes_key).map_err(|e| anyhow!(e))?;

    // AAD is Ephemeral Public Key (binds ciphertext to key exchange)
    let aad = payload.ephemeral_pubkey.as_slice();
    let payload_cipher = aes_gcm::aead::Payload {
        msg: &payload.ciphertext,
        aad,
    };

    let plaintext = cipher.decrypt(nonce, payload_cipher)
        .map_err(|e| anyhow!("Decryption failed: {}", e))?;

    Ok(plaintext)
}

pub fn encrypt(
    plaintext: &[u8],
    recipient_pub_key: &VerifyingKey,
    sender_priv_key: &SigningKey,
    sender_fingerprint: &str,
) -> Result<EncryptedPayload> {
    // 1. Convert Recipient Ed25519 Pub to X25519 Pub
    let recipient_pub_x = ed25519_pub_to_x25519(recipient_pub_key)?;

    // 2. Generate Ephemeral X25519 Keypair
    let ephemeral_priv = StaticSecret::random_from_rng(thread_rng());
    let ephemeral_pub = X25519PublicKey::from(&ephemeral_priv);

    // 3. Compute Shared Secret
    let shared_secret = ephemeral_priv.diffie_hellman(&recipient_pub_x);

    // 4. Derive AES Key
    let aes_key = derive_key(shared_secret.as_bytes(), ephemeral_pub.as_bytes(), recipient_pub_x.as_bytes())?;

    // 5. Encrypt
    let mut nonce_bytes = [0u8; 12];
    thread_rng().fill_bytes(&mut nonce_bytes);
    let nonce = Nonce::from_slice(&nonce_bytes);
    
    let cipher = Aes256Gcm::new_from_slice(&aes_key).map_err(|e| anyhow!(e))?;
    
    // AAD is Ephemeral Public Key
    let aad = ephemeral_pub.as_bytes();
    let payload_cipher = aes_gcm::aead::Payload {
        msg: plaintext,
        aad,
    };

    let ciphertext = cipher.encrypt(nonce, payload_cipher)
        .map_err(|e| anyhow!("Encryption failed: {}", e))?;

    // 6. Sign: EphemeralPubKey + Nonce + Ciphertext
    let mut sig_input = Vec::new();
    sig_input.extend_from_slice(ephemeral_pub.as_bytes());
    sig_input.extend_from_slice(&nonce_bytes);
    sig_input.extend_from_slice(&ciphertext);

    let signature = sender_priv_key.sign(&sig_input);

    Ok(EncryptedPayload {
        ephemeral_pubkey: ephemeral_pub.as_bytes().to_vec(),
        nonce: nonce_bytes.to_vec(),
        ciphertext,
        sender_fingerprint: sender_fingerprint.to_string(),
        signature: signature.to_vec(),
        algorithm: CryptoAlgorithm::AlgoEd25519 as i32,
    })
}

/// Verify the Ed25519 signature on an EncryptedPayload.
/// Matches Go's nitellacrypto.VerifySignature().
pub fn verify_signature(
    payload: &EncryptedPayload,
    sender_pub_key: &VerifyingKey,
) -> Result<()> {
    use ed25519_dalek::Verifier;
    if payload.signature.is_empty() {
        return Err(anyhow!("payload is not signed"));
    }

    // Reconstruct signed data: EphemeralPubKey || Nonce || Ciphertext
    let mut sig_input = Vec::new();
    sig_input.extend_from_slice(&payload.ephemeral_pubkey);
    sig_input.extend_from_slice(&payload.nonce);
    sig_input.extend_from_slice(&payload.ciphertext);

    let sig_bytes: [u8; 64] = payload.signature.as_slice()
        .try_into()
        .map_err(|_| anyhow!("Invalid signature length: {}", payload.signature.len()))?;
    let signature = ed25519_dalek::Signature::from_bytes(&sig_bytes);

    sender_pub_key.verify(&sig_input, &signature)
        .map_err(|e| anyhow!("Signature verification failed: {}", e))
}

// HKDF-SHA256 Key Derivation
fn derive_key(shared_secret: &[u8], ephemeral_pub: &[u8], recipient_pub: &[u8]) -> Result<Vec<u8>> {
    let mut info = Vec::new();
    info.extend_from_slice(b"nitella-x25519-aes256-gcm");
    info.extend_from_slice(ephemeral_pub);
    info.extend_from_slice(recipient_pub);

    let hkdf = Hkdf::<Sha256>::new(None, shared_secret);
    let mut okm = [0u8; 32];
    hkdf.expand(&info, &mut okm).map_err(|_| anyhow!("HKDF failed"))?;
    Ok(okm.to_vec())
}

// Convert Ed25519 SigningKey (Seed) to X25519 StaticSecret
// Logic: SHA512(seed) -> clamp -> StaticSecret
fn ed25519_priv_to_x25519(ed_key: &SigningKey) -> StaticSecret {
    let seed = ed_key.as_bytes();
    let mut hasher = Sha512::new();
    hasher.update(seed);
    let hash = hasher.finalize();

    let mut clamped = [0u8; 32];
    clamped.copy_from_slice(&hash[0..32]);
    
    clamped[0] &= 248;
    clamped[31] &= 127;
    clamped[31] |= 64;

    StaticSecret::from(clamped)
}

// Convert Ed25519 VerifyingKey to X25519 PublicKey
// ed25519-dalek 2.0 has built-in `to_montgomery()` for this
fn ed25519_pub_to_x25519(ed_key: &VerifyingKey) -> Result<X25519PublicKey> {
    Ok(X25519PublicKey::from(ed_key.to_montgomery().to_bytes()))
}
