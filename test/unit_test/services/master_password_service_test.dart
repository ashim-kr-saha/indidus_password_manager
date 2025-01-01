import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:password/src/data/secure_storage.dart';
import 'package:password/src/services/master_password_service.dart';

@GenerateNiceMocks([MockSpec<SecureStorage>()])
import 'master_password_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MasterPasswordService masterPasswordService;
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorage();
    masterPasswordService = MasterPasswordService(mockSecureStorage);
  });

  group('MasterPasswordService', () {
    const testPassword = 'testPassword123';
    const masterPasswordKey = 'master_password';

    test('isMasterPasswordSet should return true when password exists',
        () async {
      when(mockSecureStorage.read(masterPasswordKey))
          .thenAnswer((_) async => testPassword);

      final result = await masterPasswordService.isMasterPasswordSet();
      expect(result, true);
    });

    test('isMasterPasswordSet should return false when password is empty',
        () async {
      when(mockSecureStorage.read(masterPasswordKey))
          .thenAnswer((_) async => '');

      final result = await masterPasswordService.isMasterPasswordSet();
      expect(result, false);
    });

    test('isMasterPasswordSet should return false when password is null',
        () async {
      when(mockSecureStorage.read(masterPasswordKey))
          .thenAnswer((_) async => null);

      final result = await masterPasswordService.isMasterPasswordSet();
      expect(result, false);
    });

    test('setMasterPassword should store password in secure storage', () async {
      when(mockSecureStorage.write(masterPasswordKey, testPassword))
          .thenAnswer((_) async => {});

      await masterPasswordService.setMasterPassword(testPassword);
      verify(mockSecureStorage.write(masterPasswordKey, testPassword))
          .called(1);
    });

    test('deleteMasterPassword should remove password from secure storage',
        () async {
      when(mockSecureStorage.delete(masterPasswordKey))
          .thenAnswer((_) async => {});

      await masterPasswordService.deleteMasterPassword();
      verify(mockSecureStorage.delete(masterPasswordKey)).called(1);
    });

    group('updateMasterPassword', () {
      test('should update password when old password matches', () async {
        const newPassword = 'newPassword123';
        when(mockSecureStorage.read(masterPasswordKey))
            .thenAnswer((_) async => testPassword);
        when(mockSecureStorage.write(masterPasswordKey, newPassword))
            .thenAnswer((_) async => {});

        await masterPasswordService.updateMasterPassword(
            newPassword, testPassword);
        verify(mockSecureStorage.write(masterPasswordKey, newPassword))
            .called(1);
      });

      test('should throw exception when old password does not match', () async {
        const newPassword = 'newPassword123';
        const wrongPassword = 'wrongPassword123';
        when(mockSecureStorage.read(masterPasswordKey))
            .thenAnswer((_) async => testPassword);

        expect(
          () => masterPasswordService.updateMasterPassword(
              newPassword, wrongPassword),
          throwsA(isA<Exception>()),
        );
        verifyNever(mockSecureStorage.write(masterPasswordKey, newPassword));
      });
    });

    group('verifyMasterPassword', () {
      test('should return true when password matches', () async {
        when(mockSecureStorage.read(masterPasswordKey))
            .thenAnswer((_) async => testPassword);

        final result =
            await masterPasswordService.verifyMasterPassword(testPassword);
        expect(result, true);
      });

      test('should return false when password does not match', () async {
        when(mockSecureStorage.read(masterPasswordKey))
            .thenAnswer((_) async => testPassword);

        final result =
            await masterPasswordService.verifyMasterPassword('wrongPassword');
        expect(result, false);
      });
    });
  });
}
