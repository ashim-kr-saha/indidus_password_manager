class AuthState {
  final bool isAuthenticated;

  AuthState({
    required this.isAuthenticated,
  });
}

enum AuthType { local, server }
