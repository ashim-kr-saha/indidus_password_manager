import '../data/secure_storage.dart';

class MasterPasswordService {
  static const String _masterPasswordKey = 'master_password';
  final SecureStorage _secureStorage;

  MasterPasswordService([SecureStorage? secureStorage])
      : _secureStorage = secureStorage ?? SecureStorage();

  Future<bool> isMasterPasswordSet() async {
    final masterPassword = await _secureStorage.read(_masterPasswordKey);
    return masterPassword != null && masterPassword.isNotEmpty;
  }

  Future<void> setMasterPassword(String password) async {
    await _secureStorage.write(_masterPasswordKey, password);
  }

  Future<void> deleteMasterPassword() async {
    await _secureStorage.delete(_masterPasswordKey);
  }

  Future<void> updateMasterPassword(
    String newPassword,
    String oldPassword,
  ) async {
    final storedPassword = await _secureStorage.read(_masterPasswordKey);
    if (storedPassword == oldPassword) {
      await _secureStorage.write(_masterPasswordKey, newPassword);
    } else {
      throw Exception('Old password does not match');
    }
  }

  Future<bool> verifyMasterPassword(String password) async {
    final storedPassword = await _secureStorage.read(_masterPasswordKey);
    return storedPassword == password;
  }
}
