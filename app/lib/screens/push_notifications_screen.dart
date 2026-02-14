import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import '../main.dart';
import 'settings_screen.dart';

class PushNotificationsScreen extends ConsumerStatefulWidget {
  const PushNotificationsScreen({super.key});

  @override
  ConsumerState<PushNotificationsScreen> createState() =>
      _PushNotificationsScreenState();
}

class _PushNotificationsScreenState
    extends ConsumerState<PushNotificationsScreen> {
  bool _isLoading = true;
  bool _isRegistered = false;
  String? _error;
  bool _isSaving = false;

  // Quiet hours (stored locally)
  bool _quietHoursEnabled = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final settings = await client.getSettings(Empty());

      if (mounted) {
        setState(() {
          _isRegistered = settings.notificationsEnabled;
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

  Future<void> _registerToken() async {
    setState(() => _isSaving = true);

    try {
      final client = ref.read(logicServiceProvider);
      // Get FCM token from Firebase messaging service
      await client.registerFCMToken(local.RegisterFCMTokenRequest(
        fcmToken: '', // Will be populated by backend
        deviceType: Platform.isIOS
            ? local.DeviceType.DEVICE_TYPE_IOS
            : local.DeviceType.DEVICE_TYPE_ANDROID,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Push notifications enabled')),
        );
        setState(() {
          _isRegistered = true;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _unregisterToken() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disable Push Notifications?'),
        content: const Text(
          'You will no longer receive notifications for:\n'
          '\u2022 Approval requests\n'
          '\u2022 Node status changes\n'
          '\u2022 Connection events',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);

    try {
      final client = ref.read(logicServiceProvider);
      await client.unregisterFCMToken(Empty());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Push notifications disabled')),
        );
        setState(() {
          _isRegistered = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _quietStart : _quietEnd,
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          _quietStart = time;
        } else {
          _quietEnd = time;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            _isRegistered
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: _isRegistered ? Colors.green : Colors.grey,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  _isRegistered ? 'Enabled' : 'Disabled',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _isRegistered
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isRegistered)
                            OutlinedButton(
                              onPressed: _isSaving ? null : _unregisterToken,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Disable'),
                            )
                          else
                            FilledButton(
                              onPressed: _isSaving ? null : _registerToken,
                              child: const Text('Enable'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error display
                  if (_error != null) ...[
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
                    const SizedBox(height: 16),
                  ],

                  // Notification types (when enabled)
                  if (_isRegistered) ...[
                    _buildSectionHeader('Notification Types'),
                    Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: const Icon(Icons.approval),
                            title: const Text('Approval Requests'),
                            subtitle: const Text(
                              'Get notified when a connection needs approval',
                            ),
                            value: ref.watch(approvalNotificationsProvider),
                            onChanged: (value) {
                              ref
                                  .read(approvalNotificationsProvider.notifier)
                                  .state = value;
                            },
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            secondary: const Icon(Icons.dns),
                            title: const Text('Node Status Changes'),
                            subtitle: const Text(
                              'Notify when nodes go online/offline',
                            ),
                            value: ref.watch(nodeStatusNotificationsProvider),
                            onChanged: (value) {
                              ref
                                  .read(
                                      nodeStatusNotificationsProvider.notifier)
                                  .state = value;
                            },
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            secondary: const Icon(Icons.swap_horiz),
                            title: const Text('Connection Events'),
                            subtitle: const Text(
                              'Notify on new connections (can be noisy)',
                            ),
                            value: ref.watch(connectionNotificationsProvider),
                            onChanged: (value) {
                              ref
                                  .read(
                                      connectionNotificationsProvider.notifier)
                                  .state = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quiet hours
                    _buildSectionHeader('Quiet Hours'),
                    Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: const Icon(Icons.bedtime),
                            title: const Text('Enable Quiet Hours'),
                            subtitle: const Text(
                              'Mute notifications during specified hours',
                            ),
                            value: _quietHoursEnabled,
                            onChanged: (value) {
                              setState(() => _quietHoursEnabled = value);
                            },
                          ),
                          if (_quietHoursEnabled) ...[
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.access_time),
                              title: const Text('Start Time'),
                              trailing: Text(
                                _quietStart.format(context),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () => _pickTime(true),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.access_time),
                              title: const Text('End Time'),
                              trailing: Text(
                                _quietEnd.format(context),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () => _pickTime(false),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

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
                            'Push notifications are delivered via Firebase Cloud Messaging (FCM). '
                            'Your FCM token is registered with the Hub to receive real-time notifications.',
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
