import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/common/common.pb.dart' as common;
import '../main.dart';
import '../utils/error_helper.dart';

// Provider to store recent lookups
final recentLookupsProvider = StateProvider<List<_LookupResult>>((ref) => []);

class _LookupResult {
  final String ip;
  final common.GeoInfo geo;
  final DateTime timestamp;

  _LookupResult({required this.ip, required this.geo, required this.timestamp});
}

class GeoIPLookupScreen extends ConsumerStatefulWidget {
  final List<local.NodeInfo> nodes;

  const GeoIPLookupScreen({super.key, required this.nodes});

  @override
  ConsumerState<GeoIPLookupScreen> createState() => _GeoIPLookupScreenState();
}

class _GeoIPLookupScreenState extends ConsumerState<GeoIPLookupScreen> {
  final _ipController = TextEditingController();
  common.GeoInfo? _result;
  bool _isLoading = false;
  String? _error;
  String _currentIp = '';

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      setState(() => _error = 'Please enter an IP address');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
      _currentIp = ip;
    });

    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.lookupIP(local.LookupIPRequest(ip: ip));
      if (mounted) {
        setState(() {
          _result = resp.geo;
          _isLoading = false;
        });

        // Add to recent lookups
        final recent = ref.read(recentLookupsProvider);
        final newRecent = [
          _LookupResult(ip: ip, geo: resp.geo, timestamp: DateTime.now()),
          ...recent
              .where((r) => r.ip != ip)
              .take(9), // Keep last 10, no duplicates
        ];
        ref.read(recentLookupsProvider.notifier).state = newRecent;
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

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  void _loadFromRecent(_LookupResult result) {
    _ipController.text = result.ip;
    setState(() {
      _currentIp = result.ip;
      _result = result.geo;
      _error = null;
    });
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

  Future<void> _blockIP() async {
    final ip = _ipController.text.trim();
    final nodeId = await _selectNode();
    if (nodeId == null) return;

    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.blockIP(local.BlockIPRequest(
        nodeId: nodeId,
        ip: ip,
      ));
      if (mounted) {
        if (resp.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Blocked $ip')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${resp.error}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }

  Future<void> _blockCountry() async {
    if (_result == null || _result!.country.isEmpty) return;
    final nodeId = await _selectNode();
    if (nodeId == null) return;

    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.blockCountry(local.BlockCountryRequest(
        nodeId: nodeId,
        country: _result!.country,
      ));
      if (mounted) {
        if (resp.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Blocked country: ${_result!.country}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${resp.error}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }

  Future<void> _blockISP() async {
    if (_result == null || _result!.isp.isEmpty) return;
    final nodeId = await _selectNode();
    if (nodeId == null) return;

    try {
      final client = ref.read(logicServiceProvider);
      final resp = await client.blockISP(local.BlockISPRequest(
        nodeId: nodeId,
        isp: _result!.isp,
      ));
      if (mounted) {
        if (resp.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Blocked ISP: ${_result!.isp}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${resp.error}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${friendlyError(e)}')),
        );
      }
    }
  }

  Future<String?> _selectNode() async {
    if (widget.nodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No nodes available')),
      );
      return null;
    }

    if (widget.nodes.length == 1) {
      return widget.nodes.first.nodeId;
    }

    return showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Node'),
        children: widget.nodes.map((node) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, node.nodeId),
            child: Text(node.name.isNotEmpty ? node.name : node.nodeId),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentLookups = ref.watch(recentLookupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoIP Lookup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IP input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipController,
                    decoration: InputDecoration(
                      labelText: 'IP Address',
                      hintText: '203.0.113.45',
                      border: const OutlineInputBorder(),
                      errorText: _error,
                      suffixIcon: _ipController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _ipController.clear();
                                setState(() {
                                  _result = null;
                                  _error = null;
                                });
                              },
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _lookup(),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _isLoading ? null : _lookup,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Lookup'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Results
            if (_result != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with IP and copy button
                      Row(
                        children: [
                          Text(
                            _currentIp,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () => _copyToClipboard(_currentIp, 'IP'),
                            tooltip: 'Copy IP',
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildResultRow(
                        'Country',
                        '${_getCountryFlag(_result!.country)} ${_result!.country}',
                      ),
                      _buildResultRow('City', _result!.city),
                      _buildResultRow('Region', _result!.region),
                      _buildResultRow('ISP', _result!.isp),
                      _buildResultRow('ASN', _result!.as),
                      if (_result!.org.isNotEmpty)
                        _buildResultRow('Organization', _result!.org),
                      if (_result!.timezone.isNotEmpty)
                        _buildResultRow('Timezone', _result!.timezone),
                      if (_result!.latitude != 0 || _result!.longitude != 0)
                        _buildResultRow(
                          'Coordinates',
                          '${_result!.latitude.toStringAsFixed(4)}, ${_result!.longitude.toStringAsFixed(4)}',
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick block buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _blockIP,
                    icon: const Icon(Icons.block, size: 18),
                    label: const Text('Block IP'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  if (_result!.country.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: _blockCountry,
                      icon: const Icon(Icons.public, size: 18),
                      label: Text('Block ${_result!.country}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  if (_result!.isp.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: _blockISP,
                      icon: const Icon(Icons.business, size: 18),
                      label: const Text('Block ISP'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                ],
              ),
            ],

            // Empty state
            if (_result == null &&
                !_isLoading &&
                _error == null &&
                recentLookups.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.public, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Enter an IP address to lookup',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),

            // Recent lookups section
            if (recentLookups.isNotEmpty && _result == null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Recent Lookups',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(recentLookupsProvider.notifier).state = [];
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...recentLookups.map((result) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => _loadFromRecent(result),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Text(
                          _getCountryFlag(result.geo.country),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        result.ip,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      subtitle: Text(
                        '${result.geo.city.isNotEmpty ? '${result.geo.city}, ' : ''}${result.geo.country} \u2022 ${result.geo.isp}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
