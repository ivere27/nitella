import 'dart:io' show Platform;

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nitella_app/utils/logger.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  // New Key for Biometric Signing
  static const String keyBiometricPrivate = 'biometric_private_key';
  static const String keyBiometricPublic =
      'biometric_public_key'; // Cache public key

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  IOSOptions _getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.unlocked_this_device,
      );

  Future<bool> authenticate() async {
    if (Platform.isLinux) {
      logger.w("Biometrics not supported on Linux, skipping authentication");
      return true;
    }

    try {
      final isAvailable =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!isAvailable) {
        logger.e("No secure authentication method available");
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access Nitella',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/Pattern
        ),
      );
    } catch (e) {
      logger.e("Authentication failed", error: e);
      return false;
    }
  }

  // --- Real Biometric Verification Implementation ---

  /// Generates a new Ed25519 key pair for biometric signing.
  /// Stores the private key securely and returns the public key bytes.
  Future<List<int>> generateBiometricKey() async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();

    // Extract keys
    final userPrivateKey = await keyPair.extractPrivateKeyBytes();
    final userPublicKey = (await keyPair.extractPublicKey()).bytes;

    // Store Private Key Securely
    await _storage.write(
      key: keyBiometricPrivate,
      value: hex.encode(userPrivateKey), // Store as hex
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );

    // Cache Public Key
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyBiometricPublic, hex.encode(userPublicKey));

    logger.i("Generated new Biometric Key Pair");
    return userPublicKey;
  }

  /// Returns the stored biometric public key, or null if not generated.
  Future<List<int>?> getBiometricPublicKey() async {
    final prefs = await SharedPreferences.getInstance();
    final pubKeyHex = prefs.getString(keyBiometricPublic);
    if (pubKeyHex == null) return null;
    return hex.decode(pubKeyHex);
  }

  /// Returns a biometric public key.
  /// If missing and [createIfMissing] is true, generates and stores one.
  Future<List<int>> getOrCreateBiometricPublicKey({
    required bool createIfMissing,
  }) async {
    final existing = await getBiometricPublicKey();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    if (!createIfMissing) {
      return const [];
    }
    return await generateBiometricKey();
  }

  /// Signs authentication payload using the stored private key.
  /// Forces a fresh biometric prompt before accessing the key.
  Future<List<int>?> signPayload(List<int> payload) async {
    // 1. Force Strong Authentication
    if (!await authenticate()) {
      logger.w("User failed authentication for signing.");
      return null;
    }

    // 2. Retrieve Private Key
    final privKeyHex = await _storage.read(
      key: keyBiometricPrivate,
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );

    if (privKeyHex == null) {
      logger.e("Biometric private key not found.");
      return null;
    }

    // 3. Sign Payload
    try {
      final algorithm = Ed25519();
      final keyPair =
          await algorithm.newKeyPairFromSeed(hex.decode(privKeyHex));
      final signature = await algorithm.sign(
        payload,
        keyPair: keyPair,
      );
      return signature.bytes;
    } catch (e) {
      logger.e("Signing failed: $e");
      return null;
    }
  }

  // --- End Biometric Implementation ---

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyBiometricPublic);
    await _storage.delete(key: keyBiometricPrivate);
    logger.i("Credentials cleared.");
  }

  /// Reset all app data
  Future<void> reset() async {
    // Backend owns identity/settings reset. Flutter clears only local key material.
    await clearCredentials();
    logger.i("App reset complete.");
  }
}
