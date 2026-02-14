import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/main.dart';

class QrPairingScreen extends ConsumerStatefulWidget {
  const QrPairingScreen({super.key});

  @override
  ConsumerState<QrPairingScreen> createState() => _QrPairingScreenState();
}

class _QrPairingScreenState extends ConsumerState<QrPairingScreen> {
  // Steps: 0 = scanning, 1 = verifying, 2 = show response QR, 3 = done
  int _step = 0;

  MobileScannerController? _scannerController;
  String? _error;
  bool _isLoading = false;
  bool _hasScanned = false;

  // Scanned data
  String? _scanSessionId;
  String? _nodeId;
  String? _emojiFingerprint;
  String? _responseQrData;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _onQrDetected(BarcodeCapture capture) async {
    if (_hasScanned || _isLoading) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _hasScanned = true;
      _isLoading = true;
    });

    // Stop the scanner
    _scannerController?.stop();

    try {
      final client = ref.read(logicServiceProvider);
      final response = await client.scanQRCode(local.ScanQRCodeRequest(
        qrData: utf8.encode(code),
      ));

      if (!response.success) {
        setState(() {
          _error = response.error;
          _hasScanned = false;
          _isLoading = false;
        });
        _scannerController?.start();
        return;
      }

      setState(() {
        _scanSessionId = response.sessionId;
        _nodeId = response.nodeId;
        _emojiFingerprint = response.emojiHash;
        _step = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _hasScanned = false;
        _isLoading = false;
      });
      _scannerController?.start();
    }
  }

  Future<void> _confirmAndSign() async {
    if ((_scanSessionId ?? '').isEmpty) {
      setState(() => _error = 'Invalid scan session');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = ref.read(logicServiceProvider);
      final response =
          await client.finalizePairing(local.FinalizePairingRequest(
        sessionId: _scanSessionId ?? '',
        accepted: true,
      ));

      if (!response.success) {
        setState(() {
          _error = response.error;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _responseQrData = String.fromCharCodes(response.qrData);
        _step = 2;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cancel() async {
    final sessionId = _scanSessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      try {
        await ref.read(logicServiceProvider).finalizePairing(
              local.FinalizePairingRequest(
                sessionId: sessionId,
                accepted: false,
              ),
            );
      } catch (_) {}
    }
    if (!mounted) return;
    Navigator.pop(context, false);
  }

  void _done() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Pairing'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case 0:
        return _buildScanStep();
      case 1:
        return _buildVerifyStep();
      case 2:
        return _buildResponseQrStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildScanStep() {
    return Column(
      children: [
        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Column(
            children: [
              const Text(
                'Scan the QR code from your node',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Run: nitellad --pair-offline',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Camera view
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: _onQrDetected,
              ),
              // Overlay
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                ),
                margin: const EdgeInsets.all(48),
              ),
              // Loading indicator
              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),

        // Error display
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
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
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _error = null),
                ),
              ],
            ),
          ),

        // Hint
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Point the camera at the QR code displayed on the node terminal',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success icon
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_scanner,
                  color: Colors.green, size: 32),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Node Pairing Request',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Node info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(label: 'Node ID', value: _nodeId ?? 'Unknown'),
                  const Divider(),
                  _InfoRow(
                      label: 'Fingerprint', value: _emojiFingerprint ?? '????'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Warning
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Verify fingerprint!',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Make sure the emoji fingerprint above matches what is displayed on the node terminal. '
                  'This confirms you are pairing with the correct device.',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontSize: 13,
                  ),
                ),
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
              ),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _cancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Cancel - Don't Trust"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _isLoading ? null : _confirmAndSign,
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
                      : const Text('Fingerprint Matches - Sign'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponseQrStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success icon
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 32),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Certificate Signed!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Show this QR code to the node',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // QR Code
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _responseQrData != null
                  ? QrImageView(
                      data: _responseQrData!,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                    )
                  : const SizedBox(
                      width: 250,
                      height: 250,
                      child: Center(child: Text('Error generating QR')),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Next steps',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Point your node\'s camera at this QR code\n'
                  '2. The node will verify and save the certificate\n'
                  '3. Once the node confirms, tap "Done" below',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Done button
          FilledButton(
            onPressed: _done,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
