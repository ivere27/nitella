import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/main.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';

class PakePairingScreen extends ConsumerStatefulWidget {
  const PakePairingScreen({super.key});

  @override
  ConsumerState<PakePairingScreen> createState() => _PakePairingScreenState();
}

class _PakePairingScreenState extends ConsumerState<PakePairingScreen> {
  // Steps: 0 = setup/retry, 1 = waiting for node, 2 = verify emoji, 3 = completing, 4 = done
  int _step = 0;

  String? _error;
  String? _sessionId;
  String? _pakeEmoji;
  String? _nodeName;
  String? _nodeFingerprint;
  String? _nodeEmojiHash;
  String? _csrFingerprint;
  String? _csrHash;
  String _pairingCode = '';
  String _hubAddress = '';
  int _expiresInSeconds = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startPairingSession();
  }

  Future<void> _startPairingSession() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _step = 0;
    });

    try {
      final client = ref.read(logicServiceProvider);

      final snapshot = await client.getHubSettingsSnapshot(Empty());
      final status = snapshot.hasStatus() ? snapshot.status : local.HubStatus();
      final settings =
          snapshot.hasSettings() ? snapshot.settings : local.Settings();
      final hubUrl = snapshot.resolvedHubAddress.isNotEmpty
          ? snapshot.resolvedHubAddress
          : (status.hubAddress.isNotEmpty
              ? status.hubAddress
              : settings.hubAddress);

      final startResp = await client.startPairing(local.StartPairingRequest());
      if (startResp.pairingCode.isEmpty) {
        throw Exception('backend did not return a pairing code');
      }

      if (!mounted) return;
      setState(() {
        _pairingCode = startResp.pairingCode;
        _expiresInSeconds = startResp.expiresInSeconds;
        _hubAddress = hubUrl;
        _sessionId = null;
        _pakeEmoji = null;
        _nodeName = null;
        _nodeFingerprint = null;
        _nodeEmojiHash = null;
        _csrFingerprint = null;
        _csrHash = null;
        _isLoading = false;
      });

      // CLI-style UX: once a code is generated, start waiting immediately.
      await _waitForNode(autoStarted: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _nodePairCommand() {
    final hub = _hubAddress.isNotEmpty ? _hubAddress : '<hub-url-not-set>';
    final code = _pairingCode.isNotEmpty ? _pairingCode : '<code>';
    return 'nitellad --hub $hub --pair $code';
  }

  Future<void> _waitForNode({bool autoStarted = false}) async {
    if (_pairingCode.isEmpty) {
      setState(() => _error = 'Pairing code is not ready');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _step = 1;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final response = await client.joinPairing(local.JoinPairingRequest(
        pairingCode: _pairingCode,
      ));

      if (!response.success) {
        if (!mounted) return;
        setState(() {
          _error = response.error;
          _step = 0;
          _isLoading = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _sessionId = response.sessionId;
        _pakeEmoji = response.emojiFingerprint;
        _nodeName = response.nodeName;
        _nodeFingerprint = response.fingerprint;
        _nodeEmojiHash = response.emojiHash;
        _csrFingerprint = response.csrFingerprint;
        _csrHash = response.csrHash;
        _step = 2;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = autoStarted ? 'Waiting failed: $e' : e.toString();
        _step = 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmMatch() async {
    setState(() {
      _step = 3;
      _isLoading = true;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final response =
          await client.finalizePairing(local.FinalizePairingRequest(
        sessionId: _sessionId ?? '',
        accepted: true,
      ));

      if (!response.success) {
        if (!mounted) return;
        setState(() {
          _error = response.error;
          _step = 2;
          _isLoading = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _step = 4;
        _isLoading = false;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _step = 2;
        _isLoading = false;
      });
    }
  }

  void _copyText(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _cancel() {
    final sessionId = _sessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      _cancelSession(sessionId);
    }
    Navigator.pop(context, false);
  }

  Future<void> _cancelSession(String sessionId) async {
    try {
      await ref
          .read(logicServiceProvider)
          .finalizePairing(local.FinalizePairingRequest(
            sessionId: sessionId,
            accepted: false,
          ));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair via Hub'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case 0:
        return _buildStartStep();
      case 1:
        return _buildWaitingStep();
      case 2:
        return _buildVerifyEmojiStep();
      case 3:
        return _buildCompletingStep();
      case 4:
        return _buildSuccessStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStartStep() {
    if (_isLoading && _pairingCode.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text('Preparing pairing code...'),
            const SizedBox(height: 8),
            Text(
              'Getting your Hub URL and generating a one-time code',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pairing setup failed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Retry to generate a new pairing code and start waiting automatically.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isLoading ? null : _startPairingSession,
            icon: const Icon(Icons.refresh),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Retry Pairing'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 24),
          const Text(
            'Waiting for node...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'No extra tap needed here. Run this on your node:',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _nodePairCommand(),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () =>
                      _copyText(_nodePairCommand(), 'Command copied'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Hub URL', _hubAddress.isNotEmpty ? _hubAddress : '-'),
          const SizedBox(height: 6),
          _buildInfoRow(
              'Pairing Code', _pairingCode.isNotEmpty ? _pairingCode : '-'),
          const SizedBox(height: 6),
          _buildInfoRow(
            'Code expires',
            _expiresInSeconds > 0 ? '${_expiresInSeconds}s' : 'unknown',
          ),
          const SizedBox(height: 24),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerifyEmojiStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Verify Fingerprint',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Match the node CSR fingerprint and hash on the node terminal.',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_nodeName != null && _nodeName!.isNotEmpty) ...[
                  Text(
                    'Node: $_nodeName',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'CSR Fingerprint',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  (_csrFingerprint != null && _csrFingerprint!.isNotEmpty)
                      ? _csrFingerprint!
                      : '????',
                  style: const TextStyle(
                    fontSize: 44,
                    letterSpacing: 6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'CSR Hash',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  (_csrHash != null && _csrHash!.isNotEmpty) ? _csrHash! : '-',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                if (_pakeEmoji != null && _pakeEmoji!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'PAKE Emoji: $_pakeEmoji',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (_nodeEmojiHash != null && _nodeEmojiHash!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Node Emoji Hash: $_nodeEmojiHash',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (_nodeFingerprint != null &&
                    _nodeFingerprint!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Node Fingerprint: $_nodeFingerprint',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _cancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('No, Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _isLoading ? null : _confirmMatch,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Yes, Match'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletingStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            'Completing pairing...',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Signing node certificate',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Node Paired!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _nodeName ?? 'New Node',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          if (_nodeEmojiHash != null && _nodeEmojiHash!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _nodeEmojiHash!,
              style: const TextStyle(fontSize: 24),
            ),
          ] else if (_pakeEmoji != null && _pakeEmoji!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _pakeEmoji!,
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ],
      ),
    );
  }
}
