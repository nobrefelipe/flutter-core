import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../widgets/pin_auth_dialog.dart';
import '../atomic_state/result.dart';
import '../cache/local_cache.dart';

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final AppCache _cache = AppCache();

  // PIN Management
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Result<bool>> setupPin(BuildContext context, String pin) async {
    final l10n = AppLocalizations.of(context);
    try {
      if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
        return Result.failure(l10n.pinMustBeFourDigits);
      }

      final hashedPin = _hashPin(pin);
      await _cache.setPinHash(hashedPin);
      return Result.success(true);
    } catch (e) {
      return Result.failure('${l10n.failedToSetupPin}: $e');
    }
  }

  Future<Result<bool>> verifyPin(BuildContext context, String pin) async {
    final l10n = AppLocalizations.of(context);
    try {
      final storedHash = _cache.getPinHash();
      if (storedHash == null) {
        return Result.failure(l10n.pinNotSetUp);
      }

      final inputHash = _hashPin(pin);
      final isValid = storedHash == inputHash;

      return Result.success(isValid);
    } catch (e) {
      return Result.failure('${l10n.failedToVerifyPin}: $e');
    }
  }

  Future<Result<bool>> changePin(BuildContext context, String oldPin, String newPin) async {
    final l10n = AppLocalizations.of(context);
    try {
      final verifyResult = await verifyPin(context, oldPin);
      if (verifyResult is Failure) {
        return Result.failure(l10n.currentPinIncorrect);
      }

      if (!(verifyResult as Success<bool>).value) {
        return Result.failure(l10n.currentPinIncorrect);
      }

      return await setupPin(context, newPin);
    } catch (e) {
      return Result.failure('${l10n.failedToChangePin}: $e');
    }
  }

  bool hasPinSetup() {
    return _cache.getPinHash() != null;
  }

  // Biometric Management
  Future<Result<bool>> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      final result = isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<bool>> authenticateWithBiometrics(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      final availabilityResult = await isBiometricAvailable();

      if (availabilityResult is Failure) {
        return Result.failure(l10n.biometricNotAvailable);
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: l10n.pleaseAuthenticateToAccess,
        persistAcrossBackgrounding: true,
      );

      return Result.success(isAuthenticated);
    } on PlatformException catch (e) {
      return Result.failure('${l10n.biometricAuthenticationFailed}: ${e.message}');
    } catch (e) {
      return Result.failure('${l10n.biometricAuthenticationError}: $e');
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _cache.setBiometricEnabled(enabled);
  }

  bool isBiometricEnabled() {
    return _cache.getBiometricEnabled();
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Security Setup Status
  Future<void> setSecuritySetupComplete(bool complete) async {
    await _cache.setSecuritySetupComplete(complete);
  }

  bool isSecuritySetupComplete() {
    return _cache.getSecuritySetupComplete();
  }

  // Authentication Flow
  Future<Result<bool>> authenticate(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      // If biometric is enabled and available, try biometric first
      if (isBiometricEnabled()) {
        final biometricResult = await authenticateWithBiometrics(context);
        if (biometricResult is Success<bool>) {
          return Success(true);
        }
      }

      // Fallback to PIN required
      return Failure(l10n.pinAuthenticationRequired);
    } catch (e) {
      return Failure('${l10n.authenticationFailed}: $e');
    }
  }

  // Clear all security data
  Future<void> clearSecurityData() async {
    await _cache.clearPinHash();
    await _cache.setBiometricEnabled(false);
    await _cache.setSecuritySetupComplete(false);
  }

  // Reusable authentication helper that handles both biometric and PIN flows
  Future<Result<bool>> authenticateUser(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    try {
      if (isBiometricEnabled()) {
        // If biometrics is enabled, only use biometrics (no PIN fallback)
        final authResult = await authenticateWithBiometrics(context);
        if (authResult is Failure) {
          return Result.failure(authResult.errorMessage);
        }
        return Result.success((authResult as Success<bool>).value);
      } else {
        // If biometrics is not enabled, show PIN authentication dialog
        final pinResult = await showPinAuthDialog(context);
        if (pinResult == null) {
          return Result.failure(l10n.authenticationError);
        }
        if (!pinResult) {
          return Result.failure(l10n.authenticationCancelled);
        }
        return Result.success(pinResult);
      }
    } catch (e) {
      return Result.failure('${l10n.authenticationFailed}: $e');
    }
  }
}
