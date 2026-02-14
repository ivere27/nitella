import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import '../main.dart';
import '../services/hub_service.dart';
import 'settings_screen.dart';

class HubSettingsScreen extends ConsumerStatefulWidget {
  const HubSettingsScreen({super.key});

  @override
  ConsumerState<HubSettingsScreen> createState() => _HubSettingsScreenState();
}

class _HubSettingsScreenState extends ConsumerState<HubSettingsScreen> {
  final _urlController = TextEditingController();
  final _inviteCodeController = TextEditingController(text: 'NITELLA');
  local.HubStatus? _status;
  bool _isLoading = true;
  bool _isConnecting = false;
  bool _isRegistering = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final snapshot = await client.getHubSettingsSnapshot(Empty());
      final status = snapshot.hasStatus() ? snapshot.status : local.HubStatus();
      final settings =
          snapshot.hasSettings() ? snapshot.settings : local.Settings();
      final inviteCode = snapshot.resolvedInviteCode.isNotEmpty
          ? snapshot.resolvedInviteCode
          : (settings.hubInviteCode.isNotEmpty
              ? settings.hubInviteCode
              : 'NITELLA');
      final hubUrl = snapshot.resolvedHubAddress.isNotEmpty
          ? snapshot.resolvedHubAddress
          : (status.hubAddress.isNotEmpty
              ? status.hubAddress
              : settings.hubAddress);

      if (mounted) {
        setState(() {
          _status = status;
          _urlController.text = hubUrl;
          _inviteCodeController.text = inviteCode;
          _isLoading = false;
        });

        // Update global providers
        ref.read(hubConnectedProvider.notifier).state = status.connected;
        ref.read(hubAddressProvider.notifier).state = hubUrl;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _connect() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Please enter a Hub URL');
      return;
    }

    setState(() {
      _isConnecting = true;
      _error = null;
    });

    try {
      await _runOnboarding(url,
          showSuccessMessage: 'Connected and registered with Hub');
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<bool> _runOnboarding(
    String url, {
    required String showSuccessMessage,
  }) async {
    final inviteCode = _inviteCodeController.text.trim();
    final response = await HubService().ensureRegisteredWithTrustFlow(
      hubAddress: url,
      inviteCode: inviteCode,
      persistSettings: true,
      onTrustPrompt: (warning) async {
        final accepted = await _showTofuDialog(
          subject: warning.subject,
          emojiHash: warning.emojiHash,
          fingerprint: warning.fingerprint,
          expires: warning.expires,
        );
        return accepted == true;
      },
    );

    if (!response.success) {
      if (mounted) {
        setState(() => _error = response.error);
      }
      return false;
    }

    if (mounted) {
      final resolvedHubAddress =
          response.hubAddress.isNotEmpty ? response.hubAddress : url;
      ref.read(hubConnectedProvider.notifier).state = true;
      ref.read(hubAddressProvider.notifier).state = resolvedHubAddress;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(showSuccessMessage)),
      );
    }
    await _loadStatus();
    return true;
  }

  Future<bool?> _showTofuDialog({
    required String subject,
    required String emojiHash,
    required String fingerprint,
    required String expires,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('Verify Hub Certificate')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Text(
                'This Hub uses a self-signed certificate. '
                'Verify the emoji hash matches the Hub server before trusting it.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                emojiHash,
                style: const TextStyle(fontSize: 32, letterSpacing: 8),
              ),
            ),
            const SizedBox(height: 16),
            _tofuInfoRow('Subject', subject),
            _tofuInfoRow('Expires', expires),
            const SizedBox(height: 8),
            Text(
              'Fingerprint',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                fingerprint,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Reject'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Trust This Hub'),
          ),
        ],
      ),
    );
  }

  Widget _tofuInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _disconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect from Hub?'),
        content: const Text(
          'You will no longer be able to:\n'
          '\u2022 Pair nodes remotely\n'
          '\u2022 Receive push notifications\n'
          '\u2022 Sync templates',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isConnecting = true;
      _error = null;
    });

    try {
      final client = ref.read(logicServiceProvider);
      await client.disconnectFromHub(Empty());

      if (mounted) {
        ref.read(hubConnectedProvider.notifier).state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disconnected from Hub')),
        );
        _loadStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _register() async {
    setState(() {
      _isRegistering = true;
      _error = null;
    });

    try {
      final url = _urlController.text.trim().isNotEmpty
          ? _urlController.text.trim()
          : (_status?.hubAddress ?? '');
      if (url.isEmpty) {
        setState(() => _error = 'Hub URL is empty');
        return;
      }
      await _runOnboarding(url,
          showSuccessMessage: 'Registered with Hub successfully');
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hub Server'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hub URL field
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Hub URL',
                      hintText: 'hub.nitella.net:50052',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cloud),
                    ),
                    enabled: !(_status?.connected ?? false),
                  ),
                  const SizedBox(height: 12),

                  // Invite code field
                  TextField(
                    controller: _inviteCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Invite Code',
                      hintText: 'NITELLA',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vpn_key),
                    ),
                    enabled: !(_status?.connected ?? false),
                  ),
                  const SizedBox(height: 16),

                  // Status indicator
                  _buildStatusCard(),
                  const SizedBox(height: 16),

                  // Error display
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action buttons based on state
                  _buildActionButtons(),

                  // Info box when not registered
                  if (_status?.connected == true &&
                      !(_status?.userId.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Registration Required',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Register your identity with this Hub to:\n'
                            '\u2022 Pair nodes remotely\n'
                            '\u2022 Receive push notifications\n'
                            '\u2022 Sync templates across devices',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Hub info when registered
                  if ((_status?.userId.isNotEmpty ?? false) == true) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader('Hub Information'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow('Server', _status?.hubAddress ?? '-'),
                            _buildInfoRow(
                                'User ID', _formatId(_status?.userId ?? '')),
                            _buildInfoRow('Tier', _status?.tier ?? 'free'),
                            _buildInfoRow(
                                'Max Nodes', '${_status?.maxNodes ?? 0}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (_status?.connected == true &&
        (_status?.userId.isNotEmpty ?? false) == true) {
      statusColor = Colors.green;
      statusText = 'Connected & Registered';
      statusIcon = Icons.check_circle;
    } else if (_status?.connected == true) {
      statusColor = Colors.amber;
      statusText = 'Connected (not registered)';
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.grey;
      statusText = 'Not connected';
      statusIcon = Icons.cloud_off;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status', style: TextStyle(color: Colors.grey)),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_status?.connected == true &&
        (_status?.userId.isNotEmpty ?? false) == true) {
      // Connected and registered - show disconnect
      return OutlinedButton.icon(
        onPressed: _isConnecting ? null : _disconnect,
        icon: _isConnecting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.link_off),
        label: const Text('Disconnect'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    } else if (_status?.connected == true) {
      // Connected but not registered - show register and disconnect
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: _isRegistering ? null : _register,
            icon: _isRegistering
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.person_add),
            label: const Text('Register'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isConnecting || _isRegistering ? null : _disconnect,
            icon: const Icon(Icons.link_off),
            label: const Text('Disconnect'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      );
    } else {
      // Not connected - show connect
      return FilledButton.icon(
        onPressed: _isConnecting ? null : _connect,
        icon: _isConnecting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.link),
        label: const Text('Connect'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label copied')),
                );
              },
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatId(String id) {
    if (id.length <= 16) return id;
    return '${id.substring(0, 8)}...${id.substring(id.length - 8)}';
  }
}
