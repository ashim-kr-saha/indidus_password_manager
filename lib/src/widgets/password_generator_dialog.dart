import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  State<PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  String _generatedPassword = '';
  int _passwordLength = 12;
  bool _useUppercase = true;
  bool _useLowercase = true;
  bool _useNumbers = true;
  bool _useSpecialChars = true;
  String _specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
  final TextEditingController _specialCharsController = TextEditingController();

  static const String _allowedSpecialChars = r'!@#$%^&*()_+-=[]{}|;:,.<>?';

  String? _validateSpecialChars(String value) {
    if (!_useSpecialChars) return null;
    if (value.isEmpty) return 'Please enter at least one special character';
    if (value.split('').any((char) => !_allowedSpecialChars.contains(char))) {
      return 'Only these special characters are allowed: $_allowedSpecialChars';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadConfiguration().then((_) => _generatePassword());
  }

  @override
  void dispose() {
    _specialCharsController.dispose();
    super.dispose();
  }

  Future<void> _loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _passwordLength = prefs.getInt('passwordLength') ?? 12;
      _useUppercase = prefs.getBool('useUppercase') ?? true;
      _useLowercase = prefs.getBool('useLowercase') ?? true;
      _useNumbers = prefs.getBool('useNumbers') ?? true;
      _useSpecialChars = prefs.getBool('useSpecialChars') ?? true;
      _specialChars =
          prefs.getString('specialChars') ?? '!@#\$%^&*()_+-=[]{}|;:,.<>?';
      _specialCharsController.text = _specialChars;
    });
  }

  Future<void> _saveConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('passwordLength', _passwordLength);
    await prefs.setBool('useUppercase', _useUppercase);
    await prefs.setBool('useLowercase', _useLowercase);
    await prefs.setBool('useNumbers', _useNumbers);
    await prefs.setBool('useSpecialChars', _useSpecialChars);
    await prefs.setString('specialChars', _specialChars);
  }

  void _generatePassword() {
    const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const String numberChars = '0123456789';

    List<String> charSets = [];
    if (_useUppercase) {
      charSets.add(uppercaseChars);
    }
    if (_useLowercase) {
      charSets.add(lowercaseChars);
    }
    if (_useNumbers) {
      charSets.add(numberChars);
    }
    if (_useSpecialChars && _specialChars.isNotEmpty) {
      charSets.add(_specialChars);
    }

    if (charSets.isEmpty) {
      setState(() {
        _generatedPassword = '';
      });
      return;
    }

    final Random random = Random.secure();
    List<String> passwordChars = [];

    // Ensure at least one character from each selected category
    for (String charSet in charSets) {
      passwordChars.add(charSet[random.nextInt(charSet.length)]);
    }

    // Fill the rest of the password
    while (passwordChars.length < _passwordLength) {
      String charSet = charSets[random.nextInt(charSets.length)];
      passwordChars.add(charSet[random.nextInt(charSet.length)]);
    }

    // Shuffle the password characters
    passwordChars.shuffle(random);

    setState(() {
      _generatedPassword = passwordChars.join();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate Strong Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_generatedPassword,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Length: '),
                Expanded(
                  child: Slider(
                    value: _passwordLength.toDouble(),
                    min: 8,
                    max: 32,
                    divisions: 24,
                    label: _passwordLength.toString(),
                    onChanged: (value) {
                      setState(() {
                        _passwordLength = value.round();
                      });
                      _generatePassword();
                    },
                  ),
                ),
                Text(_passwordLength.toString()),
              ],
            ),
            CheckboxListTile(
              title: const Text('Uppercase'),
              value: _useUppercase,
              onChanged: (value) {
                setState(() {
                  _useUppercase = value!;
                });
                _generatePassword();
              },
            ),
            CheckboxListTile(
              title: const Text('Lowercase'),
              value: _useLowercase,
              onChanged: (value) {
                setState(() {
                  _useLowercase = value!;
                });
                _generatePassword();
              },
            ),
            CheckboxListTile(
              title: const Text('Numbers'),
              value: _useNumbers,
              onChanged: (value) {
                setState(() {
                  _useNumbers = value!;
                });
                _generatePassword();
              },
            ),
            CheckboxListTile(
              title: const Text('Special Characters'),
              value: _useSpecialChars,
              onChanged: (value) {
                setState(() {
                  _useSpecialChars = value!;
                  if (!_useSpecialChars) {
                    _specialCharsController.text = _specialChars;
                  }
                });
                _generatePassword();
              },
            ),
            TextField(
              controller: _specialCharsController,
              decoration: InputDecoration(
                labelText: 'Custom Special Characters',
                errorText: _validateSpecialChars(_specialCharsController.text),
                helperText: 'Allowed: $_allowedSpecialChars',
              ),
              enabled: _useSpecialChars,
              onChanged: (value) {
                setState(() {
                  _specialChars = value;
                });
                _generatePassword();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _generatePassword();
            _saveConfiguration();
          },
          child: const Text('Generate'),
        ),
        TextButton(
          child: const Text('Copy & Close'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _generatedPassword));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password copied to clipboard')),
            );
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Copy'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _generatedPassword));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password copied to clipboard')),
            );
          },
        ),
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
