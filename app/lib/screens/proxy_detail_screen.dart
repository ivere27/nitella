import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/common/common.pb.dart' as common;
import 'package:nitella_app/proxy/proxy.pb.dart' as proxy;
import 'package:nitella_app/widgets/reliability_notice.dart';
import '../main.dart';
import '../utils/error_helper.dart';
import 'rules_screen.dart';
import 'connections_screen.dart';

class ProxyDetailScreen extends ConsumerStatefulWidget {
  final String nodeId;
  final String nodeName;
  final local.ProxyInfo proxyInfo;

  const ProxyDetailScreen({
    super.key,
    required this.nodeId,
    required this.nodeName,
    required this.proxyInfo,
  });

  @override
  ConsumerState<ProxyDetailScreen> createState() => _ProxyDetailScreenState();
}

class _ProxyDetailScreenState extends ConsumerState<ProxyDetailScreen> {
  late local.ProxyInfo _proxy;
  local.ConnectionStats? _stats;
  List<local.GeoStats> _countryStats = [];
  List<local.GeoStats> _ispStats = [];
  List<proxy.Rule> _rules = [];
  bool _isLoading = true;
  Timer? _autoRefreshTimer;
  bool _autoRefresh = false;
  bool _syncInProgress = false;
  bool _syncDegraded = false;
  String _syncReason = '';
  final List<ReliabilityAuditEntry> _syncAuditLog = [];

