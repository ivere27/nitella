import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/main.dart';
import 'package:nitella_app/services/auth_service.dart';
import 'package:nitella_app/screens/initial_setup_screen.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'package:nitella_app/utils/logger.dart';
import '../utils/error_helper.dart';

class AuthCheckScreen extends ConsumerStatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  ConsumerState<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends ConsumerState<AuthCheckScreen> {
  String _status = "Authenticating...";
  bool _showRetry = false;
  bool _needsPassphrase = false;
  final _passphraseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    setState(() {
      _status = "Authenticating...";
      _showRetry = false;
      _needsPassphrase = false;
    });

    final auth = AuthService();
    final client = ref.read(logicServiceProvider);

    try {
      final bootstrap = await client.getBootstrapState(Empty());
      if (!bootstrap.identityExists ||
          bootstrap.stage ==
              local.BootstrapStage.BOOTSTRAP_STAGE_SETUP_NEEDED) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const InitialSetupScreen()),
          );
        }
        return;
      }

      if (bootstrap.requireBiometric) {
        final authenticated = await auth.authenticate();
        if (!authenticated) {
          setState(() {
            _status = "Authentication Failed";
            _showRetry = true;
          });
          return;
        }
      }

      setState(() => _status = "Checking identity...");

      if (bootstrap.identityLocked) {
        // Identity is locked - need passphrase
        setState(() {
          _status = "Identity is locked";
          _needsPassphrase = true;
        });
        return;
      }

      // Identity exists and is unlocked - go to main
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      logger.e("Failed to check identity", error: e);
      setState(() {
        _status = "Error: ${friendlyError(e)}";
        _showRetry = true;
      });
    }
  }

  Future<void> _unlock() async {
    if (_passphraseController.text.isEmpty) return;

    setState(() {
      _status = "Unlocking...";
      _needsPassphrase = false;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.unlockIdentity(
        local.UnlockIdentityRequest(passphrase: _passphraseController.text),
      );

      if (!resp.success) {
        setState(() {
          _status = resp.error.isNotEmpty ? resp.error : "Incorrect passphrase";
          _needsPassphrase = true;
        });
        return;
      }

      // Success - go to main
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      logger.e("Failed to unlock", error: e);
      setState(() {
        _status = "Error: ${friendlyError(e)}";
        _needsPassphrase = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.deepPurple),
              const SizedBox(height: 24),
              Text(_status, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              if (_needsPassphrase) ...[
                TextField(
                  controller: _passphraseController,
                  decoration: const InputDecoration(
                    labelText: "Passphrase",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onSubmitted: (_) => _unlock(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _unlock,
                  child: const Text("Unlock"),
                ),
              ],
              if (_showRetry)
                FilledButton(
                  onPressed: _checkAuth,
                  child: const Text("Retry"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
