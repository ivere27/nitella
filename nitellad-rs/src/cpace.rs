use aes_gcm::{aead::Aead, Aes256Gcm, KeyInit, Nonce};
use anyhow::{bail, Context, Result};
use hkdf::Hkdf;
use rand::RngCore;
use sha2::{Digest, Sha256};
use x25519_dalek::{PublicKey, StaticSecret};

pub const ROLE_CLI: &str = "cli";
pub const ROLE_NODE: &str = "node";

pub struct CPaceSession {
    role: String,
    session_id: Vec<u8>,
    my_secret: StaticSecret,
    my_public: PublicKey,
    peer_public: Option<PublicKey>,
    shared_key: Option<Vec<u8>>,
}

impl CPaceSession {
    pub fn new(role: &str, password: &[u8], session_id_opt: Option<&[u8]>) -> Result<Self> {
        if role != ROLE_CLI && role != ROLE_NODE {
            bail!("Invalid role");
        }

        // Derive session ID if not provided
        let session_id = match session_id_opt {
            Some(id) => id.to_vec(),
            None => {
                let mut hasher = Sha256::new();
                hasher.update(b"cpace-session-id:");
                hasher.update(password);
                let result = hasher.finalize();
                result[..16].to_vec()
            }
        };

        // Derive Generator G'
        let generator_point = derive_generator(password, &session_id);

        // Generate random scalar (my_secret)
        let mut rng = rand::thread_rng();
        let my_secret = StaticSecret::random_from_rng(&mut rng);

        // Compute Public Value Y = my_secret * G'
        // In x25519-dalek, diffie_hellman(secret, point) = secret * point
        let my_public = my_secret.diffie_hellman(&generator_point);
        let my_public_point = PublicKey::from(my_public.to_bytes());

        Ok(Self {
            role: role.to_string(),
            session_id,
            my_secret,
            my_public: my_public_point,
            peer_public: None,
            shared_key: None,
        })
    }

    pub fn get_public_value(&self) -> [u8; 32] {
        *self.my_public.as_bytes()
    }

    pub fn set_peer_public(&mut self, peer_bytes: &[u8]) -> Result<()> {
        if peer_bytes.len() != 32 {
            bail!("Invalid peer public length");
        }
        let mut arr = [0u8; 32];
        arr.copy_from_slice(peer_bytes);
        let peer_public = PublicKey::from(arr);

        // Check for identity/low order? x25519-dalek handles some checks, but RFC 7748 allows all 32-byte strings.
        // Go implementation checks for all-zero.
        if peer_bytes.iter().all(|&b| b == 0) {
            bail!("Invalid peer public: identity point");
        }

        // Compute K = my_secret * peer_public
        let k = self.my_secret.diffie_hellman(&peer_public);

        // Derive Session Key
        let key = self.derive_session_key(k.as_bytes(), &peer_public);
        self.peer_public = Some(peer_public);
        self.shared_key = Some(key);

        Ok(())
    }

    fn derive_session_key(&self, shared_secret: &[u8], peer_public: &PublicKey) -> Vec<u8> {
        // Transcript: (CLI_Pub || Node_Pub || SessionID)
        let mut transcript = Vec::new();
        if self.role == ROLE_CLI {
            transcript.extend_from_slice(self.my_public.as_bytes());
            transcript.extend_from_slice(peer_public.as_bytes());
        } else {
            transcript.extend_from_slice(peer_public.as_bytes());
            transcript.extend_from_slice(self.my_public.as_bytes());
        }
        transcript.extend_from_slice(&self.session_id);

        // Match Go: hkdf.New(sha256.New, sharedSecret, nil, transcript)
        // = HKDF(IKM=sharedSecret, salt=nil, info=transcript)
        let hkdf = Hkdf::<Sha256>::new(None, shared_secret);
        let mut okm = [0u8; 32];
        hkdf.expand(&transcript, &mut okm)
            .expect("HKDF expand failed");
        okm.to_vec()
    }

    pub fn derive_confirmation_emoji(&self) -> String {
        let shared_key = match &self.shared_key {
            Some(k) => k,
            None => return String::new(),
        };

        let hash = Sha256::digest(shared_key);

        // Must match Go's cpace.go emoji list exactly
        const EMOJIS: &[&str] = &[
            "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸",
            "🐵", "🐔", "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝",
            "🐛", "🦋", "🐌", "🐞", "🌸", "🌺", "🌻", "🌹", "🌷", "🌼", "🌿", "🍀", "🍎", "🍊",
            "🍋", "🍇", "🍓", "🍒", "🍑", "🥝", "🌙", "⭐", "🌟", "✨", "⚡", "🔥", "🌈", "☀️",
            "🎸", "🎹", "🎺", "🎷", "🥁", "🎻", "🎤", "🎧",
        ];

        let mut result = String::new();
        for i in 0..4 {
            let idx = (hash[i * 2] as usize) % EMOJIS.len();
            result.push_str(EMOJIS[idx]);
        }
        result
    }

    pub fn encrypt(&self, plaintext: &[u8]) -> Result<(Vec<u8>, Vec<u8>)> {
        let key_bytes = self.shared_key.as_ref().context("Handshake not complete")?;
        let key = aes_gcm::Key::<Aes256Gcm>::from_slice(key_bytes);
        let cipher = Aes256Gcm::new(key);

        let mut nonce_bytes = [0u8; 12];
        rand::thread_rng().fill_bytes(&mut nonce_bytes);
        let nonce = Nonce::from_slice(&nonce_bytes);

        let ciphertext = cipher
            .encrypt(nonce, plaintext)
            .map_err(|e| anyhow::anyhow!("Encryption failed: {}", e))?;
        Ok((ciphertext, nonce_bytes.to_vec()))
    }

    pub fn decrypt(&self, ciphertext: &[u8], nonce_bytes: &[u8]) -> Result<Vec<u8>> {
        let key_bytes = self.shared_key.as_ref().context("Handshake not complete")?;
        let key = aes_gcm::Key::<Aes256Gcm>::from_slice(key_bytes);
        let cipher = Aes256Gcm::new(key);
        let nonce = Nonce::from_slice(nonce_bytes);

        let plaintext = cipher
            .decrypt(nonce, ciphertext)
            .map_err(|e| anyhow::anyhow!("Decryption failed: {}", e))?;
        Ok(plaintext)
    }
}

fn derive_generator(password: &[u8], session_id: &[u8]) -> PublicKey {
    // H(password || sessionID || context)
    let mut hasher = Sha256::new();
    hasher.update(b"cpace-v1-curve25519");
    hasher.update(password);
    hasher.update(session_id);
    let digest = hasher.finalize();

    // In x25519, we don't have a direct "scalar * basepoint" where basepoint is arbitrary point in PublicKey form?
    // Wait, standard X25519 is "Scalar * Basepoint(9)".
    // To implement "Scalar * G'", we treat G' as a "Public Key" (Point) and Scalar as "Private Key".
    //
    // Go logic:
    // clamp(digest) -> scalar
    // G' = scalar * Basepoint

    let mut scalar_bytes = [0u8; 32];
    scalar_bytes.copy_from_slice(&digest);
    // Clamp
    scalar_bytes[0] &= 248;
    scalar_bytes[31] &= 127;
    scalar_bytes[31] |= 64;

    let secret = StaticSecret::from(scalar_bytes);
    let public = PublicKey::from(&secret);
    public
}
