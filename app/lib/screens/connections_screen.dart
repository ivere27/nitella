import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import '../main.dart';
import '../utils/error_helper.dart';
import 'connection_detail_screen.dart';

class ConnectionsScreen extends ConsumerStatefulWidget {
  final String nodeId;
  final String proxyId;
  final String proxyName;

  const ConnectionsScreen({
    super.key,
    required this.nodeId,
    required this.proxyId,
    required this.proxyName,
  });

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

enum _SortMode { recent, bandwidth, duration }

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  List<local.ConnectionInfo> _connections = [];
  bool _isLoading = true;
  String? _error;
  final bool _activeOnly = true;
  bool _isPaused = false;
  bool _autoRefresh = true;
  Timer? _refreshTimer;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  int _selectedCountryIndex = 0; // 0 = All
  _SortMode _sortMode = _SortMode.recent;

  @override
  void initState() {
    super.initState();
    _refresh();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    if (_autoRefresh && !_isPaused) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (!_isPaused && mounted) _refresh();
      });
    }
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_isPaused) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.listConnections(local.ListConnectionsRequest(
        nodeId: widget.nodeId,
        proxyId: widget.proxyId,
        activeOnly: _activeOnly,
        limit: 100,
      ));
      if (mounted) {
        setState(() {
          _connections = resp.connections;
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

  List<local.ConnectionInfo> get _filteredConnections {
    var list = _connections;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      list = list.where((c) {
        final query = _searchQuery.toLowerCase();
        return c.sourceIp.toLowerCase().contains(query) ||
            (c.hasGeo() && c.geo.country.toLowerCase().contains(query)) ||
            (c.hasGeo() && c.geo.city.toLowerCase().contains(query)) ||
            (c.hasGeo() && c.geo.isp.toLowerCase().contains(query));
      }).toList();
    }

    // Filter by country
    if (_selectedCountryIndex > 0) {
      final countries = _getCountries();
      if (_selectedCountryIndex <= countries.length) {
        final country = countries[_selectedCountryIndex - 1];
        list =
            list.where((c) => c.hasGeo() && c.geo.country == country).toList();
      }
    }

    // Sort
    switch (_sortMode) {
      case _SortMode.recent:
        list.sort((a, b) {
          final aTime = a.hasStartTime() ? a.startTime.toDateTime() : DateTime(0);
          final bTime = b.hasStartTime() ? b.startTime.toDateTime() : DateTime(0);
          return bTime.compareTo(aTime); // newest first
        });
      case _SortMode.bandwidth:
        list.sort((a, b) {
          final aTotal = a.bytesIn.toInt() + a.bytesOut.toInt();
          final bTotal = b.bytesIn.toInt() + b.bytesOut.toInt();
          return bTotal.compareTo(aTotal); // highest first
        });
      case _SortMode.duration:
        list.sort((a, b) {
          final aTime = a.hasStartTime() ? a.startTime.toDateTime() : DateTime.now();
          final bTime = b.hasStartTime() ? b.startTime.toDateTime() : DateTime.now();
          return aTime.compareTo(bTime); // longest first (earliest start)
        });
    }

    return list;
  }

  List<String> _getCountries() {
    final countries = <String>{};
    for (final conn in _connections) {
      if (conn.hasGeo() && conn.geo.country.isNotEmpty) {
        countries.add(conn.geo.country);
      }
    }
    return countries.toList()..sort();
  }

  Map<String, int> _getCountryStats() {
    final stats = <String, int>{};
    for (final conn in _connections) {
      if (conn.hasGeo() && conn.geo.country.isNotEmpty) {
        stats[conn.geo.country] = (stats[conn.geo.country] ?? 0) + 1;
      }
    }
    return stats;
  }

  int _getTotalBytesIn() {
    return _connections.fold(0, (sum, c) => sum + c.bytesIn.toInt());
  }

  int _getTotalBytesOut() {
    return _connections.fold(0, (sum, c) => sum + c.bytesOut.toInt());
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDuration(DateTime start) {
    final duration = DateTime.now().difference(start);
    if (duration.inSeconds < 60) return '${duration.inSeconds}s';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m';
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }

  String _getCountryFlag(String country) {
    // Simple country code to flag emoji mapping
    final flags = {
      'US': '🇺🇸',
      'KR': '🇰🇷',
      'JP': '🇯🇵',
      'CN': '🇨🇳',
      'DE': '🇩🇪',
      'GB': '🇬🇧',
      'FR': '🇫🇷',
      'CA': '🇨🇦',
      'AU': '🇦🇺',
      'BR': '🇧🇷',
      'IN': '🇮🇳',
      'RU': '🇷🇺',
    };
    return flags[country.toUpperCase()] ?? '🌐';
  }

  Future<void> _closeConnection(local.ConnectionInfo conn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close Connection'),
        content: Text('Close connection from ${conn.sourceIp}?'),
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
          connId: conn.connId,
        ));
        _refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connection closed')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to close: ${friendlyError(e)}')),
          );
        }
      }
    }
  }

  Future<void> _closeAllConnections() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close All Connections'),
        content: Text(
            'Close all ${_connections.length} connections on ${widget.proxyName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Close All'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final client = ref.read(logicServiceProvider);
        final resp =
            await client.closeAllConnections(local.CloseAllConnectionsRequest(
          nodeId: widget.nodeId,
          proxyId: widget.proxyId,
        ));
        _refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Closed ${resp.closedCount} connections')),
          );
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

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _stopAutoRefresh();
      } else {
        _refresh();
        _startAutoRefresh();
      }
    });
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
      if (_autoRefresh) {
        _startAutoRefresh();
      } else {
        _stopAutoRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredConnections = _filteredConnections;
    final countries = _getCountries();
    final countryStats = _getCountryStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        actions: [
          // Auto-refresh toggle
          IconButton(
            icon: Icon(
              _autoRefresh ? Icons.sync : Icons.sync_disabled,
              color: _autoRefresh ? Colors.green : Colors.grey,
            ),
            onPressed: _toggleAutoRefresh,
            tooltip: _autoRefresh ? 'Auto-refresh ON' : 'Auto-refresh OFF',
          ),
          // Pause/Resume
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _togglePause,
            tooltip: _isPaused ? 'Resume' : 'Pause',
          ),
          // Close All
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'close_all') _closeAllConnections();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'close_all',
                enabled: _connections.isNotEmpty,
                child: const Row(
                  children: [
                    Icon(Icons.close, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Close All Connections', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with proxy info and totals
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${widget.proxyName} \u2022 ${_connections.length} active',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (_isPaused)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('PAUSED',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      )
                    else if (_autoRefresh)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sync, size: 12, color: Colors.green.shade700),
                            const SizedBox(width: 4),
                            Text('LIVE',
                                style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\u2191 ${_formatBytes(_getTotalBytesOut())}/s  \u2193 ${_formatBytes(_getTotalBytesIn())}/s (total)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Filter by IP, Country, ISP...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Country filter chips
          if (countries.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _FilterChip(
                    label: 'All: ${_connections.length}',
                    selected: _selectedCountryIndex == 0,
                    onTap: () => setState(() => _selectedCountryIndex = 0),
                  ),
                  ...countries.asMap().entries.map((e) => _FilterChip(
                        label:
                            '${_getCountryFlag(e.value)} ${e.value}: ${countryStats[e.value]}',
                        selected: _selectedCountryIndex == e.key + 1,
                        onTap: () =>
                            setState(() => _selectedCountryIndex = e.key + 1),
                      )),
                ],
              ),
            ),

          // Sort options
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: 'Recent',
                  selected: _sortMode == _SortMode.recent,
                  onTap: () => setState(() => _sortMode = _SortMode.recent),
                ),
                _FilterChip(
                  label: 'Bandwidth',
                  selected: _sortMode == _SortMode.bandwidth,
                  onTap: () => setState(() => _sortMode = _SortMode.bandwidth),
                ),
                _FilterChip(
                  label: 'Duration',
                  selected: _sortMode == _SortMode.duration,
                  onTap: () => setState(() => _sortMode = _SortMode.duration),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Connection list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : filteredConnections.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.hub_outlined,
                                    size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No matching connections'
                                      : _activeOnly
                                          ? 'No active connections'
                                          : 'No connections',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.builder(
                              itemCount: filteredConnections.length,
                              itemBuilder: (context, index) {
                                return _buildConnectionCard(
                                    filteredConnections[index]);
                              },
                            ),
                          ),
          ),

          // Footer hint
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Tap for IP details • [✕] to close connection',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(local.ConnectionInfo conn) {
    final geo = conn.hasGeo() ? conn.geo : null;
    final startTime =
        conn.hasStartTime() ? conn.startTime.toDateTime() : DateTime.now();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConnectionDetailScreen(
                nodeId: widget.nodeId,
                proxyId: widget.proxyId,
                proxyName: widget.proxyName,
                connection: conn,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Country avatar
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Text(
                  geo?.country.isNotEmpty == true
                      ? _getCountryFlag(geo!.country)
                      : '🌐',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),

              // Connection info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conn.sourceIp,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (geo != null)
                      Text(
                        '${_getCountryFlag(geo.country)} ${geo.city.isNotEmpty ? '${geo.city}, ' : ''}${geo.country} • ${geo.isp}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '↑ ${_formatBytes(conn.bytesOut.toInt())}/s  ↓ ${_formatBytes(conn.bytesIn.toInt())}/s',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${_formatDuration(startTime)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chevron_right, color: Colors.grey),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red.shade400),
                    iconSize: 20,
                    onPressed: () => _closeConnection(conn),
                    tooltip: 'Close connection',
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
      ),
    );
  }
}
