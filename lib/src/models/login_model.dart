import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../rust/models/logins.dart';

part 'login_model.freezed.dart';
part 'login_model.g.dart';

@freezed
class LoginModel with _$LoginModel {
  const factory LoginModel({
    String? id,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    required String name,
    String? note,
    required String username,
    String? url,
    String? password,
    String? passwordHint,
    required bool isFavorite,
    List<String>? tags,
    List<APIKey>? apiKeys,
  }) = _LoginModel;

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  factory LoginModel.fromLogin(Login login) {
    List<APIKey> apiKeys = [];
    if (login.apiKeys != null) {
      final List<dynamic> apiKeysJson = jsonDecode(login.apiKeys!);
      apiKeys = apiKeysJson.map((e) => APIKey.fromJson(e)).toList();
    }

    return LoginModel(
      id: login.id,
      createdAt: login.createdAt,
      createdBy: login.createdBy,
      updatedAt: login.updatedAt,
      updatedBy: login.updatedBy,
      name: login.name,
      note: login.note,
      username: login.username,
      url: login.url ?? '',
      password: login.password ?? '',
      passwordHint: login.passwordHint ?? '',
      isFavorite: login.isFavorite ?? false,
      tags: login.tags?.split(',') ?? [],
      apiKeys: apiKeys,
    );
  }
}

@freezed
class APIKey with _$APIKey {
  const factory APIKey({
    required String name,
    required String value,
  }) = _APIKey;

  factory APIKey.fromJson(Map<String, dynamic> json) => _$APIKeyFromJson(json);
}
