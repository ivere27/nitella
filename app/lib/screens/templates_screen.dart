import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'package:nitella_app/widgets/reliability_notice.dart';
import '../main.dart';
import '../utils/error_helper.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<local.Template> _templates = [];
  List<local.NodeInfo> _nodes = [];
  bool _isLoading = true;
  String? _error;
  bool _includePublic = true;
  bool _templateOpsDegraded = false;
  String _templateOpsReason = '';
  bool _syncInProgress = false;
  final List<ReliabilityAuditEntry> _templateOpsAuditLog = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final templatesResp = await client.listTemplates(
        local.ListTemplatesRequest(includePublic: _includePublic),
      );
      final nodesResp = await client
          .getHubDashboardSnapshot(local.GetHubDashboardSnapshotRequest());

      if (mounted) {
        setState(() {
          _templates = templatesResp.templates;
          _nodes = nodesResp.nodes;
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

  List<local.Template> get _proxyTemplates =>
      _templates.where((t) => t.proxies.isNotEmpty).toList();

  List<local.Template> get _ruleTemplates =>
      _templates.where((t) => t.proxies.isEmpty).toList();

  void _recordTemplateOpsEvent({
    required String label,
    required String message,
    required String detail,
    required bool degraded,
  }) {
    if (!mounted) return;
    setState(() {
      _templateOpsAuditLog.insert(
        0,
        ReliabilityAuditEntry(
          timestamp: DateTime.now(),
          label: label,
          message: message,
          detail: detail,
          degraded: degraded,
        ),
      );
      if (_templateOpsAuditLog.length > 100) {
        _templateOpsAuditLog.removeRange(100, _templateOpsAuditLog.length);
      }
      _templateOpsDegraded = degraded;
      _templateOpsReason = message;
    });
  }

  void _showTemplateSnack(String message, {bool warning = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: warning ? Colors.orange.shade700 : null,
      ),
    );
  }

  String _nodeLabel(String nodeId) {
    for (final node in _nodes) {
      if (node.nodeId == nodeId) {
        return node.name.isNotEmpty ? node.name : node.nodeId;
      }
    }
    return nodeId;
  }

  Future<void> _createTemplate() async {
    if (_nodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No nodes available to create template from')),
      );
      return;
    }

    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedNodeId = _nodes.first.nodeId;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Template'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                    hintText: 'e.g., Web Server Setup',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Standard web server proxy configuration',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedNodeId,
                  decoration: const InputDecoration(
                    labelText: 'Source Node',
                    border: OutlineInputBorder(),
                  ),
                  items: _nodes.map((n) {
                    final label = n.name.isNotEmpty ? n.name : n.nodeId;
                    return DropdownMenuItem(
                        value: n.nodeId, child: Text(label));
                  }).toList(),
                  onChanged: (v) => setDialogState(() => selectedNodeId = v!),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will copy all proxy configurations from the selected node.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      try {
        final client = ref.read(logicServiceProvider);
        await client.createTemplate(local.CreateTemplateRequest(
          name: nameController.text,
          description: descController.text,
          nodeId: selectedNodeId,
        ));
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template created')),
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

  Future<void> _applyTemplate(local.Template template) async {
    if (_nodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No nodes available')),
      );
      return;
    }

    String selectedNodeId = _nodes.first.nodeId;
    bool overwrite = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Apply Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Template: ${template.name}'),
              if (template.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  template.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedNodeId,
                decoration: const InputDecoration(
                  labelText: 'Target Node',
                  border: OutlineInputBorder(),
                ),
                items: _nodes.map((n) {
                  final label = n.name.isNotEmpty ? n.name : n.nodeId;
                  return DropdownMenuItem(value: n.nodeId, child: Text(label));
                }).toList(),
                onChanged: (v) => setDialogState(() => selectedNodeId = v!),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: overwrite,
                onChanged: (v) => setDialogState(() => overwrite = v ?? false),
                title: const Text('Replace existing proxies'),
                subtitle: const Text('Remove current proxies before applying'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
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
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      try {
        final client = ref.read(logicServiceProvider);
        final resp = await client.applyTemplate(local.ApplyTemplateRequest(
          templateId: template.templateId,
          nodeId: selectedNodeId,
          overwrite: overwrite,
        ));
        final expectedProxyCount = template.proxies.length;
        final expectedRuleCount = template.proxies.fold<int>(
          0,
          (sum, proxyTemplate) => sum + proxyTemplate.rules.length,
        );
        final proxiesCreated = resp.proxiesCreated;
        final rulesCreated = resp.rulesCreated;

        if (!resp.success) {
          final err =
              resp.error.trim().isNotEmpty ? resp.error.trim() : 'Apply failed';
          _recordTemplateOpsEvent(
            label: 'apply template',
            message: err,
            detail:
                'template: ${template.name}; node: ${_nodeLabel(selectedNodeId)}',
            degraded: true,
          );
          _showTemplateSnack('Apply failed: $err', warning: true);
          return;
        }

        final partialApply =
            (expectedProxyCount > 0 && proxiesCreated < expectedProxyCount) ||
                (expectedRuleCount > 0 && rulesCreated < expectedRuleCount);
        if (partialApply) {
          final message =
              'Applied partially: $proxiesCreated/$expectedProxyCount proxies, $rulesCreated/$expectedRuleCount rules';
          _recordTemplateOpsEvent(
            label: 'apply template',
            message: message,
            detail:
                'template: ${template.name}; node: ${_nodeLabel(selectedNodeId)}; overwrite: $overwrite',
            degraded: true,
          );
          _showTemplateSnack(message, warning: true);
          return;
        }

        final message = 'Applied: $proxiesCreated proxies, $rulesCreated rules';
        _recordTemplateOpsEvent(
          label: 'apply template',
          message: message,
          detail:
              'template: ${template.name}; node: ${_nodeLabel(selectedNodeId)}; overwrite: $overwrite',
          degraded: false,
        );
        _showTemplateSnack(message);
      } catch (e) {
        final err = friendlyError(e);
        _recordTemplateOpsEvent(
          label: 'apply template',
          message: err,
          detail:
              'template: ${template.name}; node: ${_nodeLabel(selectedNodeId)}',
          degraded: true,
        );
        _showTemplateSnack('Apply failed: $err', warning: true);
      }
    }
  }

  Future<void> _deleteTemplate(local.Template template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Template?'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final client = ref.read(logicServiceProvider);
        await client.deleteTemplate(
          local.DeleteTemplateRequest(templateId: template.templateId),
        );
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template deleted')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.router), text: 'Proxies'),
            Tab(icon: Icon(Icons.rule), text: 'Rules'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sync') {
                _syncTemplates();
              } else if (value == 'toggle_public') {
                setState(() => _includePublic = !_includePublic);
                _loadData();
              } else if (value == 'import_yaml') {
                _importFromClipboard();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'toggle_public',
                child: Row(
                  children: [
                    Icon(
                      _includePublic
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Show Public Templates'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sync',
                enabled: !_syncInProgress,
                child: Row(
                  children: [
                    _syncInProgress
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync, size: 20),
                    const SizedBox(width: 8),
                    Text(_syncInProgress ? 'Syncing...' : 'Sync with Hub'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import_yaml',
                child: Row(
                  children: [
                    Icon(Icons.paste, size: 20),
                    SizedBox(width: 8),
                    Text('Import from Clipboard (YAML)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_templateOpsDegraded)
            ReliabilityNoticeBanner(
              title: 'Template operations degraded',
              message: _templateOpsReason,
              degraded: true,
            ),
          ReliabilityAuditPanel(
            title: 'Template Ops Audit (Session)',
            entries: _templateOpsAuditLog,
            onClear: () {
              setState(() {
                _templateOpsAuditLog.clear();
              });
            },
          ),
          Expanded(
            child: _isLoading
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
                              onPressed: _loadData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTemplateList(_proxyTemplates, 'proxy'),
                          _buildTemplateList(_ruleTemplates, 'rule'),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTemplate,
        icon: const Icon(Icons.add),
        label: const Text('Create Template'),
      ),
    );
  }

  Widget _buildTemplateList(List<local.Template> templates, String type) {
    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'proxy' ? Icons.router_outlined : Icons.rule_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type == 'proxy' ? 'Proxy' : 'Rule'} Templates',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Create templates to easily deploy\nconfigurations to multiple nodes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showTemplateDetails(template),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            template.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (template.isPublic)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Public',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'apply') {
                              _applyTemplate(template);
                            } else if (value == 'export_yaml') {
                              _exportToClipboard(template);
                            } else if (value == 'delete') {
                              _deleteTemplate(template);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'apply',
                              child: Row(
                                children: [
                                  Icon(Icons.play_arrow, size: 20),
                                  SizedBox(width: 8),
                                  Text('Apply to Node'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'export_yaml',
                              child: Row(
                                children: [
                                  Icon(Icons.copy, size: 20),
                                  SizedBox(width: 8),
                                  Text('Export as YAML'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (template.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        template.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.router,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${template.proxies.length} proxies',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.download,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${template.downloads} uses',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        if (template.tags.isNotEmpty) ...[
                          const Spacer(),
                          ...template.tags.take(2).map((tag) => Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              )),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTemplateDetails(local.Template template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  if (template.description.isNotEmpty) ...[
                    Text(
                      template.description,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Proxies (${template.proxies.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...template.proxies.map((p) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.router),
                          title: Text(p.name),
                          subtitle: Text(p.listenAddr),
                          trailing: Text(
                            p.defaultAction.name.split('_').last,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getActionColor(p.defaultAction),
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _deleteTemplate(template);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _exportToClipboard(template);
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Export'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _applyTemplate(template);
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(dynamic action) {
    final name = action.toString();
    if (name.contains('ALLOW')) return Colors.green;
    if (name.contains('BLOCK')) return Colors.red;
    if (name.contains('APPROVAL')) return Colors.orange;
    return Colors.grey;
  }

  Future<void> _exportToClipboard(local.Template template) async {
    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.exportTemplateYaml(
        local.ExportTemplateYamlRequest(templateId: template.templateId),
      );
      if (!resp.success || resp.yaml.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${resp.error}')),
        );
        return;
      }

      await Clipboard.setData(ClipboardData(text: resp.yaml));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template YAML copied to clipboard')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: ${friendlyError(e)}')),
      );
    }
  }

  Future<void> _importFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null || data.text == null || data.text!.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard is empty')),
        );
      }
      return;
    }

    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.importTemplateYaml(
        local.ImportTemplateYamlRequest(yaml: data.text!),
      );
      if (!resp.success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: ${resp.error}')),
        );
        return;
      }

      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported template: ${resp.name} (${resp.proxyCount} proxies)',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: ${friendlyError(e)}')),
      );
    }
  }

  Future<void> _syncTemplates() async {
    if (_syncInProgress) return;
    setState(() => _syncInProgress = true);
    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.syncTemplates(Empty());
      if (!mounted) return;
      final uploaded = resp.uploaded;
      final downloaded = resp.downloaded;
      final conflicts = resp.conflicts;

      if (conflicts > 0) {
        final message =
            'Sync completed with $conflicts conflicts: $uploaded uploaded, $downloaded downloaded';
        _recordTemplateOpsEvent(
          label: 'sync templates',
          message: message,
          detail: 'public enabled: $_includePublic',
          degraded: true,
        );
        _showTemplateSnack(message, warning: true);
      } else {
        final message = uploaded == 0 && downloaded == 0
            ? 'No template changes found during sync'
            : 'Synced: $uploaded uploaded, $downloaded downloaded';
        _recordTemplateOpsEvent(
          label: 'sync templates',
          message: message,
          detail: 'public enabled: $_includePublic',
          degraded: false,
        );
        _showTemplateSnack(message);
      }
      await _loadData();
    } catch (e) {
      final err = friendlyError(e);
      _recordTemplateOpsEvent(
        label: 'sync templates',
        message: err,
        detail: 'public enabled: $_includePublic',
        degraded: true,
      );
      _showTemplateSnack('Sync failed: $err', warning: true);
    } finally {
      if (mounted) {
        setState(() => _syncInProgress = false);
      }
    }
  }
}
