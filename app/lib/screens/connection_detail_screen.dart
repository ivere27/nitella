import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import '../main.dart';
import '../utils/error_helper.dart';

class ConnectionDetailScreen extends ConsumerStatefulWidget {
  final String nodeId;
  final String proxyId;
  final String proxyName;
  final local.ConnectionInfo connection;

  const ConnectionDetailScreen({
    super.key,
    required this.nodeId,
    required this.proxyId,
    required this.proxyName,
    required this.connection,
  });

  @override
  ConsumerState<ConnectionDetailScreen> createState() =>
      _ConnectionDetailScreenState();
}

class _ConnectionDetailScreenState
    extends ConsumerState<ConnectionDetailScreen> {
  local.IPStats? _ipStats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIPStats();
  }

  Future<void> _loadIPStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.getIPStats(local.GetIPStatsRequest(
        nodeId: widget.nodeId,
        sourceIpFilter: widget.connection.sourceIp,
        limit: 1,
      ));
      if (mounted) {
        setState(() {
          _ipStats = resp.stats.isNotEmpty ? resp.stats.first : null;
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

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatDuration(DateTime start) {
    final duration = DateTime.now().difference(start);
    if (duration.inSeconds < 60) return '${duration.inSeconds}s';
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  String _getCountryFlag(String country) {
    final flags = {
      'US': '\u{1F1FA}\u{1F1F8}',
      'KR': '\u{1F1F0}\u{1F1F7}',
      'JP': '\u{1F1EF}\u{1F1F5}',
      'CN': '\u{1F1E8}\u{1F1F3}',
      'DE': '\u{1F1E9}\u{1F1EA}',
      'GB': '\u{1F1EC}\u{1F1E7}',
      'FR': '\u{1F1EB}\u{1F1F7}',
      'CA': '\u{1F1E8}\u{1F1E6}',
      'AU': '\u{1F1E6}\u{1F1FA}',
      'BR': '\u{1F1E7}\u{1F1F7}',
      'IN': '\u{1F1EE}\u{1F1F3}',
      'RU': '\u{1F1F7}\u{1F1FA}',
    };
    return flags[country.toUpperCase()] ?? '\u{1F310}';
  }

  Future<void> _closeConnection() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close Connection'),
        content: Text('Close connection from ${widget.connection.sourceIp}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final client = ref.read(logicServiceProvider);
        await client.closeConnection(local.CloseConnectionRequest(
          nodeId: widget.nodeId,
          proxyId: widget.proxyId,
          connId: widget.connection.connId,
        ));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connection closed')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${friendlyError(e)}')),
          );
        }
      }
    }
  }

  Future<void> _blockIP() async {
    final ip = widget.connection.sourceIp;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block IP'),
        content: Text('Add a rule to block all connections from $ip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final client = ref.read(logicServiceProvider);
        final resp = await client.blockIP(local.BlockIPRequest(
          nodeId: widget.nodeId,
          proxyId: widget.proxyId,
          ip: ip,
        ));
        if (mounted) {
          if (resp.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Blocked $ip')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed: ${resp.error}')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${friendlyError(e)}')),
          );
        }
      }
    }
  }

  Future<void> _allowIP() async {
    final ip = widget.connection.sourceIp;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Allow IP'),
        content:
            Text('Add a rule to explicitly allow all connections from $ip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final client = ref.read(logicServiceProvider);
        final resp = await client.allowIP(local.AllowIPRequest(
          nodeId: widget.nodeId,
          proxyId: widget.proxyId,
          ip: ip,
        ));
        if (mounted) {
          if (resp.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Allowed $ip')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed: ${resp.error}')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${friendlyError(e)}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final conn = widget.connection;
    final geo = conn.hasGeo() ? conn.geo : null;
    final startTime =
        conn.hasStartTime() ? conn.startTime.toDateTime() : DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(conn.sourceIp),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Connection Section
                      _buildSectionHeader('Current Connection'),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                  'Status', '\u{1F7E2} Active', Colors.green),
                              _buildInfoRow(
                                  'Duration', _formatDuration(startTime)),
                              _buildInfoRow('Bandwidth',
                                  '\u{2191} ${_formatBytes(conn.bytesOut.toInt())}/s  \u{2193} ${_formatBytes(conn.bytesIn.toInt())}/s'),
                              _buildInfoRow('Bytes',
                                  '\u{2191} ${_formatBytes(conn.bytesOut.toInt())}  \u{2193} ${_formatBytes(conn.bytesIn.toInt())}'),
                              _buildInfoRow('Proxy',
                                  '${widget.proxyName} (:${_getPort()})'),
                              _buildInfoRow('Destination', conn.destAddr),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // GeoIP Information Section
                      _buildSectionHeader('GeoIP Information'),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: geo != null
                              ? Column(
                                  children: [
                                    _buildInfoRow(
                                      'Country',
                                      '${_getCountryFlag(geo.country)} ${geo.country}',
                                    ),
                                    _buildInfoRow('City',
                                        geo.city.isNotEmpty ? geo.city : '-'),
                                    _buildInfoRow('ISP',
                                        geo.isp.isNotEmpty ? geo.isp : '-'),
                                    _buildInfoRow('ASN',
                                        geo.as.isNotEmpty ? geo.as : '-'),
                                    _buildInfoRow('Organization',
                                        geo.org.isNotEmpty ? geo.org : '-'),
                                  ],
                                )
                              : const Center(
                                  child: Text('GeoIP data not available'),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // IP History Section
                      if (_ipStats != null) ...[
                        _buildSectionHeader('IP History (All Time)'),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildInfoRow('Total Connections',
                                    '${_ipStats!.connectionCount}'),
                                _buildInfoRow('Blocked Count',
                                    '${_ipStats!.blockedCount}'),
                                _buildInfoRow('Allowed Count',
                                    '${_ipStats!.allowedCount}'),
                                const Divider(),
                                _buildInfoRow(
                                    'Total Bytes In',
                                    _formatBytes(
                                        _ipStats!.totalBytesIn.toInt())),
                                _buildInfoRow(
                                    'Total Bytes Out',
                                    _formatBytes(
                                        _ipStats!.totalBytesOut.toInt())),
                                const Divider(),
                                if (_ipStats!.hasFirstSeen())
                                  _buildInfoRow(
                                      'First Seen',
                                      _formatDateTime(
                                          _ipStats!.firstSeen.toDateTime())),
                                if (_ipStats!.hasLastSeen())
                                  _buildInfoRow(
                                      'Last Seen',
                                      _formatDateTime(
                                          _ipStats!.lastSeen.toDateTime())),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _closeConnection,
                              icon: const Icon(Icons.close),
                              label: const Text('Close Connection'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _blockIP,
                              icon: const Icon(Icons.block),
                              label: const Text('Block IP'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _allowIP,
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Allow IP'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  String _getPort() {
    // Extract port from destAddr if available
    final destAddr = widget.connection.destAddr;
    if (destAddr.contains(':')) {
      return destAddr.split(':').last;
    }
    return '???';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
