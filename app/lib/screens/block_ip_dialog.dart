import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import '../main.dart';

/// Dialog for blocking an IP address.
/// All validation and rule creation logic is handled by the Go backend.
class BlockIPDialog extends ConsumerStatefulWidget {
  final List<local.NodeInfo> nodes;

  const BlockIPDialog({super.key, required this.nodes});

  @override
  ConsumerState<BlockIPDialog> createState() => _BlockIPDialogState();
}

class _BlockIPDialogState extends ConsumerState<BlockIPDialog> {
  final _ipController = TextEditingController();
  bool _applyToAll = true;
  String? _selectedNodeId;
  bool _isBlocking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.nodes.isNotEmpty) {
      _selectedNodeId = widget.nodes.first.nodeId;
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _blockIP() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      setState(() => _error = 'IP address is required');
      return;
    }

    setState(() {
      _isBlocking = true;
      _error = null;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final response = await client.blockIP(local.BlockIPRequest(
        nodeId: _applyToAll ? '' : (_selectedNodeId ?? ''),
        ip: ip,
        applyToAllNodes: _applyToAll,
      ));

      if (!response.success) {
        setState(() {
          _error = response.error;
          _isBlocking = false;
        });
        return;
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_applyToAll
                ? 'Blocked $ip on ${response.rulesCreated} nodes'
                : 'Blocked $ip'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isBlocking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Block IP'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ipController,
            decoration: InputDecoration(
              labelText: 'IP Address',
              hintText: '192.168.1.1 or 10.0.0.0/8',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            keyboardType: TextInputType.text,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          const Text('Apply to:'),
          const SizedBox(height: 8),
          // Using SegmentedButton as modern replacement for Radio
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('All nodes')),
              ButtonSegment(value: false, label: Text('Selected node')),
            ],
            selected: {_applyToAll},
            onSelectionChanged: (v) => setState(() => _applyToAll = v.first),
            showSelectedIcon: false,
          ),
          if (!_applyToAll && widget.nodes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: DropdownButton<String>(
                value: _selectedNodeId,
                isExpanded: true,
                items: widget.nodes.map((node) {
                  return DropdownMenuItem(
                    value: node.nodeId,
                    child: Text(
                      node.name.isNotEmpty ? node.name : node.nodeId,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedNodeId = v),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isBlocking ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isBlocking ? null : _blockIP,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isBlocking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Block'),
        ),
      ],
    );
  }
}
