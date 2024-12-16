import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/secure_storage.dart';
import '../providers/auth_provider.dart';
import '../screens/dummy_data_progress_page.dart';
import 'home/home_screen.dart';
import 'login_page.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  static var path = '/registration';
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final SecureStorage _secureStorage = SecureStorage();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedOption = 'local';
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _addDummyData = true;

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
    bool isConfirmPassword = false,
    Key? key,
    FocusNode? focusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: key,
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText &&
            ((isPassword && !_showPassword) ||
                (isConfirmPassword && !_showConfirmPassword)),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: isPassword || isConfirmPassword
              ? IconButton(
                  icon: Icon(
                    (isPassword ? _showPassword : _showConfirmPassword)
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isPassword) {
                        _showPassword = !_showPassword;
                      } else {
                        _showConfirmPassword = !_showConfirmPassword;
                      }
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
        _buildRadioOption('API', 'api'),
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
          if (value == 'api') {
            Future.delayed(const Duration(milliseconds: 50), () {
              _urlFocusNode.requestFocus();
            });
          }
        },
      ),
    );
  }

  Widget _buildDummyDataCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Checkbox(
            value: _addDummyData,
            onChanged: (value) {
              setState(() {
                _addDummyData = value!;
              });
            },
          ),
          const Text('Add dummy data after registration'),
        ],
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      try {
        final url = _selectedOption == 'api' ? _urlController.text : null;
        final success = await ref.read(authProvider.notifier).register(
              _nameController.text,
              _emailController.text,
              _passwordController.text,
              _confirmPasswordController.text,
              endpoint: url,
            );
        if (success) {
          await _secureStorage.setPassword(_passwordController.text);
          if (mounted) {
            if (_addDummyData) {
              context.go(DummyDataProgressPage.path);
            } else {
              context.go(HomeScreen.path);
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Registration failed'),
            ));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Form(
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
                            'Get Started',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                            ),
                          ),
                          const Text(
                            'Let\'s get started by filling out the form below.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(_nameController, 'Name'),
                          _buildTextFormField(_emailController, 'Email'),
                          _buildTextFormField(
                            _passwordController,
                            'Password',
                            obscureText: true,
                            isPassword: true,
                          ),
                          _buildTextFormField(
                            _confirmPasswordController,
                            'Confirm Password',
                            obscureText: true,
                            isConfirmPassword: true,
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
                                  if (_selectedOption == 'api' &&
                                      (value == null || value.isEmpty)) {
                                    return 'Server URL is required when API option is selected';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            crossFadeState: _selectedOption == 'api'
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                          ),
                          _buildRadioOptions(),
                          _buildDummyDataCheckbox(),
                          ElevatedButton(
                            onPressed: _handleRegistration,
                            child: const Text('Sign Up'),
                          ),
                          const SizedBox(height: 16),
                          _buildLoginLink(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(LoginPage.path),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Already got an account? ',
                style: TextStyle(
                    fontSize: 14, color: Theme.of(context).primaryColor),
              ),
              TextSpan(
                text: 'Login here',
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
}
