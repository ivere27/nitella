import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/local/nitella_local.pbgrpc.dart' as local_grpc;
import 'package:nitella_app/services/logic_service_client.dart';

class ActiveApprovalsNotifier
    extends StateNotifier<List<local.ApprovalRequest>> {
  Timer? _refreshTimer;
  bool _isRefreshing = false;
  Duration _pollInterval = const Duration(seconds: 5);
  final local_grpc.MobileLogicServiceClient _client;

  ActiveApprovalsNotifier(this._client) : super([]);

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
    try {
      final snapshot =
          await _client.getApprovalsSnapshot(local.GetApprovalsSnapshotRequest(
        includeHistory: false,
      ));
      final nextPollSeconds = snapshot.recommendedPollIntervalSeconds;
      if (nextPollSeconds > 0 &&
          _pollInterval.inSeconds != nextPollSeconds &&
          mounted) {
        _pollInterval = Duration(seconds: nextPollSeconds);
        startPolling();
      }
      if (mounted) {
        state = snapshot.pendingRequests;
      }
    } catch (_) {
    } finally {
      _isRefreshing = false;
    }
  }

  void setApprovals(List<local.ApprovalRequest> approvals) {
    state = approvals;
  }

  void removeApproval(String requestId) {
    state = state.where((r) => r.requestId != requestId).toList();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

final activeApprovalsProvider = StateNotifierProvider.autoDispose<
    ActiveApprovalsNotifier, List<local.ApprovalRequest>>((ref) {
  final notifier = ActiveApprovalsNotifier(ref.read(logicServiceProvider));
  notifier.startPolling();
  return notifier;
});
