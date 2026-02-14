import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/main.dart';
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart';
import 'package:nitella_app/services/auth_service.dart';
import 'package:nitella_app/utils/logger.dart';
import '../utils/error_helper.dart';

class InitialSetupScreen extends ConsumerStatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  ConsumerState<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends ConsumerState<InitialSetupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Generation Controls
  late final TextEditingController _cnController;
  final _orgController = TextEditingController();
  final _passphraseController = TextEditingController();
  bool _usePassphrase = false;

  // Restore Controls
  final _restoreMnemonicController = TextEditingController();
  final _restorePassphraseController = TextEditingController();
  final _restoreCnController = TextEditingController();
  final _restoreOrgController = TextEditingController();
  bool _restoreUsePassphrase = false;

  // Import Controls
  final _importCertPath = TextEditingController();
  final _importKeyPath = TextEditingController();
  final _importKeyPassphrase = TextEditingController();

  // Common Controls
  final _hubController = TextEditingController();
  bool _securityEnabled = false;
  bool _isLoading = false;
  Timer? _clipboardClearTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Init with defaults
    String hostname;
    try {
      hostname = Platform.localHostname;
    } catch (e) {
      hostname = "Device";
    }

    _cnController = TextEditingController(text: "Nitella Root CA ($hostname)");
    _restoreCnController.text = _cnController.text;

    _loadRichDeviceInfo();
  }

  Future<void> _loadRichDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceName = "Device";

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = "${androidInfo.manufacturer} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        deviceName = linuxInfo.prettyName;
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        deviceName = macInfo.computerName;
      }

      if (mounted) {
        setState(() {
          _cnController.text = "Nitella Root CA ($deviceName)";
          _restoreCnController.text = _cnController.text;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    _clipboardClearTimer?.cancel();
    _tabController.dispose();
    _cnController.dispose();
    _orgController.dispose();
    _passphraseController.dispose();
    _restoreMnemonicController.dispose();
    _restorePassphraseController.dispose();
    _restoreCnController.dispose();
    _restoreOrgController.dispose();
    _importCertPath.dispose();
    _importKeyPath.dispose();
    _importKeyPassphrase.dispose();
    _hubController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final client = ref.read(logicServiceProvider);

      if (_tabController.index == 0) {
        // Mode: Create New Identity
        local.EvaluatePassphraseResponse? createPassphraseCheck;
        if (_usePassphrase) {
          final passphrase = _passphraseController.text;
          createPassphraseCheck = await _checkPassphrasePolicy(passphrase);
          if (createPassphraseCheck == null) {
            return;
          }
        }
        final req = local.CreateIdentityRequest(
          commonName: _cnController.text,
          organization: _orgController.text,
          passphrase: _usePassphrase ? _passphraseController.text : '',
          allowWeakPassphrase: createPassphraseCheck?.shouldWarn ?? false,
        );
        final resp = await client.createIdentity(req);

        if (!resp.success) {
          throw Exception(resp.error);
        }

        // Show Mnemonic for Backup
        if (resp.mnemonic.isNotEmpty && mounted) {
          // Enable screenshot protection while mnemonic is visible
          if (!kIsWeb && Platform.isAndroid) {
            await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: SystemUiOverlay.values);
            // FLAG_SECURE prevents screenshots and screen recording on Android
            await const MethodChannel('io.tempage.nitella/security')
                .invokeMethod('enableSecureFlag');
          }
          try {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text("Backup Recovery Phrase"),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                            "Write down these 24 words securely. This is the ONLY way to recover your identity if your device is lost."),
                        const SizedBox(height: 16),
                        SelectableText(
                          resp.mnemonic,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Monospace',
                              fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        if (resp.identity.emojiHash.isNotEmpty) ...[
                          const Text("Visual Identity (Emoji Fingerprint):",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SelectableText(
                            resp.identity.emojiHash,
                            style: const TextStyle(fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  FilledButton(
                    key: const Key('backup_confirm_button'),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("I have written it down"),
                  ),
                ],
              ),
            );
          } finally {
            // Disable screenshot protection after mnemonic dialog is dismissed
            if (!kIsWeb && Platform.isAndroid) {
              await const MethodChannel('io.tempage.nitella/security')
                  .invokeMethod('disableSecureFlag');
            }
            // Clear clipboard after 30s in case user copied the mnemonic
            _clipboardClearTimer?.cancel();
            _clipboardClearTimer = Timer(const Duration(seconds: 30), () {
              Clipboard.setData(const ClipboardData(text: ''));
            });
          }
        }
      } else if (_tabController.index == 1) {
        // Mode: Restore from Mnemonic
        local.EvaluatePassphraseResponse? restorePassphraseCheck;
        if (_restoreUsePassphrase) {
          final passphrase = _restorePassphraseController.text;
          if (passphrase.isEmpty) {
            throw Exception("Passphrase required");
          }
          restorePassphraseCheck = await _checkPassphrasePolicy(passphrase);
          if (restorePassphraseCheck == null) {
            return;
          }
        }
        final req = local.RestoreIdentityRequest(
          mnemonic: _restoreMnemonicController.text.trim(),
          commonName: _restoreCnController.text.isNotEmpty
              ? _restoreCnController.text
              : "Nitella Root CA",
          organization: _restoreOrgController.text,
          passphrase:
              _restoreUsePassphrase ? _restorePassphraseController.text : '',
          allowWeakPassphrase: restorePassphraseCheck?.shouldWarn ?? false,
        );
        final resp = await client.restoreIdentity(req);

        if (!resp.success) {
          throw Exception(resp.error);
        }

        // Visual Confirmation for Restore
        if (mounted) {
          bool confirmed = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => AlertDialog(
                  title: const Text("Confirm Identity"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          "Please confirm that these emojis match your original identity:"),
                      const SizedBox(height: 16),
                      if (resp.identity.emojiHash.isNotEmpty)
                        SelectableText(
                          resp.identity.emojiHash,
                          style: const TextStyle(fontSize: 32),
                          textAlign: TextAlign.center,
                        )
                      else
                        const Text("(No visual fingerprint available)"),
                      const SizedBox(height: 24),
                      const Text("Fingerprint:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SelectableText(
                        resp.identity.fingerprint,
                        style: const TextStyle(
                            fontFamily: 'Monospace', fontSize: 12),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Cancel"),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              ) ??
              false;

          if (!confirmed) {
            throw "Restore cancelled by user";
          }
        }
      } else {
        // Mode: Import from File
        final req = local.ImportIdentityRequest(
          certPem: _importCertPath.text,
          keyPem: _importKeyPath.text,
          keyPassphrase: _importKeyPassphrase.text,
        );
        final resp = await client.importIdentity(req);

        if (!resp.success) {
          throw Exception(resp.error);
        }

        // Show confirmation
        if (mounted) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Identity Imported"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (resp.identity.emojiHash.isNotEmpty) ...[
                    Text(
                      resp.identity.emojiHash,
                      style: const TextStyle(fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text("Fingerprint: ${resp.identity.fingerprint}"),
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Continue"),
                ),
              ],
            ),
          );
        }
      }

      final configuredHubAddress = _hubController.text.trim();
      final updatePaths = <String>['require_biometric'];
      final settings = local.Settings(requireBiometric: _securityEnabled);
      if (_securityEnabled) {
        await AuthService()
            .getOrCreateBiometricPublicKey(createIfMissing: true);
      }
      if (configuredHubAddress.isNotEmpty) {
        settings.hubAddress = configuredHubAddress;
        updatePaths.add('hub_address');
      }
      await client.updateSettings(local.UpdateSettingsRequest(
        settings: settings,
        updateMask: FieldMask(paths: updatePaths),
      ));

      if (mounted) {
        // Navigate to Home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      logger.e("Setup failed", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${friendlyError(e)}")),
        );
      }
    } finally {
      _restoreMnemonicController.clear();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<local.EvaluatePassphraseResponse?> _checkPassphrasePolicy(
      String passphrase) async {
    if (passphrase.isEmpty) {
      return null;
    }

    final client = ref.read(logicServiceProvider);
    final check = await client.evaluatePassphrase(
      local.EvaluatePassphraseRequest(passphrase: passphrase),
    );
    if (!check.shouldWarn) {
      return check;
    }

    if (!mounted) {
      return null;
    }

    final details = check.report.isNotEmpty
        ? check.report
        : "Strength: ${check.strength.name}\n"
            "Entropy: ${check.entropy.toStringAsFixed(1)} bits\n"
            "Assessment: ${check.message}\n"
            "Estimated crack time: ${check.crackTime}";

    final accepted = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Weak Passphrase"),
            content: SingleChildScrollView(
              child: Text(
                "$details\n\nUse this passphrase anyway?",
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Choose Stronger"),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Use Anyway"),
              ),
            ],
          ),
        ) ??
        false;

    if (!accepted) {
      return null;
    }
    return check;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Initial Setup"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Create"),
            Tab(text: "Restore"),
            Tab(text: "Import"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    switch (_tabController.index) {
                      case 0:
                        return _buildCreateForm();
                      case 1:
                        return _buildRestoreForm();
                      case 2:
                        return _buildImportForm();
                      default:
                        return _buildCreateForm();
                    }
                  }),
              const SizedBox(height: 32),
              const Text("Hub Configuration",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hubController,
                decoration: const InputDecoration(
                  labelText: "Hub Endpoint (Optional)",
                  hintText: "hub.example.com:443",
                  helperText: "Leave empty to skip Hub connection",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              const Text("App Security",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Enable Biometrics / PIN"),
                subtitle: const Text("Require authentication to open the app."),
                value: _securityEnabled,
                onChanged: (v) => setState(() => _securityEnabled = v!),
              ),
              if (_securityEnabled)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Note: If you enable this, you will be prompted for FaceID/TouchID/PIN every time you open Nitella.",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_getSubmitLabel()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSubmitLabel() {
    switch (_tabController.index) {
      case 0:
        return "Create Identity";
      case 1:
        return "Restore Identity";
      case 2:
        return "Import Identity";
      default:
        return "Continue";
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _restoreMnemonicController.text = data!.text!;
      setState(() {});
    }
  }

  Widget _buildRestoreForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Restore your identity from a BIP-39 mnemonic phrase.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        const Text("Recovery Phrase",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _restoreMnemonicController,
          decoration: const InputDecoration(
              labelText: "Mnemonic Phrase (12-24 words)",
              border: OutlineInputBorder(),
              hintText: "witch collapse practice feed..."),
          maxLines: 3,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? "Mnemonic is required" : null,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _pasteFromClipboard,
              icon: const Icon(Icons.paste, size: 18),
              label: const Text("Paste"),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement QR scanning for mnemonic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("QR scanning not yet implemented")),
                );
              },
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text("Scan QR"),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text("Identity Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          "Must match original values to restore the same certificate",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _restoreCnController,
          decoration: const InputDecoration(
              labelText: "Common Name (CN)",
              border: OutlineInputBorder(),
              hintText: "Nitella Root CA"),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _restoreOrgController,
          decoration: const InputDecoration(
              labelText: "Organization (O)",
              border: OutlineInputBorder(),
              hintText: "Optional"),
        ),
        const SizedBox(height: 24),
        const Text("Security Options",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Use Passphrase"),
          subtitle: const Text("Encrypt your private key with a passphrase"),
          value: _restoreUsePassphrase,
          onChanged: (v) => setState(() => _restoreUsePassphrase = v!),
        ),
        if (_restoreUsePassphrase) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _restorePassphraseController,
            decoration: const InputDecoration(
                labelText: "Passphrase", border: OutlineInputBorder()),
            obscureText: true,
          ),
        ],
      ],
    );
  }

  Widget _buildImportForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Import your Root CA certificate and private key from files.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        const Text("Certificate File",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _importCertPath,
          decoration: InputDecoration(
            labelText: "Certificate (.crt, .pem)",
            border: const OutlineInputBorder(),
            hintText: "Paste PEM content or file path",
            suffixIcon: IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () async {
                // TODO: Implement file picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          "File picker not yet implemented. Paste PEM content directly.")),
                );
              },
            ),
          ),
          maxLines: 4,
          validator: (v) => v!.isEmpty ? "Certificate required" : null,
        ),
        const SizedBox(height: 24),
        const Text("Private Key File",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _importKeyPath,
          decoration: InputDecoration(
            labelText: "Private Key (.key, .pem)",
            border: const OutlineInputBorder(),
            hintText: "Paste PEM content or file path",
            suffixIcon: IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () async {
                // TODO: Implement file picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          "File picker not yet implemented. Paste PEM content directly.")),
                );
              },
            ),
          ),
          maxLines: 4,
          validator: (v) => v!.isEmpty ? "Private key required" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _importKeyPassphrase,
          decoration: const InputDecoration(
              labelText: "Key Passphrase (if encrypted)",
              border: OutlineInputBorder(),
              hintText: "Leave empty if key is not encrypted"),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildCreateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Create a new cryptographic identity. A recovery phrase will be generated.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        const Text("Identity Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cnController,
          decoration: const InputDecoration(
              labelText: "Common Name (CN)", border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _orgController,
          decoration: const InputDecoration(
              labelText: "Organization (O)",
              border: OutlineInputBorder(),
              hintText: "Optional"),
        ),
        const SizedBox(height: 24),
        const Text("Security Options",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Use Passphrase"),
          subtitle: const Text("Encrypt your private key with a passphrase"),
          value: _usePassphrase,
          onChanged: (v) => setState(() => _usePassphrase = v!),
        ),
        if (_usePassphrase) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _passphraseController,
            decoration: const InputDecoration(
                labelText: "Passphrase", border: OutlineInputBorder()),
            obscureText: true,
            validator: (v) => _usePassphrase && (v == null || v.isEmpty)
                ? "Passphrase required"
                : null,
          ),
        ],
      ],
    );
  }
}
