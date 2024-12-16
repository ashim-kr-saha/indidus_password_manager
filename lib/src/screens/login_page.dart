import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/secure_storage.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';
import 'home/home_screen.dart';
import 'registration_page.dart';

Dio prepareDio(String url, String token) {
  final dio = Dio();
  dio.options.baseUrl = url;
  dio.options.connectTimeout = const Duration(seconds: 5);
  dio.options.receiveTimeout = const Duration(seconds: 3);
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  return dio;
}

class LoginPage extends ConsumerStatefulWidget {
  static var path = '/';

  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedOption = 'local';
  bool _showPassword = false;
  final SecureStorage _secureStorage = SecureStorage();
  final _urlFieldKey = GlobalKey<FormFieldState>();
  final _urlFocusNode = FocusNode();

  @override
  void dispose() {
    _urlFocusNode.dispose();
    super.dispose();
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    String? Function(String?)? validator,
    bool isPassword = false,
    Key? key,
    FocusNode? focusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: key,
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText && isPassword && !_showPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                )
              : null,
        ),
        validator: validator ?? _defaultValidator,
      ),
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Widget _buildRadioOptions() {
    return Row(
      children: [
        _buildRadioOption('Local', 'local'),
        _buildRadioOption('Server', 'server'),
      ],
    );
  }

  Widget _buildRadioOption(String title, String value) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(title),
        value: value,
        groupValue: _selectedOption,
        onChanged: (value) {
          setState(() => _selectedOption = value!);
          if (value == 'server') {
            // Add a short delay to allow the animation to start
            Future.delayed(const Duration(milliseconds: 50), () {
              _urlFocusNode.requestFocus();
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.4),
                theme.colorScheme.primary.withOpacity(0.1),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: authState.isAuthenticated
                        ? _buildAuthenticatedView(authState)
                        : _buildLoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(AuthState authState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('You are logged in!'),
        ElevatedButton(
          onPressed: () => ref.read(authProvider.notifier).logout(),
          child: const Text('Logout'),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Indidus Password Manager',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w300,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome Back',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          const Text(
            'Please log in to your account.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(_emailController, 'Email'),
          _buildTextFormField(
            _passwordController,
            'Password',
            obscureText: true,
            isPassword: true,
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _buildTextFormField(
                _urlController,
                'Server URL',
                key: _urlFieldKey,
                focusNode: _urlFocusNode,
                validator: (value) {
                  if (_selectedOption == 'server' &&
                      (value == null || value.isEmpty)) {
                    return 'Server URL is required when server option is selected';
                  }
                  return null;
                },
              ),
            ),
            crossFadeState: _selectedOption == 'server'
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          _buildRadioOptions(),
          ElevatedButton(
            onPressed: _handleLogin,
            child: const Text('Login'),
          ),
          const SizedBox(height: 16),
          _buildRegisterLink(context),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
            endpoint: _selectedOption == 'server' ? _urlController.text : null,
          );
      if (success) {
        await _secureStorage.setPassword(_passwordController.text);
        if (mounted) {
          GoRouter.of(context).go(HomeScreen.path);
        }
      }
    }
  }

  Widget _buildRegisterLink(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => GoRouter.of(context).go(RegistrationPage.path),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Don\'t have an account? ',
                style: TextStyle(
                    fontSize: 14, color: Theme.of(context).primaryColor),
              ),
              TextSpan(
                text: 'Register here',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _checkMasterPassword() async {
  //   final masterPasswordService = MasterPasswordService();
  //   final isMasterPasswordSet =
  //       await masterPasswordService.isMasterPasswordSet();

  //   if (!isMasterPasswordSet) {
  //     if (mounted) {
  //       GoRouter.of(context).go(MasterPasswordSetupScreen.path);
  //     }
  //   } else {
  //     if (mounted) {
  //       GoRouter.of(context).go(HomeScreen.path);
  //     }
  //   }
  // }
}
