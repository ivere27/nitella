import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/main.dart';
import '../utils/error_helper.dart';
import '../utils/proto_helpers.dart';
import 'node_detail_screen.dart';
import 'add_node_screen.dart';

class NodesScreen extends ConsumerStatefulWidget {
  const NodesScreen({super.key});

  @override
  ConsumerState<NodesScreen> createState() => _NodesScreenState();
}

class _NodesScreenState extends ConsumerState<NodesScreen> {
  List<local.NodeInfo> _nodes = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNodes() async {
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

  List<local.NodeInfo> get _filteredNodes {
    if (_searchQuery.isEmpty) return _nodes;
    final query = _searchQuery.toLowerCase();
    return _nodes.where((node) {
      return node.name.toLowerCase().contains(query) ||
          node.nodeId.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _togglePin(local.NodeInfo node) async {
    try {
      final client = ref.read(logicServiceProvider);
      await client.updateNode(local.UpdateNodeRequest(
        nodeId: node.nodeId,
        pinned: !node.pinned,
      ));
      _loadNodes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }

  Future<void> _toggleAlerts(local.NodeInfo node) async {
    try {
      final client = ref.read(logicServiceProvider);
      await client.updateNode(local.UpdateNodeRequest(
        nodeId: node.nodeId,
        alertsEnabled: !node.alertsEnabled,
      ));
      _loadNodes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nodes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNodes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          // Node list
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNodeScreen()),
          );
          if (result == true) _loadNodes();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Node'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNodes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final nodes = _filteredNodes;

    if (nodes.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return const Center(
          child: Text('No nodes match your search'),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.computer_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No nodes paired yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + Add Node to pair your first node',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Sort: pinned first, then by name
    nodes.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return a.name.compareTo(b.name);
    });

    return RefreshIndicator(
      onRefresh: _loadNodes,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: nodes.length,
        itemBuilder: (context, index) {
          final node = nodes[index];
          return _NodeListTile(
            node: node,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NodeDetailScreen(node: node),
                ),
              );
              _loadNodes();
            },
            onTogglePin: () => _togglePin(node),
            onToggleAlerts: () => _toggleAlerts(node),
          );
        },
      ),
    );
  }
}

class _NodeListTile extends StatelessWidget {
  final local.NodeInfo node;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleAlerts;

  const _NodeListTile({
    required this.node,
    required this.onTap,
    required this.onTogglePin,
    required this.onToggleAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = node.metrics;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Pin & Alert toggles
              Column(
                children: [
                  GestureDetector(
                    onTap: onTogglePin,
                    child: Icon(
                      node.pinned ? Icons.star : Icons.star_border,
                      color: node.pinned ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onToggleAlerts,
                    child: Icon(
                      node.alertsEnabled
                          ? Icons.notifications
                          : Icons.notifications_off_outlined,
                      color: node.alertsEnabled
                          ? theme.colorScheme.primary
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: node.online ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitle(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (node.online && node.hasMetrics()) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatTraffic(metrics),
                        style: TextStyle(
                          fontSize: 12,
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

    // Connection type
    parts.add(connTypeLabel(node.connType));

    // Proxy count
    final proxyCount = node.proxyCount;
    if (proxyCount > 0) {
      parts.add('$proxyCount ${proxyCount == 1 ? 'proxy' : 'proxies'}');
    }

    // Active connections
    if (node.online && node.hasMetrics()) {
      final conns = node.metrics.activeConnections;
      if (conns > 0) {
        parts.add('$conns conns');
      }
    }

    return parts.join(' \u2022 ');
  }

  String _formatTraffic(local.NodeMetrics metrics) {
    final upload = _formatBytes(metrics.bytesOut.toInt());
    final download = _formatBytes(metrics.bytesIn.toInt());
    return '\u2191 $upload  \u2193 $download';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
