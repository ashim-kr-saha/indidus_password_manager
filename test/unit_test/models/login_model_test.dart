import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:password/src/models/login_model.dart';
import 'package:password/src/rust/models/logins.dart';

void main() {
  group('LoginModel', () {
    test('should create LoginModel from json', () {
      final json = {
        'id': '1',
        'createdAt': 1234567890,
        'createdBy': 'user1',
        'updatedAt': 1234567891,
        'updatedBy': 'user1',
        'name': 'Test Login',
        'note': 'Test note',
        'username': 'testuser',
        'url': 'https://test.com',
        'password': 'password123',
        'passwordHint': 'hint',
        'isFavorite': true,
        'tags': ['tag1', 'tag2'],
        'apiKeys': [
          {'name': 'API Key 1', 'value': 'key1'},
          {'name': 'API Key 2', 'value': 'key2'}
        ]
      };

      final loginModel = LoginModel.fromJson(json);

      expect(loginModel.id, '1');
      expect(loginModel.createdAt, 1234567890);
      expect(loginModel.createdBy, 'user1');
      expect(loginModel.updatedAt, 1234567891);
      expect(loginModel.updatedBy, 'user1');
      expect(loginModel.name, 'Test Login');
      expect(loginModel.note, 'Test note');
      expect(loginModel.username, 'testuser');
      expect(loginModel.url, 'https://test.com');
      expect(loginModel.password, 'password123');
      expect(loginModel.passwordHint, 'hint');
      expect(loginModel.isFavorite, true);
      expect(loginModel.tags, ['tag1', 'tag2']);
      expect(loginModel.apiKeys?.length, 2);
      expect(loginModel.apiKeys?[0].name, 'API Key 1');
      expect(loginModel.apiKeys?[0].value, 'key1');
    });

    test('should create LoginModel from Login', () {
      final login = Login(
          id: '1',
          createdAt: 1234567890,
          createdBy: 'user1',
          updatedAt: 1234567891,
          updatedBy: 'user1',
          name: 'Test Login',
          note: 'Test note',
          username: 'testuser',
          url: 'https://test.com',
          password: 'password123',
          passwordHint: 'hint',
          isFavorite: true,
          tags: 'tag1,tag2',
          apiKeys: jsonEncode([
            {'name': 'API Key 1', 'value': 'key1'},
            {'name': 'API Key 2', 'value': 'key2'}
          ]));

      final loginModel = LoginModel.fromLogin(login);

      expect(loginModel.id, '1');
      expect(loginModel.createdAt, 1234567890);
      expect(loginModel.createdBy, 'user1');
      expect(loginModel.updatedAt, 1234567891);
      expect(loginModel.updatedBy, 'user1');
      expect(loginModel.name, 'Test Login');
      expect(loginModel.note, 'Test note');
      expect(loginModel.username, 'testuser');
      expect(loginModel.url, 'https://test.com');
      expect(loginModel.password, 'password123');
      expect(loginModel.passwordHint, 'hint');
      expect(loginModel.isFavorite, true);
      expect(loginModel.tags, ['tag1', 'tag2']);
      expect(loginModel.apiKeys?.length, 2);
      expect(loginModel.apiKeys?[0].name, 'API Key 1');
      expect(loginModel.apiKeys?[0].value, 'key1');
    });

    test('should handle null values correctly', () {
      final login = Login(
        name: 'Test Login',
        username: 'testuser',
      );

      final loginModel = LoginModel.fromLogin(login);

      expect(loginModel.id, null);
      expect(loginModel.createdAt, null);
      expect(loginModel.createdBy, null);
      expect(loginModel.updatedAt, null);
      expect(loginModel.updatedBy, null);
      expect(loginModel.url, '');
      expect(loginModel.password, '');
      expect(loginModel.passwordHint, '');
      expect(loginModel.isFavorite, false);
      expect(loginModel.tags, []);
      expect(loginModel.apiKeys, []);
    });
  });

  group('APIKey', () {
    test('should create APIKey from json', () {
      final json = {'name': 'Test API Key', 'value': 'test-value'};

      final apiKey = APIKey.fromJson(json);

      expect(apiKey.name, 'Test API Key');
      expect(apiKey.value, 'test-value');
    });
  });
}
