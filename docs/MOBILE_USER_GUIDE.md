# Nitella Mobile User Guide

A comprehensive guide for users running the Nitella mobile app on iOS and Android.

## Table of Contents

- [What is Nitella Mobile?](#what-is-nitella-mobile)
- [Design Philosophy](#design-philosophy)
- [Pros & Cons](#pros--cons)
- [First-Time Setup](#first-time-setup)
- [Home Screen (Dashboard)](#home-screen-dashboard)
- [Pairing Your First Node](#pairing-your-first-node)
- [Managing Nodes](#managing-nodes)
- [Managing Proxies](#managing-proxies)
- [Rules](#rules)
- [Handling Approval Requests](#handling-approval-requests)
- [Live Connections](#live-connections)
- [Statistics](#statistics)
- [Templates](#templates)
- [Proxy Config Versioning](#proxy-config-versioning)
- [Settings](#settings)
- [Security Best Practices](#security-best-practices)
- [Troubleshooting](#troubleshooting)

---

## What is Nitella Mobile?

Your phone is the security control center. The Nitella mobile app lets you:

- **Approve or deny connections** in real-time from anywhere
- **Manage proxy rules** — block by IP, country, ISP, or TLS attributes
- **Monitor live connections** with GeoIP-enriched data
- **Pair and manage nodes** — your proxy servers running `nitellad`
- **Deploy consistent configurations** across nodes with templates
- **Version-control proxy configs** with Hub-synced revision history

The app works with or without a Hub. Connect directly to local nodes over your network, or manage remote nodes worldwide through the Hub relay.

---

## Design Philosophy

### Thin UI Wrapper

The app is purely a UI layer — all business logic runs in a Go backend compiled into the app via FFI. This means the same proven Go code that powers the CLI also powers the mobile app. The Flutter UI collects your input and displays data; the Go backend handles encryption, Hub communication, certificate signing, and all validation.

### Mobile as Root CA

Your phone generates and holds the master identity — an Ed25519 private key derived from a BIP-39 mnemonic. When you pair a node, your phone signs its certificate, making your device the root of trust for your entire network. No server, Hub, or third party ever holds your private key.

### Real-Time Control

Connection approval requests are pushed to your phone in real-time. When someone connects to a service protected by Nitella, you see who they are (IP, location, ISP) and can approve or deny instantly.

### Offline Capable

Direct Connect mode lets you manage nodes on your local network or VPN without any Hub or internet access. QR code pairing works completely air-gapped.

---

## Pros & Cons

| Pros | Cons |
|------|------|
| Approve connections from anywhere | Requires phone to be available for approvals |
| Biometric protection (FaceID/TouchID) | Battery usage from push notifications |
| BIP-39 recovery — never lose your identity | Initial setup takes a few minutes |
| Works with or without Hub | Limited to TCP (Layer 4) proxy management |
| Real-time stats and geo visualization | Requires Hub for remote node management |
| Same Go backend as CLI — consistent behavior | |

---

## First-Time Setup

On first launch, you'll create or restore your cryptographic identity.

### Create a New Identity

1. **Tap "Create"** on the setup screen
2. **Enter identity details:**
   - Common Name (CN) — your name or identifier
   - Organization (Org) — optional
   - A name is auto-generated from device hostname, or enter your own
3. **Set a passphrase** (optional but recommended) — encrypts your private key
4. **Save your recovery phrase** — 24 BIP-39 words displayed once on screen. This is the only time it will be shown.

The backend evaluates passphrase strength and provides feedback including entropy estimate and crack time scenarios.

### Restore from Recovery Phrase

1. **Tap "Restore"** on the setup screen
2. **Enter your 12 or 24 word mnemonic** — the phrase from a previous identity
3. Your identity is reconstructed from the mnemonic

### Import Existing Identity

1. **Tap "Import"** on the setup screen
2. **Paste your PEM-encoded certificate and private key**
3. The app imports your existing identity

### Configure Hub (Optional)

At the bottom of the setup screen, you can configure your Hub endpoint. This can also be done later in Settings.

### Enable Biometric Auth (Recommended)

Toggle biometric authentication during setup or later in Settings. This protects your identity with FaceID, TouchID, or device PIN.

---

## Home Screen (Dashboard)

The dashboard is your main view after authentication. It shows:

### Navigation

The app has 5 bottom tabs:

| Tab | Description |
|-----|-------------|
| **Home** | Dashboard with Hub status and quick actions |
| **Nodes** | All paired nodes |
| **Proxies** | All proxies across all nodes |
| **Alerts** | Pending approvals and history |
| **Settings** | App configuration |

### Hub Status

At the top of the dashboard, a status indicator shows your Hub connection:
- **Green dot** — Connected to Hub
- **Gray dot** — Disconnected

### Quick Actions

Quick access buttons for common tasks:

- **Pair Node** — Start PAKE pairing via Hub
- **Scan QR** — Offline QR code pairing
- **Block IP** — Quick IP block dialog (with node/proxy selector and apply-to-all option)
- **GeoIP Lookup** — Look up any IP address

### Pinned Nodes

Nodes you've pinned appear on the dashboard with:
- Online/offline status indicator
- Connection type (Hub vs Direct)
- Proxy count
- Live throughput (bytes in/out)
- Pin/unpin via star icon

---

## Pairing Your First Node

Pairing connects a `nitellad` proxy node to your phone so you can manage it remotely. There are three pairing methods.

### Method 1: PAKE Pairing (via Hub)

Best for remote nodes already connected to a Hub.

1. **On the node server**, run:
   ```bash
   nitellad --hub hub.example.com:50052 --pair
   ```
   The node displays a pairing code like `7-TIGER-CASTLE`.

2. **In the app**, tap **"Pair Node"** on the dashboard (or Nodes tab)
3. **Enter the pairing code** from the node
4. **Verify emoji fingerprints** — the app and node both display the same emoji sequence. Confirm they match.
5. **Done** — the node is paired and its certificate is signed by your phone's CA

### Method 2: QR Code Pairing (Offline)

Best for air-gapped or local nodes without Hub access.

1. **On the node server**, run:
   ```bash
   nitellad --pair-offline
   ```
   The node displays a QR code on screen.

2. **In the app**, tap **"Scan QR"** on the dashboard
3. **Scan the QR code** with your phone's camera
4. **Verify emoji fingerprint** — confirm it matches what the node displays
5. **Tap "Fingerprint Matches - Sign"** — your phone signs the node's certificate
6. **Show the response QR** to the node's camera — the node receives its signed certificate
7. **Tap Done** when the node confirms pairing is complete

### Method 3: Direct Connect

Best for nodes on your local network or VPN, without Hub.

1. **In the app**, tap **"Direct Connect"** in the Add Node screen
2. **Enter the node's address** (host:port), admin token, and CA certificate PEM
3. **Tap "Test Connection"** to verify connectivity via mTLS
4. **Connect** — the app connects directly to the node's admin API

### Node Status Indicators

- **Green dot** — Node is online
- **Gray dot** — Node is offline
- Last seen timestamp shown below the status

---

## Managing Nodes

### Node List

The Nodes tab shows all paired nodes with:
- Status indicator (online/offline)
- Node name and emoji fingerprint
- Pin and notification toggles
- Search by name or ID

### Node Actions

- **Tap a node** — Open node detail screen
- **Star icon** — Pin/unpin node to dashboard
- **Bell icon** — Toggle alert notifications for this node

### Node Detail Screen

Shows full node information with tabs:

| Tab | Contents |
|-----|----------|
| **Overview** | Status, version, online/offline, proxy count |
| **Proxies** | All proxies on this node with toggle running/stopped |
| **Rules** | Global rules (node-level, cross-proxy) |
| **Connections** | Active connections with stats |
| **Settings** | Node name, tags, alerts enable/disable |

### Edit Node

- **Change name** — Tap the name field in node detail
- **Toggle pin** — Star icon in list or detail
- **Toggle alerts** — Bell icon in list or detail

### Remove Node

In the node detail screen, remove the node to unpair it. This requires biometric confirmation.

---

## Managing Proxies

### Proxy List

The Proxies tab shows a unified list of all proxies across all nodes, with:

- **Search** — Filter by name, address, or node name
- **Filter tabs** — All / Running / Stopped
- **Auto-refresh toggle** — Live updates (timer-based)
- **Group by node** — Collapsible node sections

### Proxy Display

Each proxy card shows:
- Status indicator (green=running, orange=stopped, gray=node offline)
- Proxy name and listen address
- Default action label (Allow / Block / Require Approval)
- Active connection count
- Connection type (Hub / P2P / Direct)

### Create a Proxy

Tap the add button (+) to create a new proxy:

1. **Name** — A label for the proxy (e.g., "Web Proxy")
2. **Node** — Select which node hosts this proxy
3. **Listen Address** — The bind address (e.g., `:8080`, `0.0.0.0:8080`)
4. **Default Backend** — The upstream server address (optional)
5. **Default Action:**
   - **Allow** — Forward all connections by default
   - **Block** — Block by default, use rules to allow specific IPs
   - **Mock** — Respond with a fake service banner
   - **Require Approval** — Ask you to approve each connection

6. **Mock Preset** (if Action = Mock):
   - SSH Secure (reject)
   - SSH Tarpit (slow response)
   - HTTP 403 / 404 / 401
   - Redis Auth Required
   - MySQL Access Denied / Tarpit
   - RDP Reject
   - Telnet Reject
   - Raw Tarpit (any protocol)

7. **Advanced Settings:**
   - Fallback Action — What to do when the backend is unavailable (Close Connection or Send Mock)
   - Fallback Mock — Which mock to use as fallback

### Proxy Actions

Tap the menu icon on a proxy card for:
- **Detail** — View full proxy info
- **Rules** — Manage proxy rules
- **Connections** — View live connections
- **Edit** — Modify proxy settings
- **Delete** — Remove proxy (requires confirmation + biometric)

### Enable / Disable

Use the toggle switch on each proxy card to enable or disable it (when the node is online).

---

## Rules

Rules control how individual connections are handled based on conditions. Rules are evaluated by priority (highest number first); the first matching rule wins.

### Per-Proxy Rules

Open a proxy's rules from its menu or detail screen.

### Add a Rule

Tap the add button to create a new rule:

1. **Rule Name** — A label (e.g., "Block China")
2. **Action** — Allow / Block / Mock / Require Approval
3. **Conditions** — One or more conditions (AND logic):

| Condition Type | Description | Example |
|----------------|-------------|---------|
| Source IP | Match by IP or CIDR | `192.168.1.0/24` |
| Geo Country | Match by country code | `CN`, `RU` |
| Geo City | Match by city name | `Beijing` |
| Geo ISP | Match by ISP/org | `Amazon`, `Google Cloud` |
| TLS Present | Client has a certificate | `true` |
| TLS Common Name | Certificate CN | `admin@example.com` |
| TLS CA Issuer | Certificate issuer | `My Corp CA` |
| TLS Org Unit | Certificate OU | `Engineering` |
| TLS Subject Alt Name | Certificate SAN | `server.example.com` |
| TLS Fingerprint | Certificate SHA256 hash | `SHA256:abc...` |
| Time Range | Time of day | `18:00-09:00` |

4. **Operator:**
   - Equals
   - Contains
   - Regex
   - CIDR (for IP conditions)
   - Negate (NOT operator) — invert the condition

5. **Advanced Settings:**
   - Priority (higher executes first)
   - Target Backend (optional — forward to a different backend)

### Quick-Add Shortcuts

The quick-add sheet offers common scenarios with one tap:
- **Block this IP** — Block a specific IP
- **Block IP Range** — Auto-generates /24 CIDR
- **Block Country** — Block by country code
- **Block ISP** — Block by ISP name
- **Allow this IP** — Whitelist an IP
- **Require Approval for Country** — Manual approval for a country
- **Advanced Rule Editor** — Full rule builder

### Rule Display

Rules are color-coded:
- **Green (A)** — Allow
- **Red (B)** — Block
- **Orange (M)** — Mock
- **Blue (R)** — Require Approval

Each rule shows its priority number and conditions in plain text.

### Global Rules

Global rules apply across **all proxies** on a node. Access them from the node detail screen (Rules tab).

- **Add Global Rule** — Enter IP/CIDR, action (Block/Allow), and duration (permanent or temporary)
- **List/Remove** — View and delete active global rules
- These are runtime rules — they are not persisted across node restarts

---

## Handling Approval Requests

The Alerts tab has two sub-tabs: **Pending** and **History**.

### Pending Approvals

When a connection arrives at a proxy with `require_approval`, you'll see:
- **Push notification** on your phone (if enabled via FCM)
- **Badge count** on the Alerts tab
- **Snackbar notification** with a "REVIEW" button

Each pending request shows:
- Source IP address
- Source location (City, Country, ISP) from GeoIP
- Target node and proxy name
- TLS CN and fingerprint (if present)
- Time elapsed since the request

### Approve Options

Tap the green **Approve** dropdown:

| Option | Effect |
|--------|--------|
| Approve once | Allow this single connection (CONNECTION_ONLY mode) |
| Approve 1 hour | Cache approval for 1 hour |
| Approve 24 hours | Cache approval for 24 hours |
| Approve permanently | Create a permanent allow rule |

### Deny Options

Tap the red **Deny** dropdown:

| Option | Effect |
|--------|--------|
| Deny once | Reject this connection, no rule created |
| Block IP | Create a block rule for the source IP |
| Block ISP | Create a block rule for the source ISP |

### Approval History

The History tab shows past approval decisions with:
- Action status (Approved / Denied / Expired) with icon and color
- Source IP and location
- Node and proxy
- Duration/action type
- Block type and rule ID if created
- Relative timestamp ("2 minutes ago")
- **Clear All Logs** button to reset history

History is persisted to disk (up to 1000 entries) and survives app restarts.

---

## Live Connections

View real-time connections for any proxy.

### Connection List

Access from a proxy's menu > **Connections**. The header shows:
- Proxy name and active connection count
- Total throughput (bytes in/out per second)
- Status: **LIVE** (green) or **PAUSED** (orange)

### Controls

- **Auto-refresh toggle** — Updates every 2 seconds (green=on, gray=off)
- **Pause/Resume** — Freeze the connection list
- **Close All** — Close all connections (requires confirmation)

### Filters and Sorting

- **Search** — By IP, country, ISP, or city
- **Country filter chips** — Filter by country with flag emoji and count
- **Sort by:**
  - Recent — Newest connections first
  - Bandwidth — Highest throughput first
  - Duration — Longest-running first

### Connection Details

Each connection shows:
- Country flag emoji
- Source IP (bold)
- Location (City, Country, ISP)
- Upload/download speeds
- Duration connected

Tap a connection for full details:
- Source and destination addresses
- Timestamps
- Total bytes transferred
- Full GeoIP information
- Rule matched
- Action taken
- TLS info (CN, fingerprint if available)
- Option to create block rule from this connection

### Close Connections

- **Close icon (X)** on each connection — Close that specific connection
- **Close All** in the menu — Close all connections on the proxy

Both require confirmation.

---

## Statistics

Access stats from a node detail screen. The stats screen has three tabs.

### Summary Tab

Overview cards showing:
- **Total Connections** — Total count
- **Unique IPs** — Distinct source IPs
- **Countries** — Number of countries seen
- **Allowed** — Connections allowed (green)
- **Blocked** — Connections blocked (red)
- **Pending Approvals** — Currently pending
- **Data Transfer** — Total inbound and outbound bytes

### Geo Tab

Geographic breakdown showing:
- Country (with flag)
- Connection count per country
- Unique IPs per country
- Blocked count

### Top IPs Tab

Most active source IPs with:
- IP address
- Country and ISP info
- First seen and last seen timestamps
- Total connection count
- Blocked count
- Pagination support

### Export Options

From the menu:
- **Export as CSV** — Table format with all stats
- **Export as YAML** — Structured data export
- **Copy to Clipboard** — Copies YAML to clipboard

All exports include summary statistics, geographic breakdown, top IPs, timestamps, and node ID.

---

## Templates

Templates let you save and reuse proxy configurations across nodes. Access them from the Templates screen (two tabs: My Templates and Public Templates).

### Create a Template

1. Tap "Create Template"
2. Select the **source node** to copy configuration from
3. The backend captures all proxies and their rules from the node
4. Enter a **name** and **description**
5. Add **tags** for organization

### Apply a Template

1. Tap the menu on a template > **Apply to Node**
2. Select the **target node**
3. Optionally check **"Replace existing proxies"** to clear the node first
4. The template creates the proxies and rules on the target node
5. Returns counts of proxies and rules created

### Import / Export

- **Export as YAML** — Copy template configuration to clipboard
- **Import from Clipboard** — Paste YAML to create a local template
- The parser validates the YAML structure before importing

### Template Display

Each template card shows:
- Name and description
- Proxy count
- Tags
- Author fingerprint

---

## Proxy Config Versioning

Proxy configurations can be version-controlled and synced with the Hub. Configs are E2E encrypted — the Hub stores opaque blobs it cannot read.

### Local Storage

Proxy configs are stored locally at `~/.nitella/proxies/` with an index file mapping IDs to metadata (name, description, timestamps, revision number, config hash).

### Hub Sync

- **Push** — Encrypt and upload config as a new revision to Hub
- **Pull** — Fetch and decrypt a revision from Hub
- **Diff** — Compare local config vs Hub revision, or two Hub revisions
- **History** — View revision metadata (number, size, timestamp)
- **Flush** — Delete old revisions, keep N most recent

### Deploy to Nodes

- **Apply** — Deploy a proxy config to a node (by revision number or raw YAML)
- **Unapply** — Remove a deployed proxy from a node
- **Status** — View currently applied proxies on a node

---

## Settings

### Hub & Network

- **Hub Server** — Configure Hub address and connection settings
  - Hub address field
  - Connection status indicator
  - Registration with invite code
  - Custom CA certificate PEM
  - Certificate pinning (SPKI SHA256)

- **P2P Settings** — Configure peer-to-peer mode:
  - **Auto (WebRTC)** — Automatic P2P with Hub fallback (recommended)
  - **P2P Only** — Direct connections only, no Hub relay
  - **Hub Only** — Force all traffic through Hub
  - STUN/TURN server configuration
  - P2P status display with real-time streaming

- **Push Notifications** — Configure notification preferences (FCM):
  - Approval notifications toggle
  - Node status notifications toggle
  - Connection notifications toggle
  - Test notification button

### Security

- **Biometric** — Toggle FaceID/TouchID/PIN protection
- **Auto-Lock** — Select auto-lock timer (Never, 1, 5, 15, 30, or 60 minutes)
- **Change Passphrase** — Update your identity encryption passphrase

### Identity

- **Visual Identity** — Your emoji fingerprint display
- **Export CA Certificate** — Share your CA certificate with fingerprint
- **Signed Certificates** — List all certificates you've issued to nodes

### Embedded Node

- **Node Identity** — Shows the embedded node name and ID
- **Status** — Running/stopped indicator

### About

- **Version** — App version
- **Licenses** — Open-source license information

### Reset Identity (Danger)

At the bottom of Settings, a red **Reset Identity** button permanently deletes your identity and all paired nodes. This requires biometric confirmation and cannot be undone.

---

## Security Best Practices

### Always Enable Biometric Auth

Protect your app with FaceID, TouchID, or device PIN. Your phone holds the root private key — if someone accesses the app, they can control all your paired nodes.

### Save Your Recovery Phrase at Setup

Your recovery phrase is only displayed once during initial setup. Write it down immediately and store it in a physically secure location. Do not store it digitally (screenshots, notes apps, cloud storage). There is no way to retrieve it later.

### Use Passphrase Encryption

Set a strong passphrase to encrypt your private key at rest. Even if someone extracts your app data, they cannot use your identity without the passphrase.

### Review Approval Requests Carefully

When an approval request arrives:
- Check the **source IP** and **GeoIP location** — does it make sense?
- Verify the **destination proxy** — is this a service you expect connections to?
- Consider the **time of day** — is this connection expected right now?
- Check **TLS info** — does the client certificate match an expected identity?
- When in doubt, **deny** — you can always approve later

### Use Templates for Consistency

Create templates from your best-configured nodes and apply them to new nodes. This ensures consistent security policies across your infrastructure and prevents configuration drift.

### Review Signed Certificates Periodically

Go to **Settings > Signed Certificates** and review the list. If you see certificates you don't recognize, investigate — someone may have paired a node using compromised credentials.

---

## Troubleshooting

### Can't Connect to Hub

1. **Check the Hub endpoint** in Settings > Hub Server
2. **Verify network connectivity** — try switching between WiFi and cellular
3. **Check Hub status** — contact the Hub operator to verify it's running
4. **Certificate issues** — if the Hub uses a self-signed cert, ensure you've accepted its fingerprint

### Node Shows Offline

1. **Check the node is running** — SSH into the server and verify `nitellad` is active
2. **Check Hub connectivity from the node** — the node needs outbound access to the Hub's gRPC port
3. **Verify the node certificate hasn't expired**
4. **Try Direct Connect** — if the node is on your local network, connect directly to rule out Hub issues

### Approval Notifications Not Arriving

1. **Check push notification settings** — Settings > Push Notifications, ensure approval notifications are enabled
2. **Check OS notification permissions** — Ensure the app has notification permission in your phone's settings
3. **Verify Hub connection** — Notifications flow through the Hub; check your connection status
4. **Check the proxy action** — Ensure the proxy or a rule uses `require_approval`

### Biometric Not Working

1. **Re-enable biometric** in Settings > Security > Biometric
2. **Check OS biometric settings** — Ensure FaceID/TouchID is configured in your phone's system settings
3. **Restart the app** — Force-close and reopen
4. **Fallback** — You can use your device PIN as a fallback for biometric auth

### Pairing Fails

1. **PAKE pairing** — Ensure the pairing code is entered exactly as shown on the node (case-insensitive)
2. **QR pairing** — Ensure your camera can focus on the QR code clearly
3. **Emoji mismatch** — If emoji fingerprints don't match, cancel immediately — this could indicate a man-in-the-middle attack
4. **Timeout** — Pairing codes expire after a few minutes; restart the process if it times out

### App Slow or Unresponsive

1. **Disable auto-refresh** on the Connections and Proxies screens when not actively monitoring
2. **Reduce pinned nodes** — Each pinned node maintains a live status connection
3. **Clear approval history** — A large history can slow the Alerts tab
4. **Restart the app** — Force-close and reopen to clear any stuck state
