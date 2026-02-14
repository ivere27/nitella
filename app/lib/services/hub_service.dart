import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:nitella_app/local/nitella_local.pbgrpc.dart' as local;
import 'package:nitella_app/services/auth_service.dart';
import 'package:nitella_app/services/logic_service_client.dart';
import 'package:nitella_app/utils/logger.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';

class HubTrustWarning {
  final String hubAddress;
  final String fingerprint;
  final String emojiHash;
  final String subject;
  final String expires;
  final String challengeId;

  const HubTrustWarning({
    required this.hubAddress,
    required this.fingerprint,
    required this.emojiHash,
    required this.subject,
    required this.expires,
    required this.challengeId,
  });
}

class HubService {
  static final HubService _instance = HubService._internal();
  factory HubService() => _instance;
  HubService._internal();

  final local.MobileLogicServiceClient _mobileLogicClient =
      createLogicServiceClient();

  bool _isHubAddressNotConfiguredError(String error) {
    final normalized = error.trim().toLowerCase();
    return normalized.contains('hub address not specified') ||
        normalized.contains('hub not configured') ||
        normalized.contains('hub address not set');
  }

  HubTrustWarning _warningFromChallenge(
    local.HubTrustChallenge challenge,
    String fallbackHubAddress,
  ) {
    return HubTrustWarning(
      hubAddress: fallbackHubAddress,
      fingerprint: challenge.fingerprint,
      emojiHash: challenge.emojiHash,
      subject: challenge.subject,
      expires: challenge.expires,
      challengeId: challenge.challengeId,
    );
  }

  HubTrustWarning _warningFromResponse(
    local.OnboardHubResponse resp,
    String fallbackHubAddress,
  ) {
    final challenge = resp.hasTrustChallenge()
        ? resp.trustChallenge
        : local.HubTrustChallenge();
    final resolvedHubAddress =
        resp.hubAddress.isNotEmpty ? resp.hubAddress : fallbackHubAddress;
    return _warningFromChallenge(challenge, resolvedHubAddress);
  }

  Future<HubTrustWarning?> getPendingTrustWarning() async {
    try {
      final snapshot = await _mobileLogicClient.getHubSettingsSnapshot(Empty());
      if (!snapshot.hasPendingTrustChallenge()) {
        return null;
      }
      final fallbackHubAddress = snapshot.resolvedHubAddress.isNotEmpty
          ? snapshot.resolvedHubAddress
          : (snapshot.hasStatus() ? snapshot.status.hubAddress : '');
      return _warningFromChallenge(
        snapshot.pendingTrustChallenge,
        fallbackHubAddress,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    try {
      final resp = await _mobileLogicClient
          .ensureHubConnected(local.EnsureHubConnectedRequest());
      if (resp.success) {
        final resolvedHub =
            resp.hubAddress.isNotEmpty ? resp.hubAddress : '(default)';
        logger.i("HubService init connected: $resolvedHub");
        return;
      }

      if (_isHubAddressNotConfiguredError(resp.error)) {
        logger.i("Hub not configured. Skipping Hub initialization.");
        return;
      }

      if (resp.stage == local.OnboardHubResponse_Stage.STAGE_NEEDS_TRUST) {
        logger.i(
            "Hub initialization requires trust verification in Hub Settings.");
        return;
      }
      if (!resp.success) {
        logger.w("Hub initialization failed: ${resp.error}");
        return;
      }
    } catch (e) {
      logger.w("HubService init failed", error: e);
    }
  }

  Future<local.OnboardHubResponse> ensureRegisteredWithTrustFlow({
    String? hubAddress,
    String? inviteCode,
    bool persistSettings = false,
    Future<bool> Function(HubTrustWarning warning)? onTrustPrompt,
  }) async {
    final resolvedHubAddress = (hubAddress ?? '').trim();
    final resolvedInviteCode = (inviteCode ?? '').trim();
    final biometricPublicKey =
        await AuthService().getOrCreateBiometricPublicKey(
      createIfMissing: true,
    );

    local.OnboardHubResponse response =
        await _mobileLogicClient.ensureHubRegistered(
      local.EnsureHubRegisteredRequest(
        hubAddress: resolvedHubAddress,
        inviteCode: resolvedInviteCode,
        biometricPublicKey: biometricPublicKey,
        persistSettings: persistSettings,
      ),
    );

    if (response.stage == local.OnboardHubResponse_Stage.STAGE_NEEDS_TRUST &&
        response.hasTrustChallenge() &&
        onTrustPrompt != null) {
      final fallbackHubAddress = resolvedHubAddress.isNotEmpty
          ? resolvedHubAddress
          : response.hubAddress;
      final warning = _warningFromResponse(response, fallbackHubAddress);
      final accepted = await onTrustPrompt(warning);
      if (warning.challengeId.isEmpty) {
        return local.OnboardHubResponse(
          stage: local.OnboardHubResponse_Stage.STAGE_FAILED,
          success: false,
          error: 'Hub trust challenge is missing challenge id',
        );
      }
      response = await _mobileLogicClient.resolveHubTrustChallenge(
        local.ResolveHubTrustChallengeRequest(
          challengeId: warning.challengeId,
          accepted: accepted,
        ),
      );
    }

    if (response.success && response.userId.isNotEmpty) {
      await syncFcmToken();
    }
    return response;
  }

  Future<String?> getUserId() async {
    try {
      final snapshot = await _mobileLogicClient.getHubSettingsSnapshot(Empty());
      if (snapshot.hasStatus() && snapshot.status.userId.isNotEmpty) {
        return snapshot.status.userId;
      }
    } catch (_) {}
    return null;
  }

  Future<void> ensureRegistered() async {
    try {
      final response = await ensureRegisteredWithTrustFlow();
      if (response.stage == local.OnboardHubResponse_Stage.STAGE_NEEDS_TRUST) {
        throw "Hub requires certificate trust verification in Hub Settings.";
      }
      if (!response.success) {
        throw "Onboarding failed: ${response.error}";
      }
      if (response.userId.isEmpty) {
        throw "Onboarding succeeded but no user ID was returned.";
      }
      logger.i("Registered with Hub. UserID: ${response.userId}");
    } catch (e) {
      logger.e("Failed to register with Hub", error: e);
      rethrow;
    }
  }

  Future<void> syncFcmToken() async {
    try {
      if (!kIsWeb &&
          (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
        logger.d("Skipping FCM token sync on desktop");
        return;
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await _mobileLogicClient.registerFCMToken(local.RegisterFCMTokenRequest(
        fcmToken: token,
        deviceType: Platform.isIOS
            ? local.DeviceType.DEVICE_TYPE_IOS
            : local.DeviceType.DEVICE_TYPE_ANDROID,
      ));
      logger.i("FCM Token synced.");
    } catch (e) {
      logger.e("Failed to sync FCM token", error: e);
    }
  }

  Future<void> disconnect() async {
    try {
      await _mobileLogicClient.disconnectFromHub(Empty());
      logger.i("Disconnected from Hub");
    } catch (e) {
      logger.e("Failed to disconnect from Hub", error: e);
    }
  }

  Future<local.HubStatus> getHubStatus() async {
    final snapshot = await _mobileLogicClient.getHubSettingsSnapshot(Empty());
    return snapshot.hasStatus() ? snapshot.status : local.HubStatus();
  }
}
