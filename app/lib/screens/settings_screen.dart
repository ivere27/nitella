import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/main.dart';

import '../services/auth_service.dart';
import '../utils/error_helper.dart';
import '../utils/biometric_guard.dart';
import '../services/mobile_ui_service.dart';
import '../screens/initial_setup_screen.dart';
import '../screens/embedded_node_screen.dart';
import '../screens/hub_settings_screen.dart';
import '../screens/p2p_settings_screen.dart';
import '../screens/push_notifications_screen.dart';
import '../screens/signed_certificates_screen.dart';

final hubAddressProvider = StateProvider<String>((ref) => '');
final hubConnectedProvider = StateProvider<bool>((ref) => false);
final hubRegisteredProvider = StateProvider<bool>((ref) => false);
// P2P mode: 1=Auto, 2=P2P Only, 3=Hub Only
final p2pModeProvider = StateProvider<int>((ref) => 1);
// Security
final biometricEnabledProvider = StateProvider<bool>((ref) => true);
final autoLockMinutesProvider = StateProvider<int>((ref) => 5);
// Notifications
final approvalNotificationsProvider = StateProvider<bool>((ref) => true);
final nodeStatusNotificationsProvider = StateProvider<bool>((ref) => true);
final connectionNotificationsProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  StreamSubscription? _statusSubscription;
  String? _identityEmoji;
  String? _identitySubject;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Listen to node status changes
    _statusSubscription =
        MobileUIServiceImpl().nodeStatusStream.listen((status) {
      if (mounted) {
        ref.read(hubConnectedProvider.notifier).state = status.online;
      }
    });
  }

  Future<void> _loadSettings() async {
    try {
      final client = ref.read(logicServiceProvider);
      final overview = await client.getSettingsOverviewSnapshot(Empty());
      final hubSnapshot =
          overview.hasHub() ? overview.hub : local.HubSettingsSnapshot();
      local.Settings settings = local.Settings();
      if (hubSnapshot.hasSettings()) {
        settings = hubSnapshot.settings;
      } else if (overview.hasP2p() && overview.p2p.hasSettings()) {
        settings = overview.p2p.settings;
      }
      final mode = settings.p2pMode.value;
      if (mode >= 1 && mode <= 3) {
        ref.read(p2pModeProvider.notifier).state = mode;
      }
      ref.read(biometricEnabledProvider.notifier).state =
          settings.requireBiometric;
      ref.read(autoLockMinutesProvider.notifier).state =
          settings.autoLockMinutes;

      final hubStatus =
          hubSnapshot.hasStatus() ? hubSnapshot.status : local.HubStatus();
      ref.read(hubConnectedProvider.notifier).state = hubStatus.connected;
      ref.read(hubAddressProvider.notifier).state =
          hubSnapshot.resolvedHubAddress.isNotEmpty
              ? hubSnapshot.resolvedHubAddress
              : hubStatus.hubAddress;

      final identity =
          overview.hasIdentity() ? overview.identity : local.IdentityInfo();
      if (identity.exists) {
        setState(() {
          _identityEmoji = identity.emojiHash;
          _identitySubject = identity.fingerprint;
        });
      }
    } catch (e) {
      debugPrint('Failed to load identity: $e');
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(hubConnectedProvider);
    final hubAddress = ref.watch(hubAddressProvider);
    final p2pMode = ref.watch(p2pModeProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final autoLockMinutes = ref.watch(autoLockMinutesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Hub & Network Section
          _buildSectionHeader('Hub & Network'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.cloud,
                    color: isConnected ? Colors.green : Colors.grey,
                  ),
                  title: const Text('Hub Server'),
                  subtitle: Text(
                      hubAddress.isNotEmpty ? hubAddress : 'Not configured'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnected ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HubSettingsScreen()),
                    ).then((_) => _loadSettings());
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: const Text('P2P Settings'),
                  subtitle: Text(_p2pModeLabel(p2pMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const P2PSettingsScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Enabled'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PushNotificationsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Security Section
          _buildSectionHeader('Security'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: const Text('Biometric'),
                  subtitle: Text(biometricEnabled ? 'Enabled' : 'Disabled'),
                  value: biometricEnabled,
                  onChanged: _setBiometricEnabled,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_clock),
                  title: const Text('Auto-Lock'),
                  subtitle: Text(autoLockMinutes == 0
                      ? 'Never'
                      : '$autoLockMinutes minutes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAutoLockDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.password),
                  title: const Text('Change Passphrase'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePassphraseDialog(context),
                ),
              ],
            ),
          ),

          // Identity Section
          _buildSectionHeader('Identity'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                if (_identityEmoji != null)
                  ListTile(
                    leading: const Icon(Icons.face),
                    title: Text(
                      _identityEmoji!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    subtitle: Text(_identitySubject ?? ''),
                  ),
                if (_identityEmoji != null) const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('Export CA Certificate'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportCACertificate(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Signed Certificates'),
                  subtitle: const Text('View issued node certificates'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SignedCertificatesScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Embedded Node Section
          _buildSectionHeader('Embedded Node'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dns),
                  title: const Text('Node Identity'),
                  subtitle: Text(
                    _identitySubject != null
                        ? 'node-mobile-${_identitySubject!.length > 8 ? _identitySubject!.substring(0, 8) : _identitySubject!}'
                        : 'node-mobile-xxxx',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmbeddedNodeScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.circle,
                    size: 12,
                    color: Colors.green.shade400,
                  ),
                  title: const Text('Status'),
                  trailing: Text(
                    'Running',
                    style: TextStyle(color: Colors.green.shade600),
                  ),
                ),
              ],
            ),
          ),

          // About Section
          _buildSectionHeader('About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  trailing: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Licenses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'Nitella',
                      applicationVersion: '1.0.0',
                    );
                  },
                ),
              ],
            ),
          ),

          // Reset Identity
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => _showResetDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Reset Identity'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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

  String _p2pModeLabel(int mode) {
    switch (mode) {
      case 1:
        return 'Auto (WebRTC)';
      case 2:
        return 'P2P Only';
      case 3:
        return 'Hub Only';
      default:
        return 'Unknown';
    }
  }

  void _showAutoLockDialog(BuildContext context) {
    final currentMinutes = ref.read(autoLockMinutesProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Lock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final minutes in [0, 1, 5, 15, 30, 60])
              RadioListTile<int>(
                title: Text(minutes == 0
                    ? 'Never'
                    : minutes == 60
                        ? '1 hour'
                        : '$minutes minutes'),
                value: minutes,
                groupValue: currentMinutes,
                onChanged: (value) {
                  _setAutoLockMinutes(value ?? 0);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _setBiometricEnabled(bool enabled) async {
    final previous = ref.read(biometricEnabledProvider);
    ref.read(biometricEnabledProvider.notifier).state = enabled;
    try {
      if (enabled) {
        await AuthService()
            .getOrCreateBiometricPublicKey(createIfMissing: true);
      }
      final client = ref.read(logicServiceProvider);
      await client.updateSettings(local.UpdateSettingsRequest(
        settings: local.Settings(requireBiometric: enabled),
        updateMask: FieldMask(paths: const ['require_biometric']),
      ));
    } catch (e) {
      ref.read(biometricEnabledProvider.notifier).state = previous;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }

  Future<void> _setAutoLockMinutes(int minutes) async {
    final previous = ref.read(autoLockMinutesProvider);
    ref.read(autoLockMinutesProvider.notifier).state = minutes;
    try {
      final client = ref.read(logicServiceProvider);
      await client.updateSettings(local.UpdateSettingsRequest(
        settings: local.Settings(autoLockMinutes: minutes),
        updateMask: FieldMask(paths: const ['auto_lock_minutes']),
      ));
    } catch (e) {
      ref.read(autoLockMinutesProvider.notifier).state = previous;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }

  void _showChangePassphraseDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool isLoading = false;
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Change Passphrase'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentController,
                  decoration: const InputDecoration(
                    labelText: 'Current Passphrase',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  decoration: const InputDecoration(
                    labelText: 'New Passphrase',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Passphrase',
                    border: const OutlineInputBorder(),
                    errorText: error,
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (newController.text != confirmController.text) {
                        setDialogState(
                            () => error = 'Passphrases do not match');
                        return;
                      }
                      if (newController.text.isEmpty) {
                        setDialogState(
                            () => error = 'New passphrase cannot be empty');
                        return;
                      }

                      final client = ref.read(logicServiceProvider);
                      bool allowWeakPassphrase = false;
                      try {
                        final check = await client.evaluatePassphrase(
                          local.EvaluatePassphraseRequest(
                            passphrase: newController.text,
                          ),
                        );
                        allowWeakPassphrase = check.shouldWarn;
                        if (check.shouldWarn) {
                          if (!ctx.mounted) {
                            return;
                          }
                          final details = check.report.isNotEmpty
                              ? check.report
                              : "Strength: ${check.strength.name}\n"
                                  "Entropy: ${check.entropy.toStringAsFixed(1)} bits\n"
                                  "Assessment: ${check.message}\n"
                                  "Estimated crack time: ${check.crackTime}";
                          final accepted = await showDialog<bool>(
                                context: ctx,
                                builder: (warnCtx) => AlertDialog(
                                  title: const Text('Weak Passphrase'),
                                  content: SingleChildScrollView(
                                    child: Text(
                                      "$details\n\nUse this passphrase anyway?",
                                      style: const TextStyle(
                                          fontFamily: 'monospace'),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(warnCtx, false),
                                      child: const Text('Choose Stronger'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(warnCtx, true),
                                      child: const Text('Use Anyway'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                          if (!accepted) {
                            return;
                          }
                        }
                      } catch (e) {
                        setDialogState(() {
                          error =
                              'Passphrase check failed: ${friendlyError(e)}';
                        });
                        return;
                      }

                      setDialogState(() {
                        isLoading = true;
                        error = null;
                      });

                      try {
                        await client.changePassphrase(
                          local.ChangePassphraseRequest(
                            oldPassphrase: currentController.text,
                            newPassphrase: newController.text,
                            allowWeakPassphrase: allowWeakPassphrase,
                          ),
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Passphrase changed successfully')),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          isLoading = false;
                          error = e.toString();
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCACertificate(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final client = ref.read(logicServiceProvider);
      final identity = await client.getIdentity(Empty());

      if (!identity.exists) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('No identity found')),
          );
        }
        return;
      }

      if (mounted) {
        showDialog(
          context: this.context,
          builder: (ctx) => AlertDialog(
            title: const Text('Export CA Certificate'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your root CA certificate can be used to verify node certificates. '
                  'The private key is NOT exported.',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fingerprint: ${identity.emojiHash}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${identity.fingerprint.substring(0, 16)}...',
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: identity.fingerprint));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Fingerprint copied to clipboard')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Fingerprint'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  // Use share_plus to share the certificate
                  try {
                    await Share.share(
                      'Nitella CA Certificate\n'
                      'Fingerprint: ${identity.emojiHash}\n'
                      'ID: ${identity.fingerprint}',
                      subject: 'Nitella CA Certificate',
                    );
                  } catch (e) {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Error: ${friendlyError(e)}')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Reset Identity?'),
          ],
        ),
        content: const Text(
          'This will permanently delete your identity and all paired nodes. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              if (!await biometricGuard(ref)) return;
              // Delete identity from Go backend (disk + memory)
              final client = ref.read(logicServiceProvider);
              await client.resetIdentity(Empty());
              // Clear Flutter-side state
              await AuthService().reset();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const InitialSetupScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
