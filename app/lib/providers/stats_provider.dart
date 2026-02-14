import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/local/nitella_local.pbgrpc.dart' as local_grpc;
import 'package:nitella_app/services/logic_service_client.dart';

class StatsState {
  final local.ConnectionStats? summary;
  final bool isLoading;
  final String? error;

  StatsState({
    this.summary,
    this.isLoading = false,
    this.error,
  });

  StatsState copyWith({
    local.ConnectionStats? summary,
    bool? isLoading,
    String? error,
  }) {
    return StatsState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StatsNotifier extends StateNotifier<StatsState> {
  final String? nodeId;
  Timer? _refreshTimer;
  bool _isRefreshing = false;
  Duration _pollInterval = const Duration(seconds: 5);
  final local_grpc.MobileLogicServiceClient _client;

  StatsNotifier(
      {this.nodeId, required local_grpc.MobileLogicServiceClient client})
      : _client = client,
        super(StatsState());

  void startPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_pollInterval, (_) => refresh());
    refresh();
  }

  void stopPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> refresh() async {
    if (!mounted || _isRefreshing) return;
    _isRefreshing = true;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _client.getConnectionStats(
        local.GetConnectionStatsRequest(nodeId: nodeId ?? ''),
      );
      final nextPollSeconds = stats.recommendedPollIntervalSeconds;
      if (nextPollSeconds > 0 &&
          _pollInterval.inSeconds != nextPollSeconds &&
          mounted) {
        _pollInterval = Duration(seconds: nextPollSeconds);
        startPolling();
      }

      if (mounted) {
        state = state.copyWith(summary: stats, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

final statsProvider = StateNotifierProvider.autoDispose
    .family<StatsNotifier, StatsState, String?>((ref, nodeId) {
  final notifier =
      StatsNotifier(nodeId: nodeId, client: ref.read(logicServiceProvider));
  notifier.startPolling();
  return notifier;
});

// Convenience provider for all nodes
final globalStatsProvider =
    StateNotifierProvider.autoDispose<StatsNotifier, StatsState>((ref) {
  final notifier = StatsNotifier(client: ref.read(logicServiceProvider));
  notifier.startPolling();
  return notifier;
});
