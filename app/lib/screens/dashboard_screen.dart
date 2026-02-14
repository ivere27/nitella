import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/main.dart';
import '../utils/error_helper.dart';
import '../utils/proto_helpers.dart';
import 'add_node_screen.dart';
import 'block_ip_dialog.dart';
import 'node_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  List<local.NodeInfo> _allNodes = [];
  List<local.NodeInfo> _pinnedNodes = [];
  local.HubStatus? _hubStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final client = ref.read(logicServiceProvider);
      final snapshot = await client.getHubDashboardSnapshot(
        local.GetHubDashboardSnapshotRequest(),
      );
      _allNodes = snapshot.nodes;
      _pinnedNodes = snapshot.pinnedNodes;

      final overview =
          snapshot.hasOverview() ? snapshot.overview : local.HubOverview();
      _hubStatus = local.HubStatus(
        connected: overview.hubConnected,
        hubAddress: overview.hubAddress,
        userId: overview.userId,
        tier: overview.tier,
        maxNodes: overview.maxNodes,
      );

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nitella'),
        actions: [
          // Hub status indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hub: ',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (_hubStatus?.connected ?? false)
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  (_hubStatus?.connected ?? false)
                      ? 'Connected'
                      : 'Disconnected',
                  style: TextStyle(
                    color: (_hubStatus?.connected ?? false)
                        ? Colors.green
                        : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    _buildQuickActions(context),
                    const SizedBox(height: 24),

                    // Pinned Nodes section
                    _buildPinnedNodesSection(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_circle_outline,
                label: 'Pair Node',
                color: Colors.blue,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddNodeScreen()),
                  );
                  if (result == true) _loadData();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.qr_code_scanner,
                label: 'Scan QR',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddNodeScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.block,
                label: 'Block IP',
                color: Colors.red,
                onTap: () {
                  _showBlockIpDialog(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.public,
                label: 'GeoIP',
                color: Colors.green,
                onTap: () {
                  _showGeoIpDialog(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPinnedNodesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text(
                  'Pinned Nodes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // Switch to Nodes tab - handled by parent
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_pinnedNodes.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.star_border, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text(
                  'No pinned nodes',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap the star icon on a node to pin it here',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...(_pinnedNodes.map((node) => _PinnedNodeCard(
                node: node,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NodeDetailScreen(node: node),
                    ),
                  );
                  _loadData();
                },
              ))),
      ],
    );
  }

  void _showBlockIpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BlockIPDialog(nodes: _allNodes),
    );
  }

  void _showGeoIpDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GeoIP Lookup'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'IP Address',
            hintText: '8.8.8.8',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final ip = controller.text.trim();
              Navigator.pop(context);

              try {
                final client = ref.read(logicServiceProvider);
                final result =
                    await client.lookupIP(local.LookupIPRequest(ip: ip));

                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('GeoIP: $ip'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _GeoRow('Country',
                              '${result.geo.country} (${result.geo.countryCode})'),
                          _GeoRow('City', result.geo.city),
                          _GeoRow('Region', result.geo.region),
                          _GeoRow('ISP', result.geo.isp),
                          _GeoRow('ASN', result.geo.org),
                          _GeoRow('Coordinates',
                              '${result.geo.latitude}, ${result.geo.longitude}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${friendlyError(e)}')),
                  );
                }
              }
            },
            child: const Text('Lookup'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedNodeCard extends StatelessWidget {
  final local.NodeInfo node;
  final VoidCallback onTap;

  const _PinnedNodeCard({
    required this.node,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = node.metrics;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: node.online ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),

              // Node info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          node.name.isNotEmpty ? node.name : node.nodeId,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (node.alertsEnabled)
                          const Icon(Icons.notifications,
                              size: 14, color: Colors.grey),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitle(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (node.online && node.hasMetrics()) ...[
                      const SizedBox(height: 4),
                      Text(
                        '\u2191 ${_formatBytes(metrics.bytesOut.toInt())}/s  \u2193 ${_formatBytes(metrics.bytesIn.toInt())}/s',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Chevron
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    parts.add(connTypeLabel(node.connType));
    if (node.proxyCount > 0) {
      parts.add('${node.proxyCount} proxies');
    }
    return parts.join(' \u2022 ');
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class _GeoRow extends StatelessWidget {
  final String label;
  final String value;

  const _GeoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : '-'),
          ),
        ],
      ),
    );
  }
}
