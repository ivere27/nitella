import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/main.dart';
import 'package:nitella_app/screens/block_ip_dialog.dart';
import 'package:nitella_app/screens/geoip_lookup_screen.dart';
import 'package:nitella_app/screens/node_detail_screen.dart';
import 'package:nitella_app/screens/pake_pairing_screen.dart';
import 'package:nitella_app/screens/qr_pairing_screen.dart';
import '../utils/proto_helpers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<local.NodeInfo> _nodes = [];
  bool _isLoading = true;
  String? _error;
  bool _hubConnected = false;
  int _onlineCount = 0;
  int _totalNodes = 0;
  int _totalProxies = 0;
  int _totalConnections = 0;

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
      final snapshot = await client.getHubDashboardSnapshot(
        local.GetHubDashboardSnapshotRequest(),
      );
      final overview =
          snapshot.hasOverview() ? snapshot.overview : local.HubOverview();
      if (mounted) {
        setState(() {
          _nodes = snapshot.nodes;
          _hubConnected = overview.hubConnected;
          _onlineCount = overview.onlineNodes;
          _totalNodes = overview.totalNodes;
          _totalProxies = overview.totalProxies;
          _totalConnections = overview.totalActiveConnections.toInt();
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

  List<local.NodeInfo> get _pinnedNodes {
    return _nodes.where((n) => n.pinned).toList();
  }

  Future<void> _startPairing() async {
    final paired = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PakePairingScreen()),
    );
    if (paired == true) {
      _loadData();
    }
  }

  void _scanQR() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrPairingScreen()),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _showBlockIPDialog() {
    showDialog(
      context: context,
      builder: (context) => BlockIPDialog(nodes: _nodes),
    );
  }

  void _showGeoIPLookup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GeoIPLookupScreen(nodes: _nodes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nitella'),
        actions: [
          // Hub status indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hub: ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Icon(
                  Icons.circle,
                  size: 10,
                  color: _hubConnected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _hubConnected ? 'Connected' : 'Offline',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _hubConnected ? Colors.green : Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text('Error: $_error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary stats (if nodes exist)
            if (_nodes.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('$_onlineCount/$_totalNodes', 'Nodes Online'),
                    Container(
                        width: 1, height: 40, color: Colors.grey.shade400),
                    _buildStat('$_totalProxies', 'Proxies'),
                    Container(
                        width: 1, height: 40, color: Colors.grey.shade400),
                    _buildStat('$_totalConnections', 'Connections'),
                  ],
                ),
              ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                      child: _buildQuickAction(Icons.add_circle_outline,
                          'Pair\nNode', Colors.blue, _startPairing)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildQuickAction(Icons.qr_code_scanner,
                          'Scan\nQR', Colors.purple, _scanQR)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildQuickAction(Icons.block, 'Block\nIP',
                          Colors.red, _showBlockIPDialog)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildQuickAction(Icons.public, 'GeoIP',
                          Colors.green, _showGeoIPLookup)),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Pinned Nodes Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Pinned Nodes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_nodes.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Navigate to Nodes tab
                        DefaultTabController.of(context).animateTo(1);
                      },
                      child: const Text('View All'),
                    ),
                ],
              ),
            ),

            if (_pinnedNodes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.star_border,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'No pinned nodes',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap \u2606 in Nodes tab to pin',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pinnedNodes.length,
                itemBuilder: (context, index) {
                  final node = _pinnedNodes[index];
                  return _buildNodeCard(node);
                },
              ),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeCard(local.NodeInfo node) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: node.online ? Colors.green : Colors.grey.shade400,
          child: Text(
            node.emojiHash.isNotEmpty ? node.emojiHash.substring(0, 2) : '?',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                node.name.isNotEmpty ? node.name : node.nodeId,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (node.alertsEnabled)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.notifications,
                    size: 16, color: Colors.amber.shade600),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.star, size: 16, color: Colors.amber.shade600),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${connTypeLabel(node.connType)} \u2022 ${node.proxyCount} proxies',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (node.hasMetrics() && node.metrics.bytesIn > 0)
              Text(
                '\u2191 ${_formatBandwidth(node.metrics.bytesOut.toInt())} \u2193 ${_formatBandwidth(node.metrics.bytesIn.toInt())}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NodeDetailScreen(node: node),
            ),
          );
        },
      ),
    );
  }

  String _formatBandwidth(int bytes) {
    if (bytes < 1024) return '$bytes B/s';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}
