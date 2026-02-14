import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/common/common.pb.dart' as common;
import 'package:nitella_app/proxy/proxy.pb.dart' as proxy;
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import '../main.dart';
import '../utils/error_helper.dart';
import '../utils/biometric_guard.dart';

class GlobalRulesScreen extends ConsumerStatefulWidget {
  final String nodeId;
  final String nodeName;

  const GlobalRulesScreen({
    super.key,
    required this.nodeId,
    required this.nodeName,
  });

  @override
  ConsumerState<GlobalRulesScreen> createState() => _GlobalRulesScreenState();
}

class _GlobalRulesScreenState extends ConsumerState<GlobalRulesScreen> {
  List<proxy.GlobalRule> _rules = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshRules();
  }

  Future<void> _refreshRules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.listGlobalRules(local.ListGlobalRulesRequest(
        nodeId: widget.nodeId,
      ));
      if (mounted) {
        setState(() {
          _rules = resp.rules;
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

  Future<void> _showAddDialog() async {
    final ipController = TextEditingController();
    common.ActionType action = common.ActionType.ACTION_TYPE_BLOCK;
    int durationSeconds = 0;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Global Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ipController,
                  decoration: const InputDecoration(
                    labelText: 'IP Address or CIDR',
                    hintText: '192.168.1.0/24 or 10.0.0.1',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                SegmentedButton<common.ActionType>(
                  segments: const [
                    ButtonSegment(
                      value: common.ActionType.ACTION_TYPE_BLOCK,
                      label: Text('Block'),
                      icon: Icon(Icons.block),
                    ),
                    ButtonSegment(
                      value: common.ActionType.ACTION_TYPE_ALLOW,
                      label: Text('Allow'),
                      icon: Icon(Icons.check_circle),
                    ),
                  ],
                  selected: {action},
                  onSelectionChanged: (v) =>
                      setDialogState(() => action = v.first),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: durationSeconds,
                  decoration: const InputDecoration(labelText: 'Duration'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Permanent')),
                    DropdownMenuItem(value: 3600, child: Text('1 hour')),
                    DropdownMenuItem(value: 86400, child: Text('24 hours')),
                    DropdownMenuItem(value: 604800, child: Text('7 days')),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => durationSeconds = v ?? 0),
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
                if (ipController.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                try {
                  final client = ref.read(logicServiceProvider);
                  final resp =
                      await client.addGlobalRule(local.AddGlobalRuleRequest(
                    nodeId: widget.nodeId,
                    ip: ipController.text.trim(),
                    action: action,
                    durationSeconds: Int64(durationSeconds),
                  ));
                  if (!resp.success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${resp.error}')),
                    );
                    return;
                  }
                  _refreshRules();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Global rule added')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error: ${friendlyError(e)}')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteRule(proxy.GlobalRule rule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Global Rule'),
        content: Text('Remove rule "${rule.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!await biometricGuard(ref)) return;
      try {
        final client = ref.read(logicServiceProvider);
        final resp =
            await client.removeGlobalRule(local.RemoveGlobalRuleRequest(
          nodeId: widget.nodeId,
          ruleId: rule.id,
        ));
        if (!resp.success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${resp.error}')),
          );
          return;
        }
        _refreshRules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Global rule removed')),
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

  String _formatExpiry(proxy.GlobalRule rule) {
    if (!rule.hasExpiresAt() ||
        rule.expiresAt.seconds == Int64.ZERO) {
      return 'Permanent';
    }
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        rule.expiresAt.seconds.toInt() * 1000);
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    if (remaining.inDays > 0) return 'Expires in ${remaining.inDays}d';
    if (remaining.inHours > 0) return 'Expires in ${remaining.inHours}h';
    if (remaining.inMinutes > 0) return 'Expires in ${remaining.inMinutes}m';
    return 'Expires soon';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Global Rules'),
            Text(
              widget.nodeName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRules,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    // Info card
                    Card(
                      margin: const EdgeInsets.all(12),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'These rules apply to ALL proxies on this node. '
                                'Global BLOCK has highest priority. Global ALLOW '
                                'prevents per-proxy blocks.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Rules list
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshRules,
                        child: _rules.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 120),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.shield_outlined,
                                            size: 64, color: Colors.grey),
                                        SizedBox(height: 16),
                                        Text('No global rules'),
                                        Text('Tap + to add a rule',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: _rules.length,
                                itemBuilder: (context, index) {
                                  final rule = _rules[index];
                                  final isBlock = rule.action ==
                                      common.ActionType.ACTION_TYPE_BLOCK;
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isBlock
                                            ? Colors.red.shade100
                                            : Colors.green.shade100,
                                        child: Icon(
                                          isBlock
                                              ? Icons.block
                                              : Icons.check_circle,
                                          color: isBlock
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                      title: Text(rule.name),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(rule.sourceIp,
                                              style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 12)),
                                          Text(_formatExpiry(rule),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                      isThreeLine: true,
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () => _deleteRule(rule),
                                        tooltip: 'Remove',
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
