import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import '../main.dart';
import '../utils/error_helper.dart';
import '../utils/proto_helpers.dart';

class SignedCertificatesScreen extends ConsumerStatefulWidget {
  const SignedCertificatesScreen({super.key});

  @override
  ConsumerState<SignedCertificatesScreen> createState() =>
      _SignedCertificatesScreenState();
}

class _SignedCertificatesScreenState
    extends ConsumerState<SignedCertificatesScreen> {
  List<local.NodeInfo> _nodes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final response = await client
          .getHubDashboardSnapshot(local.GetHubDashboardSnapshotRequest());

      if (mounted) {
        setState(() {
          _nodes = response.nodes;
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

  void _showCertificateDetails(local.NodeInfo node) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_user,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.name.isNotEmpty ? node.name : node.nodeId,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Certificate Details',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Certificate info
              _buildDetailRow('Node ID', node.nodeId),
              _buildDetailRow('Emoji Hash', node.emojiHash),
              _buildDetailRow('Status',
                  node.online ? '\u{1F7E2} Online' : '\u{26AA} Offline'),
              _buildDetailRow('Connection', connTypeLabel(node.connType)),
              _buildDetailRow(
                  'Paired',
                  node.hasPairedAt()
                      ? _formatDateTime(node.pairedAt.toDateTime())
                      : 'Unknown'),
              const SizedBox(height: 16),

              const Divider(),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: node.nodeId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Node ID copied')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy ID'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _revokeConfirmation(node),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Revoke'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
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

  Future<void> _revokeConfirmation(local.NodeInfo node) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    Navigator.pop(context); // Close bottom sheet

    String selectedReason = 'No longer needed';

    final confirmed = await showDialog<bool>(
      context: this.context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Revoke Certificate?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This will permanently revoke the certificate for:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      node.emojiHash,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        node.name.isNotEmpty ? node.name : node.nodeId,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedReason,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Key compromised', child: Text('Key compromised')),
                  DropdownMenuItem(
                      value: 'No longer needed',
                      child: Text('No longer needed')),
                  DropdownMenuItem(
                      value: 'Superseded', child: Text('Superseded')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setDialogState(() => selectedReason = v!),
              ),
              const SizedBox(height: 16),
              Text(
                'Reason: $selectedReason',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              const Text(
                '\u26A0\uFE0F This action cannot be undone. '
                'The node will no longer be able to connect.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Revoke'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final client = ref.read(logicServiceProvider);
        await client.removeNode(local.RemoveNodeRequest(nodeId: node.nodeId));
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Certificate revoked')),
        );
        _loadCertificates();
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signed Certificates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCertificates,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCertificates,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _nodes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'No signed certificates',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pair nodes to issue certificates',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCertificates,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _nodes.length,
                        itemBuilder: (context, index) {
                          final node = _nodes[index];
                          return _CertificateCard(
                            node: node,
                            onTap: () => _showCertificateDetails(node),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final local.NodeInfo node;
  final VoidCallback onTap;

  const _CertificateCard({
    required this.node,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: node.online
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    node.emojiHash.isNotEmpty
                        ? node.emojiHash.substring(0, 2)
                        : '\u{1F510}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Certificate info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            node.name.isNotEmpty ? node.name : node.nodeId,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${_formatId(node.nodeId)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: node.online ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          node.online ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: node.online ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\u2022 ${connTypeLabel(node.connType)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _formatId(String id) {
    if (id.length <= 16) return id;
    return '${id.substring(0, 8)}...';
  }
}
