import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/database.dart';
import '../models/auth_state.dart';
import '../rust/models/others/authentication.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    return AuthState(
      isAuthenticated: false,
    );
  }

  Future<bool> login(
    String email,
    String password, {
    String? endpoint,
  }) async {
    try {
      final loginData = LoginData(email: email, password: password);
      final _ = await Database.instance.login(loginData, endpoint);

      state = AuthState(
        isAuthenticated: true,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String rePassword, {
    String? endpoint,
  }) async {
    try {
      final database = Database();
      final registerData = RegisterData(
        email: email,
        password: password,
        name: name,
        rePassword: rePassword,
      );
      final _ = await database.register(registerData, endpoint);

      state = AuthState(
        isAuthenticated: true,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    state = AuthState(
      isAuthenticated: false,
    );

    Database.instance.reset();
  }
}
