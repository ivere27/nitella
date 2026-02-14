import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/common/common.pb.dart' as common;
import '../main.dart';
import '../utils/error_helper.dart';
import '../utils/biometric_guard.dart';
import '../utils/proxy_pagination.dart';
import 'rules_screen.dart';
import 'connections_screen.dart';
import 'proxy_detail_screen.dart';

class ProxiesScreen extends ConsumerStatefulWidget {
  const ProxiesScreen({super.key});

  @override
  ConsumerState<ProxiesScreen> createState() => _ProxiesScreenState();
}

class _ProxiesScreenState extends ConsumerState<ProxiesScreen> {
  // Map of NodeID -> List<ProxyInfo>
  final Map<String, List<local.ProxyInfo>> _nodeProxies = {};
  List<local.NodeInfo> _nodes = [];
  bool _isLoading = false;

  // Search and filter
  String _searchQuery = '';
  final _searchController = TextEditingController();
  int _filterIndex = 0; // 0=All, 1=Running, 2=Stopped

  // Auto-refresh
  bool _autoRefresh = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Get filtered list of all proxies across nodes
  List<_ProxyWithNode> get _filteredProxies {
    final List<_ProxyWithNode> allProxies = [];
    for (final node in _nodes) {
      final proxies = _nodeProxies[node.nodeId] ?? [];
      for (final proxy in proxies) {
        allProxies.add(_ProxyWithNode(node: node, proxy: proxy));
      }
    }

    // Apply filter
    var filtered = allProxies;
    if (_filterIndex == 1) {
      // Running only
      filtered =
          allProxies.where((p) => p.proxy.running && p.node.online).toList();
    } else if (_filterIndex == 2) {
      // Stopped only
      filtered =
          allProxies.where((p) => !p.proxy.running || !p.node.online).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.proxy.name.toLowerCase().contains(query) ||
            p.proxy.listenAddr.toLowerCase().contains(query) ||
            p.node.name.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
      if (_autoRefresh) {
        _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
          if (!_isLoading) _refreshAll();
        });
      } else {
        _refreshTimer?.cancel();
        _refreshTimer = null;
      }
    });
  }

  Future<void> _refreshAll() async {
    setState(() => _isLoading = true);
    try {
      final client = ref.read(logicServiceProvider);
      final nodesResp = await client.listNodes(local.ListNodesRequest());
      final nodes = nodesResp.nodes;
      final nodeProxies = <String, List<local.ProxyInfo>>{};
      final failedNodes = <String>[];

      for (final node in nodes) {
        final nodeId = node.nodeId;
        final nodeLabel = node.name.isNotEmpty ? node.name : nodeId;
        try {
          nodeProxies[nodeId] = await listAllNodeProxiesPaginated(
            client: client,
            nodeId: nodeId,
          );
        } catch (e) {
          debugPrint('Error listing proxies for node $nodeId: $e');
          nodeProxies[nodeId] = [];
          failedNodes.add(nodeLabel);
        }
      }

      if (!mounted) return;
      setState(() {
        _nodes = nodes;
        _nodeProxies
          ..clear()
          ..addAll(nodeProxies);
      });

      if (failedNodes.isNotEmpty && mounted) {
        final sample = failedNodes.take(3).join(', ');
        final extra =
            failedNodes.length > 3 ? ' (+${failedNodes.length - 3} more)' : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load proxies for: $sample$extra'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error refreshing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${friendlyError(e)}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProxies = _filteredProxies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxies'),
        actions: [
          IconButton(
            icon: Icon(_autoRefresh ? Icons.pause : Icons.play_arrow),
            tooltip: _autoRefresh ? 'Stop auto-refresh' : 'Start auto-refresh',
            onPressed: _toggleAutoRefresh,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshAll),
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

          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filterIndex == 0,
                  onSelected: () => setState(() => _filterIndex = 0),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Running',
                  selected: _filterIndex == 1,
                  onSelected: () => setState(() => _filterIndex = 1),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Stopped',
                  selected: _filterIndex == 2,
                  onSelected: () => setState(() => _filterIndex = 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Proxy list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _nodes.isEmpty
                    ? _buildEmptyState()
                    : filteredProxies.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'No proxies match your search'
                                  : 'No proxies in this filter',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: filteredProxies.length,
                            itemBuilder: (context, index) {
                              final item = filteredProxies[index];
                              return _buildFlatProxyCard(item.node, item.proxy);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProxyDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Proxy'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dns_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No nodes paired yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pair a node to see its proxies',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Unified proxy dialog for both add and edit operations.
  Future<void> _showProxyDialog({
    bool isEdit = false,
    String? nodeId,
    local.ProxyInfo? existing,
  }) async {
    if (!isEdit && _nodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No nodes available')),
      );
      return;
    }

    String selectedNodeId = nodeId ?? _nodes.first.nodeId;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final listenController =
        TextEditingController(text: existing?.listenAddr ?? ':8080');
    final backendController =
        TextEditingController(text: existing?.defaultBackend ?? '');
    common.ActionType defaultAction =
        existing?.defaultAction ?? common.ActionType.ACTION_TYPE_ALLOW;
    common.FallbackAction fallbackAction =
        existing?.fallbackAction ?? common.FallbackAction.FALLBACK_ACTION_CLOSE;
    common.MockPreset defaultMock = common.MockPreset.MOCK_PRESET_UNSPECIFIED;
    common.MockPreset fallbackMock = common.MockPreset.MOCK_PRESET_UNSPECIFIED;
    bool showAdvanced = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Proxy' : 'Add Proxy'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Node selector — only shown for add
                if (!isEdit)
                  DropdownButtonFormField<String>(
                    initialValue: selectedNodeId,
                    decoration: const InputDecoration(labelText: 'Node'),
                    items: _nodes.map((n) {
                      final label = n.name.isNotEmpty ? n.name : n.nodeId;
                      return DropdownMenuItem(
                          value: n.nodeId, child: Text(label));
                    }).toList(),
                    onChanged: (v) => selectedNodeId = v!,
                  ),
                if (!isEdit) const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: isEdit ? null : 'e.g., Web Proxy',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: listenController,
                  decoration: InputDecoration(
                    labelText: 'Listen Address',
                    hintText: isEdit ? null : ':8080 or 0.0.0.0:8080',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: backendController,
                  decoration: InputDecoration(
                    labelText: isEdit
                        ? 'Default Backend'
                        : 'Default Backend (optional)',
                    hintText: isEdit ? null : 'localhost:3000',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<common.ActionType>(
                  initialValue: defaultAction,
                  decoration:
                      const InputDecoration(labelText: 'Default Action'),
                  items: const [
                    DropdownMenuItem(
                        value: common.ActionType.ACTION_TYPE_ALLOW,
                        child: Text('Allow')),
                    DropdownMenuItem(
                        value: common.ActionType.ACTION_TYPE_BLOCK,
                        child: Text('Block')),
                    DropdownMenuItem(
                        value: common.ActionType.ACTION_TYPE_MOCK,
                        child: Text('Mock')),
                    DropdownMenuItem(
                        value: common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL,
                        child: Text('Require Approval')),
                  ],
                  onChanged: (v) => setDialogState(() => defaultAction = v!),
                ),
                if (defaultAction == common.ActionType.ACTION_TYPE_MOCK) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<common.MockPreset>(
                    initialValue: defaultMock,
                    decoration:
                        const InputDecoration(labelText: 'Mock Response'),
                    isExpanded: true,
                    items: _buildMockPresetItems(),
                    onChanged: (v) => setDialogState(() => defaultMock = v!),
                  ),
                ],
                const SizedBox(height: 16),
                InkWell(
                  onTap: () =>
                      setDialogState(() => showAdvanced = !showAdvanced),
                  child: Row(
                    children: [
                      Icon(
                          showAdvanced ? Icons.expand_less : Icons.expand_more),
                      const SizedBox(width: 8),
                      const Text('Advanced Settings'),
                    ],
                  ),
                ),
                if (showAdvanced) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<common.FallbackAction>(
                    initialValue: fallbackAction,
                    decoration: const InputDecoration(
                      labelText: 'Fallback Action',
                      helperText: 'When backend is unavailable',
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: common.FallbackAction.FALLBACK_ACTION_CLOSE,
                          child: Text('Close Connection')),
                      DropdownMenuItem(
                          value: common.FallbackAction.FALLBACK_ACTION_MOCK,
                          child: Text('Send Mock Response')),
                    ],
                    onChanged: (v) => setDialogState(() => fallbackAction = v!),
                  ),
                  if (fallbackAction ==
                      common.FallbackAction.FALLBACK_ACTION_MOCK) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<common.MockPreset>(
                      initialValue: fallbackMock,
                      decoration:
                          const InputDecoration(labelText: 'Fallback Mock'),
                      isExpanded: true,
                      items: _buildMockPresetItems(),
                      onChanged: (v) => setDialogState(() => fallbackMock = v!),
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  final client = ref.read(logicServiceProvider);
                  if (isEdit && existing != null && nodeId != null) {
                    await client.updateProxy(local.UpdateProxyRequest(
                      nodeId: nodeId,
                      proxyId: existing.proxyId,
                      name: nameController.text,
                      listenAddr: listenController.text,
                      defaultBackend: backendController.text,
                      defaultAction: defaultAction,
                      fallbackAction: fallbackAction,
                      defaultMock: defaultMock,
                      fallbackMock: fallbackMock,
                    ));
                  } else {
                    await client.addProxy(local.AddProxyRequest(
                      nodeId: selectedNodeId,
                      name: nameController.text,
                      listenAddr: listenController.text,
                      defaultBackend: backendController.text,
                      defaultAction: defaultAction,
                      fallbackAction: fallbackAction,
                      defaultMock: defaultMock,
                      fallbackMock: fallbackMock,
                    ));
                  }
                  _refreshAll();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(isEdit ? 'Proxy updated' : 'Proxy created')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${friendlyError(e)}')),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<common.MockPreset>> _buildMockPresetItems() {
    return const [
      DropdownMenuItem(
          value: common.MockPreset.MOCK_PRESET_UNSPECIFIED,
          child: Text('None')),
      DropdownMenuItem(
          value: common.MockPreset.MOCK_PRESET_SSH_SECURE,
          child: Text('SSH - Secure (reject)')),
      DropdownMenuItem(
          value: common.MockPreset.MOCK_PRESET_SSH_TARPIT,
          child: Text('SSH - Tarpit (slow)')),
      DropdownMenuItem(
          value: common.MockPreset.MOCK_PRESET_HTTP_403,
          child: Text('HTTP 403 Forbidden')),
      DropdownMenuItem(
          value: common.MockPreset.MOCK_PRESET_HTTP_404,
          child: Text('HTTP 404 Not Found')),
      DropdownMenuItem(
          value: common.MockPreset.MOCK_PRESET_HTTP_401,
          child: Text('HTTP 401 Unauthorized')),
      DropdownMenuItem(
          value: common.MockPreset.MOCK_PRESET_REDIS_SECURE,
          child: Text('Redis - Auth Required')),
      DropdownMenuItem(
          value: common.MockPreset.MOCK_PRESET_MYSQL_SECURE,
          child: Text('MySQL - Access Denied')),
      DropdownMenuItem(
          value: common.MockPreset.MOCK_PRESET_MYSQL_TARPIT,
          child: Text('MySQL - Tarpit')),
      DropdownMenuItem(
          value: common.MockPreset.MOCK_PRESET_RDP_SECURE,
          child: Text('RDP - Reject')),
      DropdownMenuItem(
          value: common.MockPreset.MOCK_PRESET_TELNET_SECURE,
          child: Text('Telnet - Reject')),
      DropdownMenuItem(
          value: common.MockPreset.MOCK_PRESET_RAW_TARPIT,
          child: Text('Raw - Tarpit (any protocol)')),
    ];
  }

  Future<void> _deleteProxy(String nodeId, String proxyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Proxy?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!await biometricGuard(ref)) return;
      try {
        final client = ref.read(logicServiceProvider);
        await client.removeProxy(
            local.RemoveProxyRequest(nodeId: nodeId, proxyId: proxyId));
        _refreshAll();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proxy deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${friendlyError(e)}')),
          );
        }
      }
    }
  }

  Future<void> _toggleProxy(
      String nodeId, local.ProxyInfo proxy, bool running) async {
    try {
      final client = ref.read(logicServiceProvider);
      await client.updateProxy(local.UpdateProxyRequest(
        nodeId: nodeId,
        proxyId: proxy.proxyId,
        running: running,
      ));
      _refreshAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }

  String _getDefaultActionLabel(common.ActionType action) {
    switch (action) {
      case common.ActionType.ACTION_TYPE_ALLOW:
        return 'Allow default';
      case common.ActionType.ACTION_TYPE_BLOCK:
        return 'Block default';
      case common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL:
        return 'Require approval';
      default:
        return '';
    }
  }

  Widget _buildFlatProxyCard(local.NodeInfo node, local.ProxyInfo proxy) {
    final isRunning = proxy.running && node.online;
    final isOffline = !node.online;
    final nodeName = node.name.isNotEmpty ? node.name : node.nodeId;

    Color statusColor;
    String statusText;
    if (isOffline) {
      statusColor = Colors.grey;
      statusText = 'Node offline';
    } else if (isRunning) {
      statusColor = Colors.green;
      statusText = '${proxy.activeConnections} conns';
    } else {
      statusColor = Colors.orange;
      statusText = 'Stopped';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProxyDetailScreen(
              nodeId: node.nodeId,
              nodeName: node.name.isNotEmpty ? node.name : node.nodeId,
              proxyInfo: proxy,
            ),
          ),
        ),
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
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),

              // Proxy info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proxy.name.isNotEmpty ? proxy.name : proxy.listenAddr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$nodeName \u2022 ${proxy.listenAddr}${proxy.defaultBackend.isNotEmpty ? ' \u2192 ${proxy.defaultBackend}' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                      ),
                    ),
                    if (proxy.defaultAction !=
                        common.ActionType.ACTION_TYPE_UNSPECIFIED)
                      Text(
                        _getDefaultActionLabel(proxy.defaultAction),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),

              // Toggle switch
              if (node.online)
                Switch(
                  value: proxy.running,
                  onChanged: (value) => _toggleProxy(node.nodeId, proxy, value),
                ),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  switch (value) {
                    case 'detail':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProxyDetailScreen(
                            nodeId: node.nodeId,
                            nodeName:
                                node.name.isNotEmpty ? node.name : node.nodeId,
                            proxyInfo: proxy,
                          ),
                        ),
                      );
                      break;
                    case 'rules':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RulesScreen(
                            nodeId: node.nodeId,
                            proxyId: proxy.proxyId,
                            proxyName: proxy.name,
                          ),
                        ),
                      );
                      break;
                    case 'connections':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConnectionsScreen(
                            nodeId: node.nodeId,
                            proxyId: proxy.proxyId,
                            proxyName: proxy.listenAddr,
                          ),
                        ),
                      );
                      break;
                    case 'edit':
                      _showProxyDialog(
                          isEdit: true, nodeId: node.nodeId, existing: proxy);
                      break;
                    case 'delete':
                      _deleteProxy(node.nodeId, proxy.proxyId);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Detail'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'rules',
                    child: Row(
                      children: [
                        Icon(Icons.rule, size: 20),
                        SizedBox(width: 12),
                        Text('Rules'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'connections',
                    child: Row(
                      children: [
                        Icon(Icons.hub, size: 20),
                        SizedBox(width: 12),
                        Text('Connections'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
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
}

// Helper class to hold proxy with its parent node
class _ProxyWithNode {
  final local.NodeInfo node;
  final local.ProxyInfo proxy;

  _ProxyWithNode({required this.node, required this.proxy});
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
    );
  }
}
