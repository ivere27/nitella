import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../utils/error_helper.dart';

class StatsScreen extends ConsumerStatefulWidget {
  final String? nodeId;
  const StatsScreen({super.key, this.nodeId});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  local.ConnectionStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleExport(String format) async {
    if (_stats == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No statistics to export')),
      );
      return;
    }

    try {
      final client = ref.read(logicServiceProvider);

      // Get additional data for export
      final geoResp = await client.getGeoStats(local.GetGeoStatsRequest(
        nodeId: widget.nodeId ?? '',
        type: local.GeoStatsType.GEO_STATS_TYPE_COUNTRY,
        limit: 100,
      ));
      final ipResp = await client.getIPStats(local.GetIPStatsRequest(
        nodeId: widget.nodeId ?? '',
        limit: 100,
      ));

      String content;
      String filename;

      if (format == 'csv') {
        content = _generateCSV(_stats!, geoResp.stats, ipResp.stats);
        filename = 'nitella_stats_${DateTime.now().millisecondsSinceEpoch}.csv';
      } else if (format == 'yaml') {
        content = _generateYAML(_stats!, geoResp.stats, ipResp.stats);
        filename = 'nitella_stats_${DateTime.now().millisecondsSinceEpoch}.yaml';
      } else {
        // Copy to clipboard
        content = _generateYAML(_stats!, geoResp.stats, ipResp.stats);
        await Clipboard.setData(ClipboardData(text: content));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Statistics copied to clipboard')),
          );
        }
        return;
      }

      // Save and share file
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(content);

      await Share.shareXFiles([XFile(file.path)], subject: 'Nitella Statistics');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${friendlyError(e)}')),
        );
      }
    }
  }

  String _generateCSV(local.ConnectionStats stats, List<local.GeoStats> geo, List<local.IPStats> ips) {
    final buffer = StringBuffer();

    // Summary section
    buffer.writeln('# Summary Statistics');
    buffer.writeln('Metric,Value');
    buffer.writeln('Total Connections,${stats.totalConnections}');
    buffer.writeln('Active Connections,${stats.activeConnections}');
    buffer.writeln('Unique IPs,${stats.uniqueIps}');
    buffer.writeln('Unique Countries,${stats.uniqueCountries}');
    buffer.writeln('Allowed,${stats.allowedTotal}');
    buffer.writeln('Blocked,${stats.blockedTotal}');
    buffer.writeln('Bytes In,${stats.bytesIn}');
    buffer.writeln('Bytes Out,${stats.bytesOut}');
    buffer.writeln();

    // Geo section
    buffer.writeln('# Geo Statistics');
    buffer.writeln('Country,Connections,Blocked,Unique IPs');
    for (final g in geo) {
      buffer.writeln('${g.value},${g.connectionCount},${g.blockedCount},${g.uniqueIps}');
    }
    buffer.writeln();

    // IP section
    buffer.writeln('# Top IPs');
    buffer.writeln('IP,Country,ISP,Connections,Blocked');
    for (final ip in ips) {
      buffer.writeln('${ip.sourceIp},${ip.geoCountry},${ip.geoIsp},${ip.connectionCount},${ip.blockedCount}');
    }

    return buffer.toString();
  }

  String _generateYAML(local.ConnectionStats stats, List<local.GeoStats> geo, List<local.IPStats> ips) {
    final buf = StringBuffer();
    buf.writeln('exported_at: ${DateTime.now().toIso8601String()}');
    buf.writeln('node_id: ${widget.nodeId ?? 'all'}');
    buf.writeln('summary:');
    buf.writeln('  total_connections: ${stats.totalConnections.toInt()}');
    buf.writeln('  active_connections: ${stats.activeConnections}');
    buf.writeln('  unique_ips: ${stats.uniqueIps}');
    buf.writeln('  unique_countries: ${stats.uniqueCountries}');
    buf.writeln('  allowed: ${stats.allowedTotal.toInt()}');
    buf.writeln('  blocked: ${stats.blockedTotal.toInt()}');
    buf.writeln('  bytes_in: ${stats.bytesIn.toInt()}');
    buf.writeln('  bytes_out: ${stats.bytesOut.toInt()}');
    if (geo.isNotEmpty) {
      buf.writeln('geo_stats:');
      for (final g in geo) {
        buf.writeln('  - country: ${g.value}');
        buf.writeln('    connections: ${g.connectionCount}');
        buf.writeln('    blocked: ${g.blockedCount}');
        buf.writeln('    unique_ips: ${g.uniqueIps}');
      }
    }
    if (ips.isNotEmpty) {
      buf.writeln('top_ips:');
      for (final ip in ips) {
        buf.writeln('  - ip: ${ip.sourceIp}');
        buf.writeln('    country: ${ip.geoCountry}');
        buf.writeln('    isp: ${ip.geoIsp}');
        buf.writeln('    connections: ${ip.connectionCount}');
        buf.writeln('    blocked: ${ip.blockedCount}');
      }
    }
    return buf.toString();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final stats = await client.getConnectionStats(
        local.GetConnectionStatsRequest(nodeId: widget.nodeId ?? ''),
      );
      if (mounted) {
        setState(() {
          _stats = stats;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nodeId != null ? 'Node Statistics' : 'Statistics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Summary'),
            Tab(text: 'Geo'),
            Tab(text: 'Top IPs'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export',
            onSelected: _handleExport,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 12),
                    Text('Export as CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'yaml',
                child: Row(
                  children: [
                    Icon(Icons.code),
                    SizedBox(width: 12),
                    Text('Export as YAML'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 12),
                    Flexible(child: Text('Copy to Clipboard')),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _StatsSummaryTab(stats: _stats, onRefresh: _refresh),
                    _StatsGeoTab(nodeId: widget.nodeId),
                    _StatsIPTab(nodeId: widget.nodeId),
                  ],
                ),
    );
  }
}

class _StatsSummaryTab extends StatelessWidget {
  final local.ConnectionStats? stats;
  final VoidCallback onRefresh;

  const _StatsSummaryTab({this.stats, required this.onRefresh});

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Center(child: Text('No statistics available'));
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            context,
            'Total Connections',
            stats!.totalConnections.toString(),
            Icons.swap_horiz,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  context,
                  'Unique IPs',
                  stats!.uniqueIps.toString(),
                  Icons.devices,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCard(
                  context,
                  'Countries',
                  stats!.uniqueCountries.toString(),
                  Icons.public,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  context,
                  'Allowed',
                  stats!.allowedTotal.toString(),
                  Icons.check_circle,
                  Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCard(
                  context,
                  'Blocked',
                  stats!.blockedTotal.toString(),
                  Icons.block,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data Transfer',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(_formatBytes(stats!.bytesIn.toInt()),
                              style: Theme.of(context).textTheme.headlineSmall),
                          const Text('Inbound',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      Column(
                        children: [
                          Text(_formatBytes(stats!.bytesOut.toInt()),
                              style: Theme.of(context).textTheme.headlineSmall),
                          const Text('Outbound',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}

class _StatsGeoTab extends ConsumerStatefulWidget {
  final String? nodeId;
  const _StatsGeoTab({this.nodeId});

  @override
  ConsumerState<_StatsGeoTab> createState() => _StatsGeoTabState();
}

class _StatsGeoTabState extends ConsumerState<_StatsGeoTab> {
  List<local.GeoStats> _geoStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.getGeoStats(local.GetGeoStatsRequest(
        nodeId: widget.nodeId ?? '',
        type: local.GeoStatsType.GEO_STATS_TYPE_COUNTRY,
        limit: 50,
      ));
      if (mounted) {
        setState(() {
          _geoStats = resp.stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_geoStats.isEmpty) {
      return const Center(child: Text('No geo statistics yet'));
    }

    return ListView.builder(
      itemCount: _geoStats.length,
      itemBuilder: (context, index) {
        final item = _geoStats[index];
        return ListTile(
          leading: Text(item.value.isEmpty ? "??" : item.value,
              style: const TextStyle(fontSize: 24)),
          title: Text(item.value.isEmpty ? "Unknown" : item.value),
          subtitle: Text('${item.uniqueIps} unique IPs'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${item.connectionCount} conns"),
              Text("${item.blockedCount} blocked",
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

class _StatsIPTab extends ConsumerStatefulWidget {
  final String? nodeId;
  const _StatsIPTab({this.nodeId});

  @override
  ConsumerState<_StatsIPTab> createState() => _StatsIPTabState();
}

class _StatsIPTabState extends ConsumerState<_StatsIPTab> {
  List<local.IPStats> _ipStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.getIPStats(local.GetIPStatsRequest(
        nodeId: widget.nodeId ?? '',
        limit: 50,
      ));
      if (mounted) {
        setState(() {
          _ipStats = resp.stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_ipStats.isEmpty) {
      return const Center(child: Text('No IP statistics yet'));
    }

    return ListView.separated(
      itemCount: _ipStats.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _ipStats[index];
        return ListTile(
          title: Text(item.sourceIp),
          subtitle: Text('${item.geoCountry} • ${item.geoIsp}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${item.connectionCount} conns"),
              if (item.blockedCount > 0)
                Text("${item.blockedCount} blocked",
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}
