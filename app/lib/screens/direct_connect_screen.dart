import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import '../main.dart';
import '../utils/error_helper.dart';

class DirectConnectScreen extends ConsumerStatefulWidget {
  const DirectConnectScreen({super.key});

  @override
  ConsumerState<DirectConnectScreen> createState() =>
      _DirectConnectScreenState();
}

class _DirectConnectScreenState extends ConsumerState<DirectConnectScreen> {
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _tokenController = TextEditingController();
  final _caPemController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _tokenController.dispose();
    _caPemController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(() => _error = 'Please enter the node address');
      return;
    }

    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _error = 'Please enter the token');
      return;
    }

    final caPem = _caPemController.text.trim();
    if (caPem.isEmpty) {
      setState(
          () => _error = 'Please paste the node admin CA certificate (PEM)');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(logicServiceProvider);

      // Step 1: Test the connection first
      final testResp = await client.testDirectConnection(
        local.TestDirectConnectionRequest(
          address: address,
          token: token,
          caPem: caPem,
        ),
      );

      if (!testResp.success) {
        if (mounted) {
          setState(() {
            _error = testResp.error.isNotEmpty
                ? testResp.error
                : 'Connection test failed';
            _isLoading = false;
          });
        }
        return;
      }

      if (!mounted) return;

      // Step 2: Show test results and ask for confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Node Found'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (testResp.emojiHash.isNotEmpty)
                Text(
                  testResp.emojiHash,
                  style: const TextStyle(fontSize: 32),
                ),
              const SizedBox(height: 12),
              if (testResp.nodeHostname.isNotEmpty)
                _TestResultRow(label: 'Hostname', value: testResp.nodeHostname),
              if (testResp.nodeVersion.isNotEmpty)
                _TestResultRow(label: 'Version', value: testResp.nodeVersion),
              _TestResultRow(
                label: 'Proxies',
                value: '${testResp.proxyCount}',
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
              child: const Text('Add Node'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) {
        setState(() => _isLoading = false);
        return;
      }

      // Step 3: Add the node
      final name = _nameController.text.trim();
      final addResp = await client.addNodeDirect(
        local.AddNodeDirectRequest(
          name: name.isNotEmpty ? name : address,
          address: address,
          token: token,
          caPem: caPem,
        ),
      );

      if (mounted) {
        if (addResp.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Node added successfully')),
          );
          Navigator.pop(context, true);
        } else {
          setState(() {
            _error =
                addResp.error.isNotEmpty ? addResp.error : 'Failed to add node';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = friendlyError(e);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Connect'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Direct connection requires the node to be reachable '
                      'from this device (same network or VPN).',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Node address
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Node Address',
                hintText: '192.168.1.100:50053',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.dns),
                helperText: 'The admin API address of the node',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            // Node name (optional)
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name (optional)',
                hintText: 'node-local-dev',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Admin Token',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
                helperText: 'Token configured on nitellad admin API',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _caPemController,
              decoration: const InputDecoration(
                labelText: 'Admin CA Certificate (PEM)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                helperText: 'Paste the node admin CA certificate contents',
              ),
              minLines: 4,
              maxLines: 8,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.security, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connection and certificate validation are enforced by MobileLogicService.',
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Error display
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Connect button
            FilledButton.icon(
              onPressed: _isLoading ? null : _connect,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.link),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _isLoading ? 'Connecting...' : 'Connect',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _TestResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
