import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import '../main.dart';

class EmbeddedNodeScreen extends ConsumerStatefulWidget {
  const EmbeddedNodeScreen({super.key});

  @override
  ConsumerState<EmbeddedNodeScreen> createState() => _EmbeddedNodeScreenState();
}

class _EmbeddedNodeScreenState extends ConsumerState<EmbeddedNodeScreen> {
  local.IdentityInfo? _identity;
  bool _isLoading = true;
  String? _error;
  final bool _nodeRunning = true; // TODO: Get actual status

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.getIdentity(Empty());
      if (mounted) {
        setState(() {
          _identity = resp;
          _isLoading = false;
        });
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

  Future<void> _regenerateNodeKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Regenerate Node Key?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\u26A0\uFE0F WARNING: This action cannot be undone.',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            SizedBox(height: 16),
            Text('\u2022 Existing connections will break'),
            Text('\u2022 Current certificate will be invalidated'),
            Text('\u2022 You must re-register with the Hub'),
            Text('\u2022 All paired CLIs must re-pair'),
            SizedBox(height: 16),
            Text('Are you sure you want to proceed?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Implement node key regeneration
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Node key regeneration: Coming soon')),
      );
    }
  }

  String _formatFingerprint(String fp) {
    if (fp.length <= 16) return fp;
    return '${fp.substring(0, 8)}...${fp.substring(fp.length - 8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Embedded Node'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.circle,
                            color: _nodeRunning ? Colors.green : Colors.grey,
                            size: 16,
                          ),
                          title: const Text('Status'),
                          trailing: Text(
                            _nodeRunning ? 'Running' : 'Stopped',
                            style: TextStyle(
                              color: _nodeRunning ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Node Identity Section
                      _buildSectionHeader('Node Identity'),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow('Node ID',
                                  'node-mobile-${_identity?.fingerprint.substring(0, 8) ?? 'xxxx'}'),
                              _buildInfoRow(
                                  'Fingerprint', _identity?.emojiHash ?? '-'),
                              _buildInfoRow(
                                  'Public Key',
                                  _formatFingerprint(
                                      _identity?.fingerprint ?? '-')),
                              _buildInfoRow(
                                  'Created',
                                  _identity?.hasCreatedAt() == true
                                      ? _formatDateTime(
                                          _identity!.createdAt.toDateTime())
                                      : '-'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Certificate Section (if identity exists)
                      if (_identity?.exists == true) ...[
                        _buildSectionHeader('Certificate'),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildInfoRow('Subject',
                                    'CN=${_identity?.fingerprint.substring(0, 12) ?? '-'}'),
                                _buildInfoRow(
                                    'Serial',
                                    _formatFingerprint(
                                        _identity?.fingerprint ?? '-')),
                                _buildInfoRow(
                                    'Status', '\u{1F7E2} Valid', Colors.green),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Local Proxies Section
                      _buildSectionHeader('Local Proxies'),
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No local proxies configured',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Regenerate Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _regenerateNodeKey,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Regenerate Node Key'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Warning text
                      Card(
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.warning,
                                  color: Colors.orange.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Warning: Regenerating will create a new node identity, '
                                  'invalidate existing certificate, and require re-pairing with Hub.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
                fontFamily: label.contains('ID') ||
                        label.contains('Key') ||
                        label.contains('Serial')
                    ? 'monospace'
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
