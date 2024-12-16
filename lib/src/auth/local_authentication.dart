import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../screens/home/home_screen.dart';

class AuthScreen extends StatelessWidget {
  static const String path = '/';

  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthScreen({super.key});

  Future<void> _authenticate(BuildContext context) async {
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    if (authenticated) {
      if (context.mounted) {
        GoRouter.of(context).go(HomeScreen.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authenticate')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _authenticate(context),
          child: const Text('Login with Biometrics'),
        ),
      ),
    );
  }
}
