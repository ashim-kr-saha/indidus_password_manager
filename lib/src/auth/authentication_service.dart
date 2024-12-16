import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _authStateController = StreamController<bool>.broadcast();
  bool _isAuthenticated = false;

  Stream<bool> authStateChanges() => _authStateController.stream;

  Future<bool> get isAuthenticated async {
    if (!_isAuthenticated) {
      _isAuthenticated = await authenticate();
    }
    return _isAuthenticated;
  }

  Future<bool> isLocalDeviceSupportsBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final hasHardware = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && hasHardware;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Error checking authentication status: $e');
      }
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          sensitiveTransaction: true,
          biometricOnly: false,
        ),
      );
      _isAuthenticated = authenticated;
      _authStateController.add(authenticated);
      return authenticated;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Error during authentication: $e');
      }
      _isAuthenticated = false;
      _authStateController.add(false);
      return false;
    }
  }

  void signOut() {
    _isAuthenticated = false;
    _authStateController.add(false);
  }

  void dispose() {
    _authStateController.close();
  }
}