  @override
  void initState() {
    super.initState();
    _proxy = widget.proxyInfo;
    _loadData();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
      if (_autoRefresh) {
        _autoRefreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
          if (!_isLoading) _loadData();
        });
      } else {
        _autoRefreshTimer?.cancel();
        _autoRefreshTimer = null;
      }
    });
  }

  Future<void> _loadData() async {
    if (!_isLoading) {
      // Silent refresh — don't show loading spinner
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final client = ref.read(logicServiceProvider);

      // Refresh proxy info
      final proxyResp = await client.getProxy(local.GetProxyRequest(
        nodeId: widget.nodeId,
        proxyId: _proxy.proxyId,
      ));
      _proxy = proxyResp;

      // Load connection stats for this proxy
      final statsResp = await client.getConnectionStats(
        local.GetConnectionStatsRequest(
          nodeId: widget.nodeId,
          proxyId: _proxy.proxyId,
        ),
      );
      _stats = statsResp;

      // Load country geo stats
      try {
        final countryResp = await client.getGeoStats(local.GetGeoStatsRequest(
          nodeId: widget.nodeId,
          type: local.GeoStatsType.GEO_STATS_TYPE_COUNTRY,
          limit: 5,
        ));
        _countryStats = countryResp.stats;
      } catch (_) {
        // Geo stats may not be available
      }

      // Load ISP stats
      try {
        final ispResp = await client.getGeoStats(local.GetGeoStatsRequest(
          nodeId: widget.nodeId,
          type: local.GeoStatsType.GEO_STATS_TYPE_ISP,
          limit: 5,
        ));
        _ispStats = ispResp.stats;
      } catch (_) {
        // Geo stats may not be available
      }

      // Load rules for this proxy
      final rulesResp = await client.listRules(local.ListRulesRequest(
        nodeId: widget.nodeId,
        proxyId: _proxy.proxyId,
      ));
      _rules = rulesResp.rules;

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

  Future<void> _toggleProxy(bool running) async {
    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.updateProxy(local.UpdateProxyRequest(
        nodeId: widget.nodeId,
        proxyId: _proxy.proxyId,
        running: running,
      ));
      setState(() => _proxy = resp);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }

  Future<void> _disconnectAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect All?'),
        content: Text(
          'Close all ${_stats?.activeConnections ?? 0} active connections on this proxy?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final client = ref.read(logicServiceProvider);
        final resp = await client.closeAllConnections(
          local.CloseAllConnectionsRequest(
            nodeId: widget.nodeId,
            proxyId: _proxy.proxyId,
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Closed ${resp.closedCount} connections')),
          );
          _loadData();
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

  Future<void> _showEditDialog() async {
    final nameController = TextEditingController(text: _proxy.name);
    final listenController = TextEditingController(text: _proxy.listenAddr);
    final backendController =
        TextEditingController(text: _proxy.defaultBackend);
    common.ActionType defaultAction = _proxy.defaultAction;
    common.FallbackAction fallbackAction = _proxy.fallbackAction;
    bool showAdvanced = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Proxy'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: listenController,
                  decoration:
                      const InputDecoration(labelText: 'Listen Address'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: backendController,
                  decoration:
                      const InputDecoration(labelText: 'Default Backend'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<common.ActionType>(
                  value: defaultAction,
                  decoration:
                      const InputDecoration(labelText: 'Default Action'),
                  items: const [
                    DropdownMenuItem(
                      value: common.ActionType.ACTION_TYPE_ALLOW,
                      child: Text('Allow'),
                    ),
                    DropdownMenuItem(
                      value: common.ActionType.ACTION_TYPE_BLOCK,
                      child: Text('Block'),
                    ),
                    DropdownMenuItem(
                      value: common.ActionType.ACTION_TYPE_MOCK,
                      child: Text('Mock'),
                    ),
                    DropdownMenuItem(
                      value: common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL,
                      child: Text('Require Approval'),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => defaultAction = v!),
                ),
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
                    value: fallbackAction,
                    decoration: const InputDecoration(
                      labelText: 'Fallback Action',
                      helperText: 'When backend is unavailable',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: common.FallbackAction.FALLBACK_ACTION_CLOSE,
                        child: Text('Close Connection'),
                      ),
                      DropdownMenuItem(
                        value: common.FallbackAction.FALLBACK_ACTION_MOCK,
                        child: Text('Send Mock Response'),
                      ),
                    ],
                    onChanged: (v) => setDialogState(() => fallbackAction = v!),
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
                  final resp =
                      await client.updateProxy(local.UpdateProxyRequest(
                    nodeId: widget.nodeId,
                    proxyId: _proxy.proxyId,
                    name: nameController.text,
                    listenAddr: listenController.text,
                    defaultBackend: backendController.text,
                    defaultAction: defaultAction,
                    fallbackAction: fallbackAction,
                  ));
                  setState(() => _proxy = resp);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Proxy updated')),
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _recordSyncAudit(
      {required String message,
      required String detail,
      required bool degraded}) {
    if (!mounted) return;
    setState(() {
      _syncAuditLog.insert(
        0,
        ReliabilityAuditEntry(
          timestamp: DateTime.now(),
          label: 'sync • ${widget.nodeName}',
          message: message,
          detail: detail,
          degraded: degraded,
        ),
      );
      if (_syncAuditLog.length > 100) {
        _syncAuditLog.removeRange(100, _syncAuditLog.length);
      }
      _syncDegraded = degraded;
      _syncReason = message;
    });
  }

  void _showSyncSnackbar(String message, {bool warning = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: warning ? Colors.orange.shade700 : null,
      ),
    );
  }

  Future<void> _syncProxyRevision() async {
    if (_syncInProgress) return;
    setState(() => _syncInProgress = true);
    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.pushLocalProxyRevision(
        local.PushLocalProxyRevisionRequest(proxyId: _proxy.proxyId),
      );

      if (!resp.success) {
        final err =
            resp.error.trim().isNotEmpty ? resp.error.trim() : 'Sync failed';
        _recordSyncAudit(
          message: err,
          detail: 'proxy: ${_proxy.proxyId}',
          degraded: true,
        );
        _showSyncSnackbar('Sync failed: $err', warning: true);
        return;
      }

      final explicitFields = resp.remotePushed ||
          resp.localMetadataUpdated ||
          resp.localMetadataError.trim().isNotEmpty;
      final remotePushed = explicitFields ? resp.remotePushed : resp.success;
      final localUpdated = explicitFields
          ? resp.localMetadataUpdated
          : resp.error.trim().isEmpty;

      if (remotePushed && !localUpdated) {
        final localErr = resp.localMetadataError.trim().isNotEmpty
            ? resp.localMetadataError.trim()
            : (resp.error.trim().isNotEmpty
                ? resp.error.trim()
                : 'Remote push completed, local metadata update failed');
        _recordSyncAudit(
          message: localErr,
          detail: 'proxy: ${_proxy.proxyId}',
          degraded: true,
        );
        _showSyncSnackbar(
          'Synced to Hub, but local metadata failed: $localErr',
          warning: true,
        );
        return;
      }

      _recordSyncAudit(
        message: 'Proxy revision synced successfully',
        detail: 'proxy: ${_proxy.proxyId}',
        degraded: false,
      );
      _showSyncSnackbar('Proxy revision synced to Hub');
    } catch (e) {
      final err = friendlyError(e);
      _recordSyncAudit(
        message: err,
        detail: 'proxy: ${_proxy.proxyId}',
        degraded: true,
      );
      _showSyncSnackbar('Sync failed: $err', warning: true);
    } finally {
      if (mounted) {
        setState(() => _syncInProgress = false);
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatCount(int count) {
    if (count < 1000) return '$count';
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  String _actionLabel(common.ActionType action) {
    switch (action) {
      case common.ActionType.ACTION_TYPE_ALLOW:
        return 'Allow';
      case common.ActionType.ACTION_TYPE_BLOCK:
        return 'Block';
      case common.ActionType.ACTION_TYPE_MOCK:
        return 'Mock';
      case common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL:
        return 'Require Approval';
      default:
        return 'Unspecified';
    }
  }

  String _ruleActionIcon(common.ActionType action) {
    switch (action) {
      case common.ActionType.ACTION_TYPE_ALLOW:
        return '\u2713';
      case common.ActionType.ACTION_TYPE_BLOCK:
        return '\u2718';
      case common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL:
        return '\u23f3';
      case common.ActionType.ACTION_TYPE_MOCK:
        return '\u{1f3ad}';
      default:
        return '?';
    }
  }

  Color _ruleActionColor(common.ActionType action) {
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

  String _describeRule(proxy.Rule rule) {
    if (rule.conditions.isNotEmpty) {
      return rule.conditions.map((c) {
        final typeName = c.type.name.replaceFirst('CONDITION_TYPE_', '');
        final opName = c.op.name.replaceFirst('OPERATOR_', '');
        final neg = c.negate ? 'NOT ' : '';
        return '$neg$typeName $opName ${c.value}';
      }).join(' AND ');
    }
    if (rule.expression.isNotEmpty) return rule.expression;
    return 'No conditions';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final proxyName = _proxy.name.isNotEmpty ? _proxy.name : _proxy.listenAddr;
    final isRunning = _proxy.running;

    return Scaffold(
      appBar: AppBar(
        title: Text(proxyName),
        actions: [
          IconButton(
            icon: Icon(_autoRefresh ? Icons.pause : Icons.play_arrow),
            tooltip: _autoRefresh ? 'Stop auto-refresh' : 'Auto-refresh',
            onPressed: _toggleAutoRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  if (_syncDegraded)
                    ReliabilityNoticeBanner(
                      title: 'Proxy sync degraded',
                      message: _syncReason,
                      degraded: true,
                    ),
                  // Status header
                  _buildStatusHeader(theme, isRunning),
                  const SizedBox(height: 8),

                  // Action buttons
                  _buildActionButtons(isRunning),
                  ReliabilityAuditPanel(
                    title: 'Proxy Sync Audit (Session)',
                    entries: _syncAuditLog,
                    onClear: () {
                      setState(() {
                        _syncAuditLog.clear();
                      });
                    },
                  ),

                  const Divider(height: 32),

                  // Stats section
                  if (_stats != null) ...[
                    _buildStatsSection(theme),
                    const Divider(height: 32),
                  ],

                  // Geo stats
                  if (_countryStats.isNotEmpty || _ispStats.isNotEmpty) ...[
                    _buildGeoSection(theme),
                    const Divider(height: 32),
                  ],

                  // Rules section
                  _buildRulesSection(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusHeader(ThemeData theme, bool isRunning) {
    final statusColor = isRunning ? Colors.green : Colors.orange;
    final statusText = isRunning
        ? 'Running \u2022 ${_proxy.activeConnections} connections'
        : 'Stopped';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status line
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 10),
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
          const SizedBox(height: 8),

          // Listen address -> backend
          Text(
            '${_proxy.listenAddr}${_proxy.defaultBackend.isNotEmpty ? ' \u2192 ${_proxy.defaultBackend}' : ''}',
            style: TextStyle(
                fontSize: 15, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),

          // Node info
          Text(
            'Node: ${widget.nodeName}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),

          // Bandwidth
          if (_stats != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.arrow_upward, size: 14, color: Colors.blue.shade400),
                const SizedBox(width: 4),
                Text(
                  _formatBytes(_stats!.bytesOut.toInt()),
                  style: TextStyle(fontSize: 13, color: Colors.blue.shade400),
                ),
                const SizedBox(width: 16),
                Icon(Icons.arrow_downward,
                    size: 14, color: Colors.green.shade400),
                const SizedBox(width: 4),
                Text(
                  _formatBytes(_stats!.bytesIn.toInt()),
                  style: TextStyle(fontSize: 13, color: Colors.green.shade400),
                ),
              ],
            ),
          ],

          // Default action
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Default: ${_actionLabel(_proxy.defaultAction)}',
              style: TextStyle(
                  fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isRunning) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Enable/Disable toggle
          FilledButton.tonalIcon(
            onPressed: () => _toggleProxy(!isRunning),
            icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
            label: Text(isRunning ? 'Disable' : 'Enable'),
          ),
          // Disconnect All
          if (isRunning && (_stats?.activeConnections.toInt() ?? 0) > 0)
            OutlinedButton.icon(
              onPressed: _disconnectAll,
              icon: const Icon(Icons.link_off, size: 18),
              label: const Text('Disconnect All'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          // View Connections
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConnectionsScreen(
                  nodeId: widget.nodeId,
                  proxyId: _proxy.proxyId,
                  proxyName:
                      _proxy.name.isNotEmpty ? _proxy.name : _proxy.listenAddr,
                ),
              ),
            ),
            icon: const Icon(Icons.hub, size: 18),
            label: const Text('Connections'),
          ),
          FilledButton.tonalIcon(
            onPressed: _syncInProgress ? null : _syncProxyRevision,
            icon: _syncInProgress
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload, size: 18),
            label: Text(_syncInProgress ? 'Syncing...' : 'Sync Revision'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    final stats = _stats!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stats', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          // Stats grid
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Row 1: Active, Total, Unique IPs
                  Row(
                    children: [
                      _StatCell(
                        label: 'Active',
                        value: _formatCount(stats.activeConnections.toInt()),
                        color: Colors.blue,
                      ),
                      _StatCell(
                        label: 'Total',
                        value: _formatCount(stats.totalConnections.toInt()),
                      ),
                      _StatCell(
                        label: 'Unique IPs',
                        value: _formatCount(stats.uniqueIps.toInt()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Row 2: Allowed, Blocked, Pending
                  Row(
                    children: [
                      _StatCell(
                        label: 'Allowed',
                        value: _formatCount(stats.allowedTotal.toInt()),
                        color: Colors.green,
                      ),
                      _StatCell(
                        label: 'Blocked',
                        value: _formatCount(stats.blockedTotal.toInt()),
                        color: Colors.red,
                      ),
                      _StatCell(
                        label: 'Pending',
                        value: _formatCount(stats.pendingApprovals.toInt()),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Row 3: Bandwidth
                  Row(
                    children: [
                      _StatCell(
                        label: 'Bytes In',
                        value: _formatBytes(stats.bytesIn.toInt()),
                        icon: Icons.arrow_downward,
                        color: Colors.green,
                      ),
                      _StatCell(
                        label: 'Bytes Out',
                        value: _formatBytes(stats.bytesOut.toInt()),
                        icon: Icons.arrow_upward,
                        color: Colors.blue,
                      ),
                      _StatCell(
                        label: 'Countries',
                        value: _formatCount(stats.uniqueCountries.toInt()),
                        icon: Icons.public,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeoSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Country stats
          if (_countryStats.isNotEmpty) ...[
            Text('Top Countries', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: _countryStats.map((geo) {
                    final total = _countryStats.fold<int>(
                        0, (sum, g) => sum + g.connectionCount.toInt());
                    final pct = total > 0
                        ? (geo.connectionCount.toInt() / total * 100)
                            .toStringAsFixed(0)
                        : '0';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(geo.value,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                            flex: 5,
                            child: LinearProgressIndicator(
                              value: total > 0
                                  ? geo.connectionCount.toInt() / total
                                  : 0,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 40,
                            child: Text('$pct%',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],

          // ISP stats
          if (_ispStats.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Top ISPs', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: _ispStats.map((geo) {
                    final total = _ispStats.fold<int>(
                        0, (sum, g) => sum + g.connectionCount.toInt());
                    final pct = total > 0
                        ? (geo.connectionCount.toInt() / total * 100)
                            .toStringAsFixed(0)
                        : '0';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(geo.value,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Expanded(
                            flex: 5,
                            child: LinearProgressIndicator(
                              value: total > 0
                                  ? geo.connectionCount.toInt() / total
                                  : 0,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 40,
                            child: Text('$pct%',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRulesSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rules', style: theme.textTheme.titleMedium),
              Row(
                children: [
                  Text(
                    '${_rules.length} rules',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 20),
                    tooltip: 'Manage Rules',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RulesScreen(
                            nodeId: widget.nodeId,
                            proxyId: _proxy.proxyId,
                            proxyName: _proxy.name,
                          ),
                        ),
                      );
                      _loadData(); // Refresh after returning from rules screen
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_rules.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.rule, size: 32, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'No rules configured',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Default action: ${_actionLabel(_proxy.defaultAction)}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rules.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final rule = _rules[index];
                  final actionColor = _ruleActionColor(rule.action);
                  final actionIcon = _ruleActionIcon(rule.action);
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: actionColor.withValues(alpha: 0.15),
                      child: Text(
                        actionIcon,
                        style: TextStyle(fontSize: 12, color: actionColor),
                      ),
                    ),
                    title: Text(
                      _describeRule(rule),
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${_actionLabel(rule.action)}${rule.priority > 0 ? ' \u2022 Priority ${rule.priority}' : ''}',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    trailing: Text(
                      '${index + 1}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Default: ${_actionLabel(_proxy.defaultAction)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final IconData? icon;

  const _StatCell({
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color ?? Colors.grey),
            const SizedBox(height: 4),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
