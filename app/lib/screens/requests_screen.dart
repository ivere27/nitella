import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fixnum/fixnum.dart';
import 'package:nitella_app/common/common.pbenum.dart' as common_enum;
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/local/nitella_local.pbenum.dart' as local_enum;
import 'package:nitella_app/providers/active_approvals_provider.dart';
import 'package:nitella_app/widgets/reliability_notice.dart';
import 'package:nitella_app/main.dart';
import '../utils/error_helper.dart';
import '../utils/time_ago.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<local.ApprovalHistoryEntry> _history = [];
  int _historyTotalCount = 0;
  List<int> _approveDurationOptions = const [];
  int _defaultApproveDurationSeconds = 0;
  List<local_enum.DenyBlockType> _denyBlockOptions = const [
    local_enum.DenyBlockType.DENY_BLOCK_TYPE_NONE,
  ];
  bool _historyPersistenceDegraded = false;
  String _historyPersistenceReason = '';
  final List<ReliabilityAuditEntry> _historyPersistenceAuditLog = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await _loadApprovalsSnapshot();
    } catch (e) {
      debugPrint("Failed to refresh requests screen: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh: ${friendlyError(e)}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadApprovalsSnapshot() async {
    final client = ref.read(logicServiceProvider);
    final resp =
        await client.getApprovalsSnapshot(local.GetApprovalsSnapshotRequest(
      includeHistory: true,
      historyLimit: 200,
      historyOffset: 0,
    ));
    ref
        .read(activeApprovalsProvider.notifier)
        .setApprovals(resp.pendingRequests);
    final approveOptions = resp.approveDurationOptions
        .map((seconds) => seconds.toInt())
        .where((seconds) => seconds >= -1)
        .toList();
    final denyOptions =
        List<local_enum.DenyBlockType>.from(resp.denyBlockOptions);
    final defaultDuration = resp.defaultApproveDurationSeconds.toInt();
    if (!mounted) return;
    setState(() {
      _history = resp.historyEntries;
      _historyTotalCount = resp.historyTotalCount;
      _approveDurationOptions =
          approveOptions.isNotEmpty ? approveOptions : _approveDurationOptions;
      final resolvedDefaultDuration = defaultDuration >= -1
          ? defaultDuration
          : _defaultApproveDurationSeconds;
      _defaultApproveDurationSeconds =
          _approveDurationOptions.contains(resolvedDefaultDuration)
              ? resolvedDefaultDuration
              : (_approveDurationOptions.isNotEmpty
                  ? _approveDurationOptions.first
                  : _defaultApproveDurationSeconds);
      if (denyOptions.isNotEmpty) {
        _denyBlockOptions = denyOptions;
      }
    });
  }

  Future<void> _clearApprovalHistory() async {
    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client
          .clearApprovalHistory(local.ClearApprovalHistoryRequest());
      if (!resp.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to clear history: ${resp.error}')),
          );
        }
        return;
      }
      await _loadApprovalsSnapshot();
    } catch (e) {
      debugPrint("Failed to clear approval history: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to clear history: ${friendlyError(e)}')),
        );
      }
    }
  }

  void _recordHistoryPersistenceEvent(ReliabilityAuditEntry event) {
    if (!mounted) return;
    setState(() {
      _historyPersistenceAuditLog.insert(0, event);
      if (_historyPersistenceAuditLog.length > 100) {
        _historyPersistenceAuditLog.removeRange(
            100, _historyPersistenceAuditLog.length);
      }
      _historyPersistenceDegraded = event.degraded;
      _historyPersistenceReason = event.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(activeApprovalsProvider);
    final history = _history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pending'),
                  if (requests.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${requests.length}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'History'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_historyPersistenceDegraded)
            ReliabilityNoticeBanner(
              title: 'Approval history persistence degraded',
              message: _historyPersistenceReason,
              degraded: true,
              actionLabel: 'View log',
              onAction: () => _tabController.animateTo(1),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending Tab
                _isLoading && requests.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : requests.isEmpty
                        ? _buildEmptyPendingState()
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: requests.length,
                              itemBuilder: (context, index) {
                                return _PendingRequestCard(
                                  req: requests[index],
                                  approveDurationOptions:
                                      _approveDurationOptions,
                                  denyBlockOptions: _denyBlockOptions,
                                  onResolved: _refresh,
                                  onHistoryPersistenceEvent:
                                      _recordHistoryPersistenceEvent,
                                );
                              },
                            ),
                          ),
                // History Tab
                _buildHistoryTab(history),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPendingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              size: 64, color: Colors.green.shade300),
          const SizedBox(height: 16),
          const Text("No pending requests",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text("All connections are handled by rules",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<local.ApprovalHistoryEntry> history) {
    if (_isLoading && history.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        ReliabilityAuditPanel(
          title: 'History Persistence Audit (Session)',
          entries: _historyPersistenceAuditLog,
          onClear: () {
            setState(() {
              _historyPersistenceAuditLog.clear();
            });
          },
        ),
        Expanded(
          child: history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text("No history yet",
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text("Approval decisions will appear here",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return _HistoryCard(item: history[index]);
                  },
                ),
        ),
        if (history.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Showing ${history.length} of $_historyTotalCount total',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear History'),
                        content: const Text(
                            'Are you sure you want to clear all history?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _clearApprovalHistory();
                            },
                            child: const Text('Clear',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Clear All Logs',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final local.ApprovalHistoryEntry item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String actionText;

    switch (item.action) {
      case local_enum.ApprovalHistoryAction.APPROVAL_HISTORY_ACTION_APPROVED:
        icon = Icons.check_circle;
        color = Colors.green;
        actionText = 'Approved';
        break;
      case local_enum.ApprovalHistoryAction.APPROVAL_HISTORY_ACTION_DENIED:
        icon = Icons.block;
        color = Colors.red;
        actionText = 'Denied';
        break;
      case local_enum.ApprovalHistoryAction.APPROVAL_HISTORY_ACTION_EXPIRED:
        icon = Icons.timer_off;
        color = Colors.orange;
        actionText = 'Expired';
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
        actionText = 'Unknown';
        break;
    }

    final hasDecidedAt = item.hasDecidedAt();
    final timeAgo =
        hasDecidedAt ? formatTimeAgo(item.decidedAt.toDateTime()) : 'Unknown';
    final hasGeo = item.hasGeo();
    final location =
        hasGeo ? '${item.geo.city}, ${item.geo.country}' : 'Unknown location';
    final durationText = _buildDurationText(item);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        actionText,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.sourceIp.isEmpty ? item.destAddr : item.sourceIp,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '→ ${item.nodeName.isEmpty ? item.nodeId : item.nodeName} : ${item.proxyName.isEmpty ? item.proxyId : item.proxyName}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (durationText.isNotEmpty)
                    Text(
                      durationText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
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

  String _buildDurationText(local.ApprovalHistoryEntry item) {
    if (item.action ==
        local_enum.ApprovalHistoryAction.APPROVAL_HISTORY_ACTION_APPROVED) {
      if (item.durationSeconds == Int64(-1)) return 'Duration: Permanent';
      if (item.durationSeconds == Int64(0)) return 'Duration: Once';
      return 'Duration: ${_formatDuration(item.durationSeconds.toInt())}';
    }
    if (item.action ==
        local_enum.ApprovalHistoryAction.APPROVAL_HISTORY_ACTION_DENIED) {
      switch (item.blockType) {
        case local_enum.DenyBlockType.DENY_BLOCK_TYPE_IP:
          return 'Action: Block IP';
        case local_enum.DenyBlockType.DENY_BLOCK_TYPE_ISP:
          return 'Action: Block ISP';
        default:
          return 'Action: Deny once';
      }
    }
    return '';
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '$seconds s';
    if (seconds % 86400 == 0) return '${seconds ~/ 86400} day(s)';
    if (seconds % 3600 == 0) return '${seconds ~/ 3600} hour(s)';
    if (seconds % 60 == 0) return '${seconds ~/ 60} min';
    return '$seconds s';
  }
}

class _PendingRequestCard extends ConsumerWidget {
  final local.ApprovalRequest req;
  final List<int> approveDurationOptions;
  final List<local_enum.DenyBlockType> denyBlockOptions;
  final VoidCallback onResolved;
  final ValueChanged<ReliabilityAuditEntry> onHistoryPersistenceEvent;

  const _PendingRequestCard({
    required this.req,
    required this.approveDurationOptions,
    required this.denyBlockOptions,
    required this.onResolved,
    required this.onHistoryPersistenceEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geoInfo = req.hasGeo() ? req.geo : null;
    final ip = req.sourceIp;
    final location = geoInfo != null
        ? '${geoInfo.city}, ${geoInfo.country} • ${geoInfo.isp}'
        : 'Unknown Location';
    final timeAgo = formatTimeAgo(req.timestamp.toDateTime());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${req.proxyName} from $ip',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '→ ${req.nodeName} : ${req.proxyName}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _ApproveDropdown(
                    options: approveDurationOptions,
                    onApprove: (choice) => _approve(ref, context, choice),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DenyDropdown(
                    options: denyBlockOptions,
                    onDeny: (blockType) => _deny(ref, context, blockType),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _decisionApplied(local.ResolveApprovalDecisionResponse response) {
    // Backward-compatible: older backends do not populate decision_applied.
    return response.decisionApplied || response.success;
  }

  String _historyWarning(local.ResolveApprovalDecisionResponse response) {
    final historyError = response.historyError.trim();
    if (historyError.isNotEmpty) {
      return 'Decision applied, but history persistence failed: $historyError';
    }
    if (response.decisionApplied && !response.historyPersisted) {
      return 'Decision applied, but history persistence is degraded.';
    }
    return '';
  }

  void _emitHistoryPersistenceSignal(
      local.ResolveApprovalDecisionResponse response, String actionLabel) {
    final warning = _historyWarning(response);
    if (warning.isNotEmpty) {
      onHistoryPersistenceEvent(
        ReliabilityAuditEntry(
          label: '$actionLabel • ${req.nodeId}',
          degraded: true,
          message: warning,
          detail: 'request: ${req.requestId}',
          timestamp: DateTime.now(),
        ),
      );
      return;
    }
    if (response.decisionApplied && response.historyPersisted) {
      onHistoryPersistenceEvent(
        ReliabilityAuditEntry(
          label: '$actionLabel • ${req.nodeId}',
          degraded: false,
          message: 'History persistence healthy',
          detail: 'request: ${req.requestId}',
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _approve(WidgetRef ref, BuildContext context,
      _ApprovalRetentionChoice choice) async {
    try {
      final client = ref.read(logicServiceProvider);
      final response = await client
          .resolveApprovalDecision(local.ResolveApprovalDecisionRequest(
        requestId: req.requestId,
        decision: local_enum.ApprovalDecision.APPROVAL_DECISION_APPROVE,
        retentionMode: choice.mode,
        durationSeconds: Int64(choice.durationSeconds),
      ));
      if (!response.success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve: ${response.error}')),
          );
        }
        return;
      }
      if (!_decisionApplied(response)) {
        if (context.mounted) {
          final reason = response.error.trim().isNotEmpty
              ? response.error
              : 'decision was not applied';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve: $reason')),
          );
        }
        return;
      }

      ref.read(activeApprovalsProvider.notifier).removeApproval(req.requestId);
      onResolved();
      _emitHistoryPersistenceSignal(response, 'approve');
      final warning = _historyWarning(response);
      if (warning.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(warning),
            backgroundColor: Colors.orange.shade700,
          ),
        );
      }
    } catch (e) {
      debugPrint("Failed to approve: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: ${friendlyError(e)}')),
        );
      }
    }
  }

  Future<void> _deny(WidgetRef ref, BuildContext context,
      local_enum.DenyBlockType blockType) async {
    try {
      final client = ref.read(logicServiceProvider);

      // Send deny decision to backend - all rule creation handled by Go backend.
      final response = await client
          .resolveApprovalDecision(local.ResolveApprovalDecisionRequest(
        requestId: req.requestId,
        decision: local_enum.ApprovalDecision.APPROVAL_DECISION_DENY,
        retentionMode: common_enum
            .ApprovalRetentionMode.APPROVAL_RETENTION_MODE_CONNECTION_ONLY,
        durationSeconds: Int64(0),
        denyBlockType: blockType,
      ));

      if (!response.success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.error}')),
          );
        }
        return;
      }
      if (!_decisionApplied(response)) {
        if (context.mounted) {
          final reason = response.error.trim().isNotEmpty
              ? response.error
              : 'decision was not applied';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $reason')),
          );
        }
        return;
      }

      ref.read(activeApprovalsProvider.notifier).removeApproval(req.requestId);
      onResolved();
      _emitHistoryPersistenceSignal(response, 'deny');

      final warning = _historyWarning(response);
      if (warning.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(warning),
            backgroundColor: Colors.orange.shade700,
          ),
        );
      }

      // Show confirmation for block actions
      if (blockType == local_enum.DenyBlockType.DENY_BLOCK_TYPE_IP &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Blocked IP: ${req.sourceIp}')),
        );
      } else if (blockType == local_enum.DenyBlockType.DENY_BLOCK_TYPE_ISP &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Blocked ISP: ${req.geo.isp}')),
        );
      }
    } catch (e) {
      debugPrint("Failed to deny: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }
}

class _ApprovalRetentionChoice {
  final common_enum.ApprovalRetentionMode mode;
  final int durationSeconds;
  final String label;

  const _ApprovalRetentionChoice({
    required this.mode,
    required this.durationSeconds,
    required this.label,
  });
}

class _ApproveDropdown extends StatelessWidget {
  final List<int> options;
  final Function(_ApprovalRetentionChoice choice) onApprove;

  const _ApproveDropdown({
    required this.options,
    required this.onApprove,
  });

  String _durationLabel(int seconds) {
    if (seconds == 0) return '0s';
    if (seconds % 86400 == 0) return '${seconds ~/ 86400}d';
    if (seconds % 3600 == 0) return '${seconds ~/ 3600}h';
    if (seconds % 60 == 0) return '${seconds ~/ 60}m';
    return '${seconds}s';
  }

  List<_ApprovalRetentionChoice> _buildChoices() {
    final onceDurations = <int>[0, 60, 600, 3600];
    final cacheDurations =
        options.where((seconds) => seconds > 0).toSet().toList()..sort();
    if (cacheDurations.isEmpty) {
      cacheDurations.addAll(const [300, 600, 3600, 86400]);
    }

    if (kDebugMode) {
      if (!onceDurations.contains(10)) {
        onceDurations.insert(1, 10);
      }
      if (!cacheDurations.contains(10)) {
        cacheDurations.insert(0, 10);
      }
    } else {
      cacheDurations.removeWhere((seconds) => seconds == 10);
    }

    final choices = <_ApprovalRetentionChoice>[
      for (final seconds in onceDurations)
        _ApprovalRetentionChoice(
          mode: common_enum
              .ApprovalRetentionMode.APPROVAL_RETENTION_MODE_CONNECTION_ONLY,
          durationSeconds: seconds,
          label: seconds == 0
              ? 'Once • 0s (until close)'
              : 'Once • ${_durationLabel(seconds)}',
        ),
      for (final seconds in cacheDurations)
        _ApprovalRetentionChoice(
          mode: common_enum.ApprovalRetentionMode.APPROVAL_RETENTION_MODE_CACHE,
          durationSeconds: seconds,
          label: 'Cache • ${_durationLabel(seconds)}',
        ),
    ];
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    final choices = _buildChoices();
    return PopupMenuButton<_ApprovalRetentionChoice>(
      onSelected: (value) {
        onApprove(value);
      },
      itemBuilder: (context) => choices
          .map((choice) => PopupMenuItem(
                value: choice,
                child: Text(choice.label),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Approve',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DenyDropdown extends StatelessWidget {
  final List<local_enum.DenyBlockType> options;
  final Function(local_enum.DenyBlockType blockType) onDeny;

  const _DenyDropdown({required this.options, required this.onDeny});

  String _denyOptionLabel(local_enum.DenyBlockType blockType) {
    switch (blockType) {
      case local_enum.DenyBlockType.DENY_BLOCK_TYPE_NONE:
        return 'Deny once';
      case local_enum.DenyBlockType.DENY_BLOCK_TYPE_IP:
        return 'Block IP';
      case local_enum.DenyBlockType.DENY_BLOCK_TYPE_ISP:
        return 'Block ISP';
      default:
        return blockType.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedOptions = options.isNotEmpty
        ? options
        : const [local_enum.DenyBlockType.DENY_BLOCK_TYPE_NONE];
    return PopupMenuButton<local_enum.DenyBlockType>(
      onSelected: (value) {
        onDeny(value);
      },
      itemBuilder: (context) => resolvedOptions
          .map((blockType) => PopupMenuItem(
                value: blockType,
                child: Text(_denyOptionLabel(blockType)),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Deny',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }
}
