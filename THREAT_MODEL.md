# Threat Model: Malicious Hub Scenario

## Executive Summary

This document analyzes the security model of the Synura/Nitella system under the assumption that the **Hub is compromised or malicious**.

**Assumption:** The attacker has full control over the Hub server, including its TLS private key (e.g., a valid Let's Encrypt certificate), database, and network traffic.
**Core Defense:** The system employs a "Zero-Trust" architecture where the Hub acts as a blind relay.

## 1. Threat Agent: The Malicious Hub

The attacker is an internal or external entity who operates the Hub.
*   **Capabilities:**
    *   Inspect all traffic terminating at the Hub (TLS termination).
    *   Modify, drop, or replay messages.
    *   Corrupt or delete stored data (databases, blobs).
    *   Perform traffic analysis (timing, size).
*   **Limitations:**
    *   Cannot forge signatures from the Client (Mobile App) or Node (Nitellad).
    *   Cannot decrypt E2E encrypted payloads (Profiles, Metrics, Proxy Rules).
    *   Cannot derive PAKE shared secrets without an online guessing attack.

## 2. Scenario Analysis

### Scenario 1: Hub Launch
*   **Context:** Hub starts listening on a public port with a valid TLS certificate.
*   **Attacker Action:** Passive listening.
*   **Risk:** None. The Hub is a legitimate endpoint from a TCP/TLS perspective.

### Scenario 2: User Registration (CLI)
*   **Context:** User connects to register (`RegisterUser`).
*   **Data Exposed to Hub:**
    *   **User IP Address:** Visible (Layer 3/4).
    *   **Blind Index:** `Hash(Email + Salt)`. The Hub can track this pseudonym but cannot reverse it to an Email (assuming salt is secret or high entropy).
    *   **Encrypted Profile:** `EncryptedPayload` (Email, Avatar).
*   **Attacker Capability:**
    *   **Denial of Service:** Reject registration.
    *   **Pseudonym Tracking:** Correlate the `blind_index` with the User's IP address.
    *   **Profile Corruption:** Delete or overwrite the encrypted profile blob. The User will detect this upon decryption failure (integrity check), but data is lost.
*   **Protection:** The Hub **cannot** see the User's email or profile data.

### Scenario 3: Node Registration (The "Root CA" Flow)
*   **Context:** Node pairs with Client via Hub using PAKE, then registers.
*   **Phase A: PAKE Pairing (Key Exchange)**
    *   **Data Exposed:** `PakeMessage` (opaque bytes).
    *   **Attacker Capability (MitM):** The Hub relays these messages. To intercept the session, the Hub must run a concurrent PAKE exchange with both Client and Node.
    *   **Constraint:** PAKE (CPace, RFC 9497) requires the "Pairing Code" (e.g., "7-tiger-castle"). If the Hub doesn't know this code, the handshake fails mathematically.
    *   **Attack:** The Hub can attempt to *guess* the code online.
    *   **Mitigation:** The system enforces rate limits (50 global, 1 per IP/5s). A malicious Hub can bypass its own rate limits, but the *Client and Node* will reject the handshake if the code is wrong.
*   **Phase B: Certificate Exchange (Inside PAKE Channel)**
    *   **Data Exposed:** `EncryptedPayload` (AES-GCM with PAKE key).
    *   **Content:** The Client sends the Signed Certificate (`cert.pem`) to the Node.
    *   **Protection:** The Hub cannot read this payload (no PAKE key).
*   **Phase C: Node Registration (Post-Pairing)**
    *   **Data Exposed:** `RegisterNodeRequest` containing `cert_pem` (Public).
    *   **Attacker Capability:**
        *   **Certificate Visibility:** The Hub *does* see the Node's valid Certificate (Public Key + Node ID).
        *   **Impersonation:** The Hub **cannot** impersonate the Node because it lacks the Node's Private Key.
        *   **CSR Forgery:** The Hub **cannot** forge a CSR or Certificate because it lacks the Client's CA Private Key.
    *   **Risk:** The Hub knows *who* the Node is (Node ID) and its Public Key, but cannot *be* the Node.

### Scenario 4: Template Management
*   **Context:** CLI saves a proxy template (`PushRevision`).
*   **Data Exposed:** `encrypted_blob`.
*   **Attacker Capability:**
    *   **Storage:** The Hub stores the blob.
    *   **Analysis:** The Hub knows the *size* of the template and *when* it was updated.
    *   **Modification:** The Hub can overwrite the blob with garbage. The Client will fail to decrypt/verify signature.
*   **Protection:** Confidentiality is maintained. The Hub cannot read the proxy rules.

### Scenario 5: Approval Workflow
*   **Context:** Connection arrives at Node with `REQUIRE_APPROVAL` action. Node requests user approval via Hub or P2P.
*   **Hub Mode Flow:**
    *   **Data Exposed:** `EncryptedPayload` containing approval request details (source IP, destination, geo info).
    *   **Attacker Capability:**
        *   **Relay/Drop:** Hub can delay or drop approval requests (DoS).
        *   **Cannot Read:** Hub cannot see which IP is requesting access or the destination.
        *   **Cannot Forge:** Hub cannot forge approval decisions (signed by Client).
    *   **Protection:** E2E encryption ensures Hub sees only opaque blobs.
*   **P2P Mode Flow:**
    *   **Data Exposed:** DTLS-encrypted DataChannel messages.
    *   **Protection:** Hub is completely bypassed - no visibility into approval traffic.
*   **Decision Integrity:**
    *   Approval decisions are cryptographically signed by the Client.
    *   Node verifies signature before accepting any decision.
    *   Hub cannot forge, modify, or replay decisions.

### Scenario 6: Proxy Configuration & P2P Signaling
*   **Context:** CLI adds a rule to Nitellad.
*   **Path A: Via Hub Relay (Command)**
    *   **Data Exposed:** `EncryptedPayload` (Command).
    *   **Attacker Capability:** Relay or Drop. Replay is mitigated by timestamp validation (±60s) and request ID deduplication.
    *   **Protection:** E2E Encryption prevents the Hub from reading "Add Rule: *.google.com".
*   **Path B: Via P2P (WebRTC)**
    *   **Data Exposed:** `SignalMessage` (WebRTC SDP/ICE Candidates).
    *   **Privacy Exposure:** The SDP payload is **JSON plaintext**.
        *   **Local IPs:** The Hub sees the *Internal* LAN IPs of the peers.
        *   **Public IPs:** The Hub **already knows** the Public IPs because it terminates the TCP/TLS connection for signaling.
    *   **Impact:** The Hub can map User Identity -> Node Identity -> IP Addresses.
    *   **Unavoidable Risk:** Hiding the Public IP from the Hub is impossible as long as the Hub acts as the signaling/relay server. IP exposure is an inherent property of TCP/IP.
    *   **Data Channel:** Once P2P is established, the actual traffic (WebRTC DataChannel) is **DTLS-Encrypted**. The Hub cannot decrypt the data stream.

## 3. Vulnerability Summary

| Asset | Confidentiality (vs Hub) | Integrity (vs Hub) | Availability (vs Hub) |
| :--- | :--- | :--- | :--- |
| **User Credentials** | ✅ Secure (Blind Index) | ⚠️ Deletable | ❌ Hub can deny login |
| **User Profile** | ✅ Secure (E2E Encrypted) | ⚠️ Deletable | ❌ Hub can deny access |
| **Proxy Rules** | ✅ Secure (E2E Encrypted) | ⚠️ Deletable | ❌ Hub can deny sync |
| **Approval Requests** | ✅ Secure (E2E Encrypted) | ✅ Secure (Signed) | ❌ Hub can delay/drop |
| **Approval Decisions** | ✅ Secure (E2E Encrypted) | ✅ Secure (Signed) | ❌ Hub can delay/drop |
| **Node Traffic** | ✅ Secure (DTLS/E2E) | ✅ Secure (Signed) | ❌ Hub can stop relay |
| **User/Node Public IP** | ❌ **KNOWN** (Layer 3/4) | N/A | N/A |
| **P2P Data** | ✅ Secure (DTLS) | ✅ Secure (DTLS) | ❌ Hub can stop signal |

## 4. Recommendations for Mitigation

1.  **Payload padding:** To prevent traffic analysis (guessing rule types by size), pad encrypted blobs to fixed block sizes.
2.  **Audit Logs:** Client and Node should log Hub's behavior (e.g., "Hub returned invalid signature") to detect malicious activity locally.
3.  **Tor/I2P Support (Future):** To truly hide IPs from the Hub, the system would need to support running over an anonymity network like Tor. This is out of scope for the current design.
