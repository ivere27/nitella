import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/common/common.pbenum.dart' as common;
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart';
import '../main.dart';
import 'settings_screen.dart';

class P2PSettingsScreen extends ConsumerStatefulWidget {
  const P2PSettingsScreen({super.key});

  @override
  ConsumerState<P2PSettingsScreen> createState() => _P2PSettingsScreenState();
}

class _P2PSettingsScreenState extends ConsumerState<P2PSettingsScreen> {
  bool _isLoading = true;

  List<String> _stunServers = [];
  String _turnServer = '';
  String _turnUsername = '';
  String _turnPassword = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final snapshot = await client.getP2PSettingsSnapshot(Empty());
      final status = snapshot.hasStatus() ? snapshot.status : local.P2PStatus();
      final settings =
          snapshot.hasSettings() ? snapshot.settings : local.Settings();
      final mode = status.mode.value;
      if (mode >= 1 && mode <= 3) {
        ref.read(p2pModeProvider.notifier).state = mode;
      }

      if (mounted) {
        setState(() {
          _stunServers = List<String>.from(settings.stunServers);
          _turnServer = settings.turnServer;
          _turnUsername = settings.turnUsername;
          _turnPassword = settings.turnPassword;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _stunServers = [];
          _turnServer = '';
          _turnUsername = '';
          _turnPassword = '';
          _isLoading = false;
        });
      }
    }
  }

  common.P2PMode _modeFromInt(int mode) {
    switch (mode) {
      case 1:
        return common.P2PMode.P2P_MODE_AUTO;
      case 2:
        return common.P2PMode.P2P_MODE_DIRECT;
      case 3:
      default:
        return common.P2PMode.P2P_MODE_HUB;
    }
  }

  Future<void> _saveIceSettings() async {
    try {
      final client = ref.read(logicServiceProvider);
      await client.updateSettings(local.UpdateSettingsRequest(
        settings: local.Settings(
          stunServers: _stunServers,
          turnServer: _turnServer,
          turnUsername: _turnUsername,
          turnPassword: _turnPassword,
        ),
        updateMask: FieldMask(paths: const [
          'stun_servers',
          'turn_server',
          'turn_username',
          'turn_password',
        ]),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save ICE settings: $e')),
      );
    }
  }

  Future<void> _setP2PMode(int mode) async {
    try {
      final client = ref.read(logicServiceProvider);
      await client
          .setP2PMode(local.SetP2PModeRequest(mode: _modeFromInt(mode)));
      ref.read(p2pModeProvider.notifier).state = mode;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update P2P mode: $e')),
      );
    }
  }

  void _addStunServer() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add STUN Server'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'STUN URL',
            hintText: 'stun:stun.example.com:3478',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                setState(() {
                  _stunServers.add(url);
                });
              }
              Navigator.pop(ctx);
              if (url.isNotEmpty) {
                await _saveIceSettings();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editTurnServer() {
    final serverController = TextEditingController(text: _turnServer);
    final usernameController = TextEditingController(text: _turnUsername);
    final passwordController = TextEditingController(text: _turnPassword);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('TURN Server'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: serverController,
                decoration: const InputDecoration(
                  labelText: 'TURN URL',
                  hintText: 'turn:turn.example.com:3478',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (optional)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (_turnServer.isNotEmpty)
            TextButton(
              onPressed: () async {
                setState(() {
                  _turnServer = '';
                  _turnUsername = '';
                  _turnPassword = '';
                });
                Navigator.pop(ctx);
                await _saveIceSettings();
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          FilledButton(
            onPressed: () async {
              setState(() {
                _turnServer = serverController.text.trim();
                _turnUsername = usernameController.text.trim();
                _turnPassword = passwordController.text;
              });
              Navigator.pop(ctx);
              await _saveIceSettings();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p2pMode = ref.watch(p2pModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('P2P Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Connection Mode
                  _buildSectionHeader('Connection Mode'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          RadioListTile<int>(
                            value: 1,
                            groupValue: p2pMode,
                            onChanged: (v) {
                              if (v != null) _setP2PMode(v);
                            },
                            title: const Text('Auto'),
                            subtitle: const Text(
                                'Try P2P first, fallback to Hub relay'),
                            secondary: const Icon(Icons.auto_mode),
                          ),
                          const Divider(height: 1),
                          RadioListTile<int>(
                            value: 2,
                            groupValue: p2pMode,
                            onChanged: (v) {
                              if (v != null) _setP2PMode(v);
                            },
                            title: const Text('P2P Only'),
                            subtitle: const Text('Direct connections only'),
                            secondary: const Icon(Icons.swap_horiz),
                          ),
                          const Divider(height: 1),
                          RadioListTile<int>(
                            value: 3,
                            groupValue: p2pMode,
                            onChanged: (v) {
                              if (v != null) _setP2PMode(v);
                            },
                            title: const Text('Hub Relay Only'),
                            subtitle: const Text('Route all through Hub'),
                            secondary: const Icon(Icons.cloud),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // WebRTC Configuration
                  _buildSectionHeader('WebRTC Configuration'),

                  // STUN Servers
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: const Text('STUN Servers'),
                          subtitle: Text('${_stunServers.length} configured'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addStunServer,
                          ),
                        ),
                        const Divider(height: 1),
                        ..._stunServers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final server = entry.value;
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.dns, size: 20),
                            title: Text(
                              server,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () async {
                                setState(() {
                                  _stunServers.removeAt(index);
                                });
                                await _saveIceSettings();
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // TURN Server
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.sync_alt),
                      title: const Text('TURN Server (optional)'),
                      subtitle: Text(
                          _turnServer.isEmpty ? 'Not configured' : _turnServer),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _editTurnServer,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'P2P connections use WebRTC for direct communication between your app and nodes. '
                            'STUN servers help with NAT traversal. TURN servers provide relay when direct connection fails.',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 13,
                            ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
