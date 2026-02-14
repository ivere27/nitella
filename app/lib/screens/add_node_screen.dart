import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pake_pairing_screen.dart';
import 'qr_pairing_screen.dart';
import 'direct_connect_screen.dart';

class AddNodeScreen extends ConsumerWidget {
  const AddNodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Node'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          // Header
          const Text(
            'Choose how to add a node',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pair a nitellad node to manage it from this app.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Option 1: Pair via Hub (PAKE)
          _PairingOptionCard(
            icon: Icons.cloud_outlined,
            iconColor: Colors.blue,
            title: 'Pair via Hub',
            description: 'Secure pairing from anywhere using a code',
            details: 'Run: nitellad --hub <url> --pair',
            onTap: () async {
              final paired = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const PakePairingScreen(),
                ),
              );
              if (paired == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          const SizedBox(height: 12),

          // Option 2: Direct Connect
          _PairingOptionCard(
            icon: Icons.lan_outlined,
            iconColor: Colors.green,
            title: 'Direct Connect',
            description: 'Connect via local network or VPN',
            details: 'Requires node address and mTLS or token auth',
            onTap: () async {
              final paired = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const DirectConnectScreen(),
                ),
              );
              if (paired == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          const SizedBox(height: 12),

          // Option 3: QR Code (Offline)
          _PairingOptionCard(
            icon: Icons.qr_code_scanner,
            iconColor: Colors.purple,
            title: 'Scan QR Code',
            description: 'Offline pairing for air-gapped environments',
            details: 'Run: nitellad --pair-offline',
            onTap: () async {
              final paired = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const QrPairingScreen(),
                ),
              );
              if (paired == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),

          const SizedBox(height: 32),
          // Info section
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Node Pairing',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'When you pair a node, this app becomes its certificate authority. '
                        'The node receives a certificate signed by your identity, enabling '
                        'secure mutual TLS communication.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PairingOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String details;
  final VoidCallback onTap;

  const _PairingOptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.details,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
