import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/common/common.pb.dart' as common;
import 'package:nitella_app/proxy/proxy.pb.dart' as proxy;
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import '../main.dart';
import '../utils/error_helper.dart';
import '../utils/biometric_guard.dart';
import '../utils/rule_composer_options.dart';

class RulesScreen extends ConsumerStatefulWidget {
  final String nodeId;
  final String proxyId;
  final String proxyName;

  const RulesScreen({
    super.key,
    required this.nodeId,
    required this.proxyId,
    required this.proxyName,
  });

  @override
  ConsumerState<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends ConsumerState<RulesScreen> {
  List<proxy.Rule> _rules = [];
  local.RuleComposerPolicy? _composerPolicy;
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
      final resp = await client.listRules(local.ListRulesRequest(
        nodeId: widget.nodeId,
        proxyId: widget.proxyId,
      ));
      if (mounted) {
        setState(() {
          _rules = resp.rules;
          _composerPolicy =
              resp.hasComposerPolicy() ? resp.composerPolicy : null;
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

  /// Builds the common form fields shared between add and edit rule dialogs.
  List<Widget> _buildRuleFormFields({
    required TextEditingController nameController,
    required common.ActionType action,
    required List<common.ActionType> allowedActions,
    required ValueChanged<common.ActionType> onActionChanged,
  }) {
    final actionOptions =
        allowedActions.isNotEmpty ? allowedActions : _actionOptions();
    return [
      TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: 'Rule Name',
          hintText: 'e.g., Block China',
        ),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<common.ActionType>(
        initialValue: action,
        decoration: const InputDecoration(labelText: 'Action'),
        items: actionOptions
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(_actionOptionLabel(item)),
                ))
            .toList(),
        onChanged: (v) => onActionChanged(v!),
      ),
    ];
  }

  Future<void> _showAddRuleDialog() async {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final backendController = TextEditingController();
    common.ConditionType conditionType = _defaultConditionType();
    common.Operator conditionOp = _defaultOperator(conditionType);
    bool conditionNegate = false;
    common.ActionType action = _defaultAction();
    int priority = _defaultRulePriority();
    List<proxy.Condition> conditions = [];
    bool showAdvanced = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildRuleFormFields(
                  nameController: nameController,
                  action: action,
                  allowedActions: _actionOptions(include: action),
                  onActionChanged: (v) => setDialogState(() => action = v),
                ),
                const SizedBox(height: 16),

                // Condition section header
                Row(
                  children: [
                    const Text('Condition',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (conditions.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add More'),
                        onPressed: () {
                          setDialogState(() {
                            conditions.add(proxy.Condition(
                              type: conditionType,
                              op: conditionOp,
                              value: valueController.text,
                              negate: conditionNegate,
                            ));
                            valueController.clear();
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Existing conditions chips
                if (conditions.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: conditions.asMap().entries.map((entry) {
                      final c = entry.value;
                      return Chip(
                        label: Text(
                          '${c.negate ? 'NOT ' : ''}${_conditionTypeLabel(c.type)} ${_operatorLabel(c.op)} ${c.value}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setDialogState(() => conditions.removeAt(entry.key));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                ],

                // Condition type dropdown
                DropdownButtonFormField<common.ConditionType>(
                  initialValue: conditionType,
                  decoration:
                      const InputDecoration(labelText: 'Condition Type'),
                  isExpanded: true,
                  items: _conditionTypeOptions(include: conditionType)
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(_conditionTypeLabel(type)),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() {
                    conditionType = v!;
                    // Reset operator to default for new type
                    conditionOp = _defaultOperator(conditionType);
                  }),
                ),
                const SizedBox(height: 12),

                // Operator dropdown
                DropdownButtonFormField<common.Operator>(
                  key: ValueKey(
                      'operator-${conditionType.name}-${conditionOp.name}'),
                  initialValue: conditionOp,
                  decoration: const InputDecoration(labelText: 'Operator'),
                  items: _operatorsForType(conditionType)
                      .map((op) => DropdownMenuItem(
                            value: op,
                            child: Text(_operatorLabel(op)),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() => conditionOp = v!),
                ),
                const SizedBox(height: 8),

                // Negate toggle
                CheckboxListTile(
                  title: const Text('Negate (NOT)',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Invert this condition',
                      style: TextStyle(fontSize: 12)),
                  value: conditionNegate,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) =>
                      setDialogState(() => conditionNegate = v ?? false),
                ),
                const SizedBox(height: 8),

                // Value field with context-aware hint
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: 'Value',
                    hintText: _getValueHint(conditionType),
                    border: const OutlineInputBorder(),
                  ),
                ),

                // Advanced toggle
                const SizedBox(height: 12),
                InkWell(
                  onTap: () =>
                      setDialogState(() => showAdvanced = !showAdvanced),
                  child: Row(
                    children: [
                      Icon(
                          showAdvanced ? Icons.expand_less : Icons.expand_more),
                      const SizedBox(width: 8),
                      const Text('Advanced'),
                    ],
                  ),
                ),
                if (showAdvanced) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Priority: '),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(isDense: true),
                          controller: TextEditingController(text: '$priority'),
                          onChanged: (v) => priority = int.tryParse(v) ?? 100,
                        ),
                      ),
                      const Spacer(),
                      const Text('(higher = first)',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: backendController,
                    decoration: const InputDecoration(
                      labelText: 'Target Backend (optional)',
                      hintText: 'e.g., 192.168.1.100:8080',
                    ),
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
                  // Build final conditions list
                  final allConditions = [...conditions];
                  if (valueController.text.isNotEmpty) {
                    allConditions.add(proxy.Condition(
                      type: conditionType,
                      op: conditionOp,
                      value: valueController.text,
                      negate: conditionNegate,
                    ));
                  }

                  final rule = proxy.Rule(
                    name: nameController.text.trim(),
                    priority: priority,
                    action: action,
                    targetBackend: backendController.text,
                    conditions: allConditions,
                    enabled: true,
                  );

                  final client = ref.read(logicServiceProvider);
                  await client.addRule(local.AddRuleRequest(
                    nodeId: widget.nodeId,
                    proxyId: widget.proxyId,
                    rule: rule,
                  ));

                  _refreshRules();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rule added')),
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
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditRuleDialog(proxy.Rule existing) async {
    final nameController = TextEditingController(text: existing.name);
    final backendController =
        TextEditingController(text: existing.targetBackend);
    final expressionController =
        TextEditingController(text: existing.expression);
    int priority = existing.priority;
    common.ActionType action = existing.action;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildRuleFormFields(
                  nameController: nameController,
                  action: action,
                  allowedActions: _actionOptions(include: existing.action),
                  onActionChanged: (v) => setDialogState(() => action = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Priority: '),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true),
                        controller: TextEditingController(text: '$priority'),
                        onChanged: (v) => priority = int.tryParse(v) ?? 100,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: backendController,
                  decoration: const InputDecoration(
                    labelText: 'Target Backend (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: expressionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Expression',
                    helperText:
                        'Advanced: raw expression (overrides conditions)',
                    border: OutlineInputBorder(),
                  ),
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
                  final rule = proxy.Rule(
                    name: nameController.text,
                    priority: priority,
                    action: action,
                    targetBackend: backendController.text,
                    expression: expressionController.text,
                    enabled: true,
                  )..id = existing.id;

                  final client = ref.read(logicServiceProvider);
                  await client.updateRule(local.UpdateRuleRequest(
                    nodeId: widget.nodeId,
                    proxyId: widget.proxyId,
                    rule: rule,
                  ));

                  _refreshRules();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rule updated')),
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

  Future<void> _deleteRule(proxy.Rule rule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rule'),
        content: Text('Delete rule "${rule.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!await biometricGuard(ref)) return;
      try {
        final client = ref.read(logicServiceProvider);
        await client.removeRule(local.RemoveRuleRequest(
          nodeId: widget.nodeId,
          proxyId: widget.proxyId,
          ruleId: rule.id,
        ));
        _refreshRules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rule deleted')),
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

  /// Show quick add rule bottom sheet for common operations.
  void _showQuickAddRuleSheet({String? ip, String? country, String? isp}) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Quick Add Rule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            if (ip != null && ip.isNotEmpty) ...[
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Block this IP'),
                subtitle: Text(ip),
                onTap: () {
                  Navigator.pop(ctx);
                  _quickAddRule(
                    'Block $ip',
                    common.ActionType.ACTION_TYPE_BLOCK,
                    common.ConditionType.CONDITION_TYPE_SOURCE_IP,
                    ip,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Block IP Range (CIDR)'),
                subtitle: Text('$ip -> /24'),
                onTap: () {
                  Navigator.pop(ctx);
                  _quickAddRule(
                    'Block subnet (/24)',
                    common.ActionType.ACTION_TYPE_BLOCK,
                    common.ConditionType.CONDITION_TYPE_SOURCE_IP,
                    ip,
                    sourceIpToCidr24: true,
                  );
                },
              ),
            ],
            if (country != null && country.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Block Country'),
                subtitle: Text(country),
                onTap: () {
                  Navigator.pop(ctx);
                  _quickAddRule(
                    'Block Country: $country',
                    common.ActionType.ACTION_TYPE_BLOCK,
                    common.ConditionType.CONDITION_TYPE_GEO_COUNTRY,
                    country,
                  );
                },
              ),
            if (isp != null && isp.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Block ISP'),
                subtitle: Text(isp),
                onTap: () {
                  Navigator.pop(ctx);
                  _quickAddRule(
                    'Block ISP: $isp',
                    common.ActionType.ACTION_TYPE_BLOCK,
                    common.ConditionType.CONDITION_TYPE_GEO_ISP,
                    isp,
                  );
                },
              ),
            const Divider(),
            if (ip != null && ip.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Allow this IP'),
                subtitle: Text(ip),
                onTap: () {
                  Navigator.pop(ctx);
                  _quickAddRule(
                    'Allow $ip',
                    common.ActionType.ACTION_TYPE_ALLOW,
                    common.ConditionType.CONDITION_TYPE_SOURCE_IP,
                    ip,
                  );
                },
              ),
            if (country != null && country.isNotEmpty)
              ListTile(
                leading:
                    const Icon(Icons.hourglass_empty, color: Colors.orange),
                title: const Text('Require Approval for Country'),
                subtitle: Text(country),
                onTap: () {
                  Navigator.pop(ctx);
                  _quickAddRule(
                    'Approve Country: $country',
                    common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL,
                    common.ConditionType.CONDITION_TYPE_GEO_COUNTRY,
                    country,
                  );
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Advanced Rule Editor'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddRuleDialog();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _quickAddRule(String uiLabel, common.ActionType action,
      common.ConditionType condType, String value,
      {bool sourceIpToCidr24 = false}) async {
    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.addQuickRule(local.AddQuickRuleRequest(
        nodeId: widget.nodeId,
        proxyId: widget.proxyId,
        // Backend owns default quick-rule naming to keep business logic centralized.
        name: '',
        action: action,
        conditionType: condType,
        value: value,
        sourceIpToCidr24: sourceIpToCidr24,
      ));
      if (!resp.success) {
        throw Exception(
            resp.error.isNotEmpty ? resp.error : 'Failed to add rule');
      }
      _refreshRules();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rule added: $uiLabel')),
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

  // --- Helper methods ---

  List<common.ActionType> _actionOptions({common.ActionType? include}) {
    final options = <common.ActionType>[];
    if (_composerPolicy != null && _composerPolicy!.allowedActions.isNotEmpty) {
      for (final action in _composerPolicy!.allowedActions) {
        if (action == common.ActionType.ACTION_TYPE_UNSPECIFIED) continue;
        if (!options.contains(action)) {
          options.add(action);
        }
      }
    }
    if (options.isEmpty) {
      options.addAll(defaultRuleActionOptions());
    }
    if (include != null &&
        include != common.ActionType.ACTION_TYPE_UNSPECIFIED &&
        !options.contains(include)) {
      options.add(include);
    }
    return options;
  }

  List<common.ConditionType> _conditionTypeOptions(
      {common.ConditionType? include}) {
    final options = <common.ConditionType>[];
    if (_composerPolicy != null &&
        _composerPolicy!.conditionPolicies.isNotEmpty) {
      for (final conditionPolicy in _composerPolicy!.conditionPolicies) {
        final conditionType = conditionPolicy.conditionType;
        if (conditionType == common.ConditionType.CONDITION_TYPE_UNSPECIFIED) {
          continue;
        }
        if (!options.contains(conditionType)) {
          options.add(conditionType);
        }
      }
    }
    if (options.isEmpty) {
      options.addAll(defaultRuleConditionTypeOptions());
    }
    if (options.isEmpty) {
      options.add(common.ConditionType.CONDITION_TYPE_SOURCE_IP);
    }
    if (include != null &&
        include != common.ConditionType.CONDITION_TYPE_UNSPECIFIED &&
        !options.contains(include)) {
      options.add(include);
    }
    return options;
  }

  local.RuleComposerConditionPolicy? _conditionPolicyForType(
      common.ConditionType type) {
    if (_composerPolicy == null) return null;
    for (final conditionPolicy in _composerPolicy!.conditionPolicies) {
      if (conditionPolicy.conditionType == type) {
        return conditionPolicy;
      }
    }
    return null;
  }

  common.ConditionType _defaultConditionType() {
    final options = _conditionTypeOptions();
    return options.first;
  }

  String _conditionTypeLabel(common.ConditionType type) {
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
        return 'TLS';
      case common.ConditionType.CONDITION_TYPE_TLS_CN:
        return 'TLS CN';
      case common.ConditionType.CONDITION_TYPE_TLS_CA:
        return 'TLS CA';
      case common.ConditionType.CONDITION_TYPE_TLS_OU:
        return 'TLS OU';
      case common.ConditionType.CONDITION_TYPE_TLS_SAN:
        return 'TLS SAN';
      case common.ConditionType.CONDITION_TYPE_TLS_FINGERPRINT:
        return 'TLS FP';
      case common.ConditionType.CONDITION_TYPE_TLS_SERIAL:
        return 'TLS Serial';
      case common.ConditionType.CONDITION_TYPE_TIME_RANGE:
        return 'Time Range';
      default:
        return _humanizeEnumName(type.name, 'CONDITION_TYPE_');
    }
  }

  String _operatorLabel(common.Operator op) {
    switch (op) {
      case common.Operator.OPERATOR_EQ:
        return 'Equals';
      case common.Operator.OPERATOR_CONTAINS:
        return 'Contains';
      case common.Operator.OPERATOR_REGEX:
        return 'Regex';
      case common.Operator.OPERATOR_CIDR:
        return 'CIDR';
      default:
        return _humanizeEnumName(op.name, 'OPERATOR_');
    }
  }

  List<common.Operator> _operatorsForType(common.ConditionType type) {
    final conditionPolicy = _conditionPolicyForType(type);
    if (conditionPolicy != null) {
      final operators = conditionPolicy.operators
          .where((operator) => operator != common.Operator.OPERATOR_UNSPECIFIED)
          .toList();
      if (operators.isNotEmpty) {
        return operators;
      }
      if (conditionPolicy.hasDefaultOperator() &&
          conditionPolicy.defaultOperator !=
              common.Operator.OPERATOR_UNSPECIFIED) {
        return [conditionPolicy.defaultOperator];
      }
    }
    return [common.Operator.OPERATOR_EQ];
  }

  common.Operator _defaultOperator(common.ConditionType type) {
    final conditionPolicy = _conditionPolicyForType(type);
    if (conditionPolicy != null &&
        conditionPolicy.hasDefaultOperator() &&
        conditionPolicy.defaultOperator !=
            common.Operator.OPERATOR_UNSPECIFIED) {
      return conditionPolicy.defaultOperator;
    }
    return _operatorsForType(type).first;
  }

  String _getValueHint(common.ConditionType type) {
    final conditionPolicy = _conditionPolicyForType(type);
    if (conditionPolicy != null && conditionPolicy.hasValueHint()) {
      return conditionPolicy.valueHint;
    }
    return '';
  }

  common.ActionType _defaultAction() {
    final options = _actionOptions();
    return options.first;
  }

  int _defaultRulePriority() {
    if (_composerPolicy != null && _composerPolicy!.hasDefaultPriority()) {
      return _composerPolicy!.defaultPriority;
    }
    return 100;
  }

  String _actionOptionLabel(common.ActionType action) {
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
        .map((part) =>
            '${part.substring(0, 1)}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _actionLabel(common.ActionType action) {
    switch (action) {
      case common.ActionType.ACTION_TYPE_ALLOW:
        return 'ALLOW';
      case common.ActionType.ACTION_TYPE_BLOCK:
        return 'BLOCK';
      case common.ActionType.ACTION_TYPE_MOCK:
        return 'MOCK';
      case common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL:
        return '2FA';
      default:
        return '?';
    }
  }

  Color _actionColor(common.ActionType action) {
    switch (action) {
      case common.ActionType.ACTION_TYPE_ALLOW:
        return Colors.green;
      case common.ActionType.ACTION_TYPE_BLOCK:
        return Colors.red;
      case common.ActionType.ACTION_TYPE_MOCK:
        return Colors.orange;
      case common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _describeRule(proxy.Rule rule) {
    // Show conditions if available, otherwise show expression
    if (rule.conditions.isNotEmpty) {
      return rule.conditions.map((c) {
        return '${_conditionTypeLabel(c.type)} ${_operatorLabel(c.op)} ${c.value}';
      }).join(' AND ');
    }
    if (rule.expression.isNotEmpty) return rule.expression;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rules: ${widget.proxyName}'),
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
              : RefreshIndicator(
                  onRefresh: _refreshRules,
                  child: _rules.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.rule,
                                      size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('No rules configured'),
                                  Text('Tap + to add a rule',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _rules.length,
                          itemBuilder: (context, index) {
                            final rule = _rules[index];
                            final desc = _describeRule(rule);
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _actionColor(rule.action),
                                  child: Text(
                                    _actionLabel(rule.action)[0],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(rule.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Priority: ${rule.priority}'),
                                    if (desc.isNotEmpty)
                                      Text(
                                        desc,
                                        style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 11),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (rule.targetBackend.isNotEmpty)
                                      Text('\u2192 ${rule.targetBackend}',
                                          style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 12)),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: Colors.blue),
                                      onPressed: () =>
                                          _showEditRuleDialog(rule),
                                      tooltip: 'Edit Rule',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () => _deleteRule(rule),
                                      tooltip: 'Delete Rule',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddRuleSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
