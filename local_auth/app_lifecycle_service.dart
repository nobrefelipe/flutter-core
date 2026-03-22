import 'package:flutter/material.dart';
import 'package:grade_coin/router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../main.dart';
import '../atomic_state/result.dart';
import 'biometric_auth_service.dart';

class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isLocked = false;
  bool _isAuthenticating = false;
  DateTime? _backgroundTime;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _onAppPaused() {
    _backgroundTime = DateTime.now();
    debugPrint('App paused at: $_backgroundTime');

    // Lock immediately when app goes to background
    if (_biometricService.isSecuritySetupComplete()) {
      _lockApp();
    }
  }

  void _onAppResumed() {
    debugPrint('App resumed');
    _backgroundTime = null;
  }

  void _lockApp() {
    if (_isLocked || _isAuthenticating) return;

    _isLocked = true;
    debugPrint('App locked - requiring authentication');

    // Navigate to authentication overlay
    _showAuthenticationOverlay();
  }

  void _showAuthenticationOverlay() {
    if (_isAuthenticating) return;

    // Navigate to a full-screen authentication page
    router.go('/auth/app-lock');
  }

  Future<Result<bool>> authenticateForUnlock(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (_isAuthenticating) {
      return Result.failure(l10n.authenticationInProgress);
    }

    _isAuthenticating = true;

    try {
      // Try biometric authentication first if enabled
      if (_biometricService.isBiometricEnabled()) {
        final biometricResult = await _biometricService.authenticateWithBiometrics(context);
        if (biometricResult is Success<bool> && biometricResult.value) {
          _unlockApp();
          return Result.success(true);
        }
      }

      // If biometric fails or not enabled, require PIN
      return Result.failure(l10n.pinAuthenticationRequired);
    } catch (e) {
      return Result.failure('${l10n.authenticationFailed}: $e');
    } finally {
      _isAuthenticating = false;
    }
  }

  Future<Result<bool>> authenticateWithPin(BuildContext context, String pin) async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await _biometricService.verifyPin(context, pin);
      if (result is Success<bool> && result.value) {
        _unlockApp();
        return Result.success(true);
      }
      return Result.failure(l10n.invalidPin);
    } catch (e) {
      return Result.failure('${l10n.pinVerificationFailed}: $e');
    }
  }

  void _unlockApp() {
    _isLocked = false;
    _isAuthenticating = false;
    debugPrint('App unlocked');

    // Navigate back to main app
    router.go('/home');
  }

  bool get isLocked => _isLocked;
  bool get isAuthenticating => _isAuthenticating;
}
