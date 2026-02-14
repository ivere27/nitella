import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/common/common.pbenum.dart' as common;
import 'package:nitella_app/proxy/proxy.pb.dart' as proxy;
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart';
import 'package:nitella_app/main.dart';
import 'package:nitella_app/widgets/reliability_notice.dart';
import '../utils/error_helper.dart';
import '../utils/biometric_guard.dart';
import '../utils/proxy_pagination.dart';
import '../utils/proto_helpers.dart';
import '../utils/rule_composer_options.dart';
import 'global_rules_screen.dart';

class NodeDetailScreen extends ConsumerStatefulWidget {
  final local.NodeInfo node;

  const NodeDetailScreen({super.key, required this.node});

  @override
  ConsumerState<NodeDetailScreen> createState() => _NodeDetailScreenState();
}

class _NodeDetailScreenState extends ConsumerState<NodeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late local.NodeInfo _node;

  // Data
  List<local.ProxyInfo> _proxies = [];
  List<proxy.Rule> _rules = [];
  local.ConnectionStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _node = widget.node;
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final client = ref.read(logicServiceProvider);
      final snapshot =
          await client.getNodeDetailSnapshot(local.GetNodeDetailSnapshotRequest(
        nodeId: _node.nodeId,
        includeProxies: false,
        includeRules: true,
        includeConnectionStats: true,
      ));
      final proxies = await listAllNodeProxiesPaginated(
        client: client,
        nodeId: _node.nodeId,
      );

      if (snapshot.hasNode()) {
        _node = snapshot.node;
      }
      _proxies = proxies;
      _rules = snapshot.rules;
      _stats = snapshot.hasConnectionStats() ? snapshot.connectionStats : null;

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${friendlyError(e)}')),
        );
      }
    }
  }

  Future<void> _removeNode() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Node'),
        content: Text(
          'Are you sure you want to remove "${_node.name.isNotEmpty ? _node.name : _node.nodeId}"?\n\nThis will revoke the node\'s certificate.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      if (!await biometricGuard(ref)) return;
      try {
        final client = ref.read(logicServiceProvider);
        await client.removeNode(local.RemoveNodeRequest(nodeId: _node.nodeId));
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${friendlyError(e)}')),
          );
        }
      }
    }
  }

  Future<void> _editNode() async {
    final nameController = TextEditingController(text: _node.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Node'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Node Name',
            hintText: 'Enter a friendly name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result != _node.name && mounted) {
      try {
        final client = ref.read(logicServiceProvider);
        await client.updateNode(local.UpdateNodeRequest(
          nodeId: _node.nodeId,
          name: result,
        ));
        // Refresh node data
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${friendlyError(e)}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_node.name.isNotEmpty ? _node.name : _node.nodeId),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editNode,
            tooltip: 'Edit',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'global_rules',
                child: ListTile(
                  leading: Icon(Icons.shield_outlined),
                  title: Text('Global Rules'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title:
                      Text('Remove Node', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'global_rules') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GlobalRulesScreen(
                      nodeId: _node.nodeId,
                      nodeName:
                          _node.name.isNotEmpty ? _node.name : _node.nodeId,
                    ),
                  ),
                );
              }
              if (value == 'refresh') _loadData();
              if (value == 'remove') _removeNode();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Proxies'),
            Tab(text: 'Rules'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Node status header
          _NodeStatusHeader(node: _node, onRefresh: _loadData),
          // Tab content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _ProxiesTab(
                          proxies: _proxies,
                          nodeId: _node.nodeId,
                          onRefresh: _loadData),
                      _RulesTab(
                          rules: _rules,
                          nodeId: _node.nodeId,
                          proxies: _proxies,
                          onRefresh: _loadData),
                      _StatsTab(stats: _stats, node: _node),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _NodeStatusHeader extends ConsumerWidget {
  final local.NodeInfo node;
  final VoidCallback onRefresh;

  const _NodeStatusHeader({required this.node, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          // Emoji avatar
          CircleAvatar(
            radius: 24,
            backgroundColor:
                node.online ? Colors.green.shade100 : Colors.grey.shade200,
            child: Text(
              node.emojiHash.isNotEmpty ? node.emojiHash.substring(0, 2) : '?',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          // Status info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: node.online ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      node.online ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: node.online ? Colors.green : Colors.grey,
                      ),
                    ),
                    if (node.connType !=
                        local.NodeConnectionType
                            .NODE_CONNECTION_TYPE_UNSPECIFIED) ...[
                      const SizedBox(width: 8),
                      Text(
                        'via ${connTypeLabel(node.connType)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${node.nodeId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Quick toggles (interactive)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  node.pinned ? Icons.star : Icons.star_border,
                  color: node.pinned ? Colors.amber : Colors.grey,
                ),
                onPressed: () => _togglePin(context, ref),
                tooltip: node.pinned ? 'Unpin' : 'Pin to Home',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: Icon(
                  node.alertsEnabled
                      ? Icons.notifications
                      : Icons.notifications_off,
                  color: node.alertsEnabled
                      ? theme.colorScheme.primary
                      : Colors.grey,
                ),
                onPressed: () => _toggleAlerts(context, ref),
                tooltip:
                    node.alertsEnabled ? 'Disable Alerts' : 'Enable Alerts',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _togglePin(BuildContext context, WidgetRef ref) async {
    try {
      final client = ref.read(logicServiceProvider);
      await client.updateNode(local.UpdateNodeRequest(
        nodeId: node.nodeId,
        pinned: !node.pinned,
      ));
      onRefresh();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }

  Future<void> _toggleAlerts(BuildContext context, WidgetRef ref) async {
    try {
      final client = ref.read(logicServiceProvider);
      await client.updateNode(local.UpdateNodeRequest(
        nodeId: node.nodeId,
        alertsEnabled: !node.alertsEnabled,
      ));
      onRefresh();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }
}

class _ProxiesTab extends ConsumerStatefulWidget {
  final List<local.ProxyInfo> proxies;
  final String nodeId;
  final VoidCallback onRefresh;

  const _ProxiesTab({
    required this.proxies,
    required this.nodeId,
    required this.onRefresh,
  });

  @override
  ConsumerState<_ProxiesTab> createState() => _ProxiesTabState();
}

class _ProxiesTabState extends ConsumerState<_ProxiesTab> {
  bool _batchDegraded = false;
  String _batchReason = '';
  final List<ReliabilityAuditEntry> _batchAuditLog = [];

  void _recordBatchEvent({
    required String label,
    required String message,
    required String detail,
    required bool degraded,
  }) {
    if (!mounted) return;
    setState(() {
      _batchAuditLog.insert(
        0,
        ReliabilityAuditEntry(
          timestamp: DateTime.now(),
          label: label,
          message: message,
          detail: detail,
          degraded: degraded,
        ),
      );
      if (_batchAuditLog.length > 100) {
        _batchAuditLog.removeRange(100, _batchAuditLog.length);
      }
      _batchDegraded = degraded;
      _batchReason = message;
    });
  }

  void _showBatchSnackbar(String message, {bool warning = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: warning ? Colors.orange.shade700 : null,
      ),
    );
  }

  String _summarizeIDs(List<String> ids) {
    if (ids.isEmpty) return '';
    final head = ids.take(3).join(', ');
    if (ids.length <= 3) return head;
    return '$head (+${ids.length - 3} more)';
  }

  @override
  Widget build(BuildContext context) {
    final proxies = widget.proxies;
    if (proxies.isEmpty) {
      return Column(
        children: [
          if (_batchDegraded)
            ReliabilityNoticeBanner(
              title: 'Node proxy operations degraded',
              message: _batchReason,
              degraded: true,
            ),
          ReliabilityAuditPanel(
            title: 'Node Proxy Ops Audit (Session)',
            entries: _batchAuditLog,
            onClear: () {
              setState(() {
                _batchAuditLog.clear();
              });
            },
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.router_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No proxies configured'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _addProxy(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Proxy'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (_batchDegraded)
          ReliabilityNoticeBanner(
            title: 'Node proxy operations degraded',
            message: _batchReason,
            degraded: true,
          ),
        ReliabilityAuditPanel(
          title: 'Node Proxy Ops Audit (Session)',
          entries: _batchAuditLog,
          onClear: () {
            setState(() {
              _batchAuditLog.clear();
            });
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => widget.onRefresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: proxies.length +
                  2, // +1 for action buttons, +1 for add button
              itemBuilder: (context, index) {
                // Action buttons row
                if (index == proxies.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _enableAllProxies,
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Enable All'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _disableAllProxies,
                          icon: const Icon(Icons.pause, size: 18),
                          label: const Text('Disable All'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _disconnectAllConnections,
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Disconnect All'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Add proxy button
                if (index == proxies.length + 1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => _addProxy(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Proxy'),
                    ),
                  );
                }

                final p = proxies[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: p.running
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      child: Icon(
                        Icons.router,
                        color: p.running ? Colors.green : Colors.grey,
                      ),
                    ),
                    title: Text(p.name.isNotEmpty ? p.name : p.proxyId),
                    subtitle:
                        Text('${p.listenAddr} \u2192 ${p.defaultBackend}'),
                    trailing: Switch(
                      value: p.running,
                      onChanged: (value) => _toggleProxy(context, p, value),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _enableAllProxies() async {
    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.setNodeProxiesRunning(
        local.SetNodeProxiesRunningRequest(
          nodeId: widget.nodeId,
          running: true,
        ),
      );
      final failedCount = resp.failedProxyIds.length;
      final skippedCount = resp.skippedCount;
      final updatedCount = resp.updatedCount;
      final failedSummary = _summarizeIDs(resp.failedProxyIds);

      if (resp.success) {
        widget.onRefresh();
        final message = skippedCount > 0
            ? 'Enabled $updatedCount proxies, $skippedCount already running'
            : 'Enabled $updatedCount proxies';
        _recordBatchEvent(
          label: 'enable all',
          message: message,
          detail: 'node: ${widget.nodeId}',
          degraded: false,
        );
        _showBatchSnackbar(message);
        return;
      }

      final err = resp.error.trim().isNotEmpty
          ? resp.error.trim()
          : 'Failed to enable proxies';
      if (updatedCount > 0 || skippedCount > 0) {
        widget.onRefresh();
        final message = failedCount > 0
            ? 'Enabled $updatedCount proxies, $failedCount failed'
            : err;
        _recordBatchEvent(
          label: 'enable all',
          message: message,
          detail:
              'node: ${widget.nodeId}; skipped: $skippedCount; failed IDs: ${failedSummary.isNotEmpty ? failedSummary : 'none'}',
          degraded: true,
        );
        _showBatchSnackbar(message, warning: true);
        return;
      }

      _recordBatchEvent(
        label: 'enable all',
        message: err,
        detail: 'node: ${widget.nodeId}',
        degraded: true,
      );
      _showBatchSnackbar('Enable failed: $err', warning: true);
    } catch (e) {
      final err = friendlyError(e);
      _recordBatchEvent(
        label: 'enable all',
        message: err,
        detail: 'node: ${widget.nodeId}',
        degraded: true,
      );
      _showBatchSnackbar('Enable failed: $err', warning: true);
    }
  }

  Future<void> _disableAllProxies() async {
    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.setNodeProxiesRunning(
        local.SetNodeProxiesRunningRequest(
          nodeId: widget.nodeId,
          running: false,
        ),
      );
      final failedCount = resp.failedProxyIds.length;
      final skippedCount = resp.skippedCount;
      final updatedCount = resp.updatedCount;
      final failedSummary = _summarizeIDs(resp.failedProxyIds);

      if (resp.success) {
        widget.onRefresh();
        final message = skippedCount > 0
            ? 'Disabled $updatedCount proxies, $skippedCount already stopped'
            : 'Disabled $updatedCount proxies';
        _recordBatchEvent(
          label: 'disable all',
          message: message,
          detail: 'node: ${widget.nodeId}',
          degraded: false,
        );
        _showBatchSnackbar(message);
        return;
      }

      final err = resp.error.trim().isNotEmpty
          ? resp.error.trim()
          : 'Failed to disable proxies';
      if (updatedCount > 0 || skippedCount > 0) {
        widget.onRefresh();
        final message = failedCount > 0
            ? 'Disabled $updatedCount proxies, $failedCount failed'
            : err;
        _recordBatchEvent(
          label: 'disable all',
          message: message,
          detail:
              'node: ${widget.nodeId}; skipped: $skippedCount; failed IDs: ${failedSummary.isNotEmpty ? failedSummary : 'none'}',
          degraded: true,
        );
        _showBatchSnackbar(message, warning: true);
        return;
      }

      _recordBatchEvent(
        label: 'disable all',
        message: err,
        detail: 'node: ${widget.nodeId}',
        degraded: true,
      );
      _showBatchSnackbar('Disable failed: $err', warning: true);
    } catch (e) {
      final err = friendlyError(e);
      _recordBatchEvent(
        label: 'disable all',
        message: err,
        detail: 'node: ${widget.nodeId}',
        degraded: true,
      );
      _showBatchSnackbar('Disable failed: $err', warning: true);
    }
  }

  Future<void> _disconnectAllConnections() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect All'),
        content: const Text(
            'This will close all active connections on this node. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final client = ref.read(logicServiceProvider);
        final resp = await client.closeAllNodeConnections(
          local.CloseAllNodeConnectionsRequest(nodeId: widget.nodeId),
        );
        final failedCount = resp.failedProxyIds.length;
        final closedCount = resp.closedCount;
        final processedCount = resp.processedProxyCount;
        final failedSummary = _summarizeIDs(resp.failedProxyIds);

        if (resp.success) {
          widget.onRefresh();
          final message =
              'Closed $closedCount connections across $processedCount proxies';
          _recordBatchEvent(
            label: 'disconnect all',
            message: message,
            detail: 'node: ${widget.nodeId}',
            degraded: false,
          );
          _showBatchSnackbar(message);
          return;
        }

        final err = resp.error.trim().isNotEmpty
            ? resp.error.trim()
            : 'Failed to disconnect all connections';
        if (closedCount > 0 && failedCount > 0) {
          widget.onRefresh();
          final message =
              'Closed $closedCount connections, $failedCount proxies failed';
          _recordBatchEvent(
            label: 'disconnect all',
            message: message,
            detail:
                'node: ${widget.nodeId}; processed: $processedCount; failed IDs: ${failedSummary.isNotEmpty ? failedSummary : 'none'}',
            degraded: true,
          );
          _showBatchSnackbar(message, warning: true);
          return;
        }

        _recordBatchEvent(
          label: 'disconnect all',
          message: err,
          detail: 'node: ${widget.nodeId}',
          degraded: true,
        );
        _showBatchSnackbar('Disconnect failed: $err', warning: true);
      } catch (e) {
        final err = friendlyError(e);
        _recordBatchEvent(
          label: 'disconnect all',
          message: err,
          detail: 'node: ${widget.nodeId}',
          degraded: true,
        );
        _showBatchSnackbar('Disconnect failed: $err', warning: true);
      }
    }
  }

  Future<void> _addProxy(BuildContext context) async {
    final nameController = TextEditingController();
    final listenController = TextEditingController(text: ':8080');
    final backendController = TextEditingController();
    final certPemController = TextEditingController();
    final keyPemController = TextEditingController();
    final caPemController = TextEditingController();
    common.ActionType defaultAction = common.ActionType.ACTION_TYPE_ALLOW;
    bool showTlsSettings = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Proxy'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g., Web Proxy',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: listenController,
                  decoration: const InputDecoration(
                    labelText: 'Listen Address',
                    hintText: ':8080 or 0.0.0.0:8080',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: backendController,
                  decoration: const InputDecoration(
                    labelText: 'Default Backend (optional)',
                    hintText: 'localhost:3000',
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
                        value: common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL,
                        child: Text('Require Approval')),
                  ],
                  onChanged: (v) => setDialogState(() => defaultAction = v!),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () =>
                      setDialogState(() => showTlsSettings = !showTlsSettings),
                  child: Row(
                    children: [
                      Icon(
                        showTlsSettings ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'TLS Settings',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (showTlsSettings) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: certPemController,
                    decoration: const InputDecoration(
                      labelText: 'Certificate PEM',
                      hintText: '-----BEGIN CERTIFICATE-----',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: keyPemController,
                    decoration: const InputDecoration(
                      labelText: 'Private Key PEM',
                      hintText: '-----BEGIN PRIVATE KEY-----',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: caPemController,
                    decoration: const InputDecoration(
                      labelText: 'CA Certificate PEM (optional)',
                      hintText: '-----BEGIN CERTIFICATE-----',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
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
                  await client.addProxy(local.AddProxyRequest(
                    nodeId: widget.nodeId,
                    name: nameController.text,
                    listenAddr: listenController.text,
                    defaultBackend: backendController.text,
                    defaultAction: defaultAction,
                    certPem: certPemController.text,
                    keyPem: keyPemController.text,
                    caPem: caPemController.text,
                  ));
                  widget.onRefresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Proxy created')),
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
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleProxy(
      BuildContext context, local.ProxyInfo p, bool running) async {
    try {
      final client = ref.read(logicServiceProvider);
      await client.updateProxy(local.UpdateProxyRequest(
        nodeId: widget.nodeId,
        proxyId: p.proxyId,
        running: running,
        updateMask: FieldMask(paths: const ['running']),
      ));
      widget.onRefresh();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }
}

class _RulesTab extends ConsumerWidget {
  final List<proxy.Rule> rules;
  final String nodeId;
  final List<local.ProxyInfo> proxies;
  final VoidCallback onRefresh;

  const _RulesTab({
    required this.rules,
    required this.nodeId,
    required this.proxies,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rule_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No rules configured'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _addRule(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Rule'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rules.length + 1,
        itemBuilder: (context, index) {
          if (index == rules.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: OutlinedButton.icon(
                onPressed: () => _addRule(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Add Rule'),
              ),
            );
          }

          final rule = rules[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    _getActionColor(rule.action).withValues(alpha: 0.2),
                child: Icon(
                  _getActionIcon(rule.action),
                  color: _getActionColor(rule.action),
                ),
              ),
              title: Text(rule.name.isNotEmpty ? rule.name : 'Rule ${rule.id}'),
              subtitle: Text('Priority: ${rule.priority}'),
              trailing: Text(
                rule.action.name.split('_').last,
                style: TextStyle(
                  color: _getActionColor(rule.action),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getActionColor(common.ActionType action) {
    switch (action) {
      case common.ActionType.ACTION_TYPE_ALLOW:
        return Colors.green;
      case common.ActionType.ACTION_TYPE_BLOCK:
        return Colors.red;
      case common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(common.ActionType action) {
    switch (action) {
      case common.ActionType.ACTION_TYPE_ALLOW:
        return Icons.check_circle;
      case common.ActionType.ACTION_TYPE_BLOCK:
        return Icons.block;
      case common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL:
        return Icons.hourglass_empty;
      default:
        return Icons.help;
    }
  }

  String _conditionTypeOptionLabel(common.ConditionType type) {
    switch (type) {
      case common.ConditionType.CONDITION_TYPE_SOURCE_IP:
        return 'Source IP';
      case common.ConditionType.CONDITION_TYPE_GEO_COUNTRY:
        return 'Country';
      case common.ConditionType.CONDITION_TYPE_GEO_CITY:
        return 'City';
      case common.ConditionType.CONDITION_TYPE_GEO_ISP:
        return 'ISP';
      case common.ConditionType.CONDITION_TYPE_TLS_PRESENT:
        return 'TLS Present';
      case common.ConditionType.CONDITION_TYPE_TLS_CN:
        return 'TLS Common Name';
      case common.ConditionType.CONDITION_TYPE_TLS_CA:
        return 'TLS CA Issuer';
      case common.ConditionType.CONDITION_TYPE_TLS_OU:
        return 'TLS Org Unit';
      case common.ConditionType.CONDITION_TYPE_TLS_SAN:
        return 'TLS Subject Alt Name';
      case common.ConditionType.CONDITION_TYPE_TLS_FINGERPRINT:
        return 'TLS Fingerprint';
      case common.ConditionType.CONDITION_TYPE_TLS_SERIAL:
        return 'TLS Serial';
      case common.ConditionType.CONDITION_TYPE_TIME_RANGE:
        return 'Time Range';
      default:
        return _humanizeEnumName(type.name, 'CONDITION_TYPE_');
    }
  }

  String _actionOptionLabel(common.ActionType action) {
    switch (action) {
      case common.ActionType.ACTION_TYPE_ALLOW:
        return 'Allow';
      case common.ActionType.ACTION_TYPE_BLOCK:
        return 'Block';
      case common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL:
        return 'Require Approval';
      case common.ActionType.ACTION_TYPE_MOCK:
        return 'Mock';
      default:
        return _humanizeEnumName(action.name, 'ACTION_TYPE_');
    }
  }

  String _humanizeEnumName(String value, String prefix) {
    final trimmed =
        value.startsWith(prefix) ? value.substring(prefix.length) : value;
    if (trimmed.isEmpty) return value;
    return trimmed
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) => '${part.substring(0, 1)}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Future<void> _addRule(BuildContext context, WidgetRef ref) async {
    if (proxies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No proxies available. Add a proxy first.')),
      );
      return;
    }

    final nameController = TextEditingController();
    final valueController = TextEditingController();
    String selectedProxyId = proxies.first.proxyId;
    common.ConditionType conditionType =
        common.ConditionType.CONDITION_TYPE_SOURCE_IP;
    common.ActionType action = common.ActionType.ACTION_TYPE_BLOCK;
    final client = ref.read(logicServiceProvider);
    var conditionOptions = defaultRuleConditionTypeOptions();
    var actionOptions = defaultRuleActionOptions();
    final hintsByConditionType = <common.ConditionType, String>{};

    Future<void> loadComposerPolicyForProxy(String proxyId) async {
      var nextConditionOptions = defaultRuleConditionTypeOptions();
      var nextActionOptions = defaultRuleActionOptions();
      final nextHints = <common.ConditionType, String>{};
      try {
        final rulesResp = await client.listRules(local.ListRulesRequest(
          nodeId: nodeId,
          proxyId: proxyId,
        ));
        if (rulesResp.hasComposerPolicy()) {
          final composerPolicy = rulesResp.composerPolicy;
          final allowedConditionTypes = <common.ConditionType>[];
          final seenConditionTypes = <common.ConditionType>{};
          for (final conditionPolicy in composerPolicy.conditionPolicies) {
            final type = conditionPolicy.conditionType;
            if (type == common.ConditionType.CONDITION_TYPE_UNSPECIFIED) {
              continue;
            }
            if (seenConditionTypes.add(type)) {
              allowedConditionTypes.add(type);
            }
            if (conditionPolicy.hasValueHint() &&
                conditionPolicy.valueHint.isNotEmpty) {
              nextHints[type] = conditionPolicy.valueHint;
            }
          }
          if (allowedConditionTypes.isNotEmpty) {
            nextConditionOptions = allowedConditionTypes;
          }

          final allowedActions = <common.ActionType>[];
          final seenActions = <common.ActionType>{};
          for (final allowedAction in composerPolicy.allowedActions) {
            if (allowedAction == common.ActionType.ACTION_TYPE_UNSPECIFIED) {
              continue;
            }
            if (seenActions.add(allowedAction)) {
              allowedActions.add(allowedAction);
            }
          }
          if (allowedActions.isNotEmpty) {
            nextActionOptions = allowedActions;
          }
        }
      } catch (_) {}

      conditionOptions = nextConditionOptions;
      actionOptions = nextActionOptions;
      hintsByConditionType
        ..clear()
        ..addAll(nextHints);

      if (!conditionOptions.contains(conditionType)) {
        conditionType = conditionOptions.first;
      }
      if (!actionOptions.contains(action)) {
        action = actionOptions.first;
      }
    }

    await loadComposerPolicyForProxy(selectedProxyId);
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedProxyId,
                  decoration: const InputDecoration(labelText: 'Proxy'),
                  isExpanded: true,
                  items: proxies
                      .map((p) => DropdownMenuItem(
                            value: p.proxyId,
                            child: Text(p.name.isNotEmpty ? p.name : p.proxyId),
                          ))
                      .toList(),
                  onChanged: (v) async {
                    if (v == null || v == selectedProxyId) return;
                    setDialogState(() => selectedProxyId = v);
                    await loadComposerPolicyForProxy(v);
                    if (ctx.mounted) {
                      setDialogState(() {});
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Rule Name',
                    hintText: 'e.g., Block suspicious IP',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<common.ConditionType>(
                  initialValue: conditionType,
                  decoration:
                      const InputDecoration(labelText: 'Condition Type'),
                  isExpanded: true,
                  items: conditionOptions
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_conditionTypeOptionLabel(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDialogState(() => conditionType = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: 'Value',
                    hintText: hintsByConditionType[conditionType] ?? '',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<common.ActionType>(
                  initialValue: action,
                  decoration: const InputDecoration(labelText: 'Action'),
                  items: actionOptions
                      .map(
                        (actionType) => DropdownMenuItem(
                          value: actionType,
                          child: Text(_actionOptionLabel(actionType)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDialogState(() => action = v!),
                ),
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
                  final resp =
                      await client.addQuickRule(local.AddQuickRuleRequest(
                    nodeId: nodeId,
                    proxyId: selectedProxyId,
                    name: nameController.text.trim(),
                    action: action,
                    conditionType: conditionType,
                    value: valueController.text.trim(),
                  ));
                  if (!resp.success) {
                    throw Exception(resp.error.isNotEmpty
                        ? resp.error
                        : 'Failed to create rule');
                  }
                  onRefresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rule created')),
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
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final local.ConnectionStats? stats;
  final local.NodeInfo node;

  const _StatsTab({required this.stats, required this.node});

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Center(child: Text('No stats available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection stats cards
          Row(
            children: [
              Expanded(
                  child: _StatCard(
                title: 'Active',
                value: '${stats!.activeConnections}',
                icon: Icons.link,
                color: Colors.blue,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                title: 'Total',
                value: '${stats!.totalConnections}',
                icon: Icons.history,
                color: Colors.green,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _StatCard(
                title: 'Blocked',
                value: '${stats!.blockedTotal}',
                icon: Icons.block,
                color: Colors.red,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                title: 'Pending',
                value: '${stats!.pendingApprovals}',
                icon: Icons.hourglass_empty,
                color: Colors.orange,
              )),
            ],
          ),
          const SizedBox(height: 24),
          // Traffic stats
          const Text(
            'Traffic',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _TrafficRow(
                    label: 'Upload',
                    value: _formatBytes(stats!.bytesOut.toInt()),
                    icon: Icons.arrow_upward,
                    color: Colors.blue,
                  ),
                  const Divider(),
                  _TrafficRow(
                    label: 'Download',
                    value: _formatBytes(stats!.bytesIn.toInt()),
                    icon: Icons.arrow_downward,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Node info
          const Text(
            'Node Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(label: 'Node ID', value: node.nodeId),
                  const Divider(),
                  _InfoRow(label: 'Fingerprint', value: node.fingerprint),
                  const Divider(),
                  _InfoRow(label: 'Emoji', value: node.emojiHash),
                  if (node.version.isNotEmpty) ...[
                    const Divider(),
                    _InfoRow(label: 'Version', value: node.version),
                  ],
                  if (node.os.isNotEmpty) ...[
                    const Divider(),
                    _InfoRow(label: 'OS', value: node.os),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrafficRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TrafficRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
