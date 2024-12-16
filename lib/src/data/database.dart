import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../rust/api/simple.dart' as api;
import '../rust/models/financial_cards.dart';
import '../rust/models/identity_cards.dart';
import '../rust/models/logins.dart';
import '../rust/models/notes.dart';
import '../rust/models/others/authentication.dart';
import '../rust/models/tags.dart';
import 'database_config.dart';
import 'database_type.dart';
import 'dummy_data.dart';
import 'secure_storage.dart';

/// By default, the database is local.
/// To use the API, call [toAPI] method.
/// To switch back to local, call [_toLocal] method.
/// Before using the database, you must call [initDb] method.
class Database {
  String refreshToken = "";
  String accessToken = "";
  DatabaseConfig _config = DatabaseConfig.local();
  Database._();

  static final Database _instance = Database._();

  factory Database() {
    return _instance;
  }

  static Database get instance {
    return _instance;
  }

  Database reset() {
    _instance.refreshToken = "";
    _instance.accessToken = "";
    _instance._config = DatabaseConfig.local();
    return _instance;
  }

  bool get isAuthenticated {
    return refreshToken.isNotEmpty && accessToken.isNotEmpty;
  }

  Database _setToken(String refreshToken, String accessToken) {
    _instance.refreshToken = refreshToken;
    _instance.accessToken = accessToken;
    return _instance;
  }

  Database _toAPI(Dio dio) {
    _instance._config = DatabaseConfig.api(dio: dio);
    return _instance;
  }

  Database _toLocal() {
    _instance._config = DatabaseConfig.local();
    return _instance;
  }

  Future<Database> initDb() async {
    var isInitialized = await api.isDatabaseInitialized();
    if (_config.type == DatabaseType.local && !isInitialized) {
      final dbPath = await _getDatabasePath();
      if (kDebugMode) {
        print("Database path: $dbPath");
      }
      var (success, message) = await api.init(dbPath: dbPath);
      if (!success) {
        throw Exception("Failed to initialize database: $message");
      }
    }
    return _instance;
  }

  Future<String> _getDatabasePath() async {
    Directory appDocDir;
    if (Platform.isAndroid || Platform.isIOS) {
      appDocDir = await getApplicationDocumentsDirectory();
    } else if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      appDocDir = await getApplicationSupportDirectory();
    } else {
      throw UnsupportedError("Unsupported platform");
    }

    String dbPath = join(appDocDir.path, 'password.db');
    return dbPath;
  }

  Dio get dio => (_config as ApiDatabaseConfig).dio;

  Future<JwtTokens> register(RegisterData user, String? endpoint) async {
    if (endpoint == null) {
      await instance._toLocal().initDb();
      final tokens = await api.register(user: user);
      _setToken(tokens.refreshToken, tokens.accessToken);
      return tokens;
    } else {
      final dio = Dio(BaseOptions(baseUrl: endpoint));
      final db = _toAPI(dio);
      await db.initDb();
      Response response = await dio.post('/auth/register', data: user.toJson());
      final tokens = JwtTokens.fromJson(response.data);
      _setToken(tokens.refreshToken, tokens.accessToken);
      return tokens;
    }
  }

  Future<JwtTokens> login(LoginData login, String? endpoint) async {
    if (endpoint == null) {
      await instance._toLocal().initDb();
      final tokens = await api.login(user: login);
      _setToken(tokens.refreshToken, tokens.accessToken);
      return tokens;
    } else {
      final dio = Dio(BaseOptions(baseUrl: endpoint));
      final db = _toAPI(dio);
      await db.initDb();
      Response response = await dio.post('/auth/login', data: login.toJson());
      final tokens = JwtTokens.fromJson(response.data);
      _setToken(tokens.refreshToken, tokens.accessToken);
      return tokens;
    }
  }

  Future<Login> getLogin(String id) async {
    if (_config.type == DatabaseType.local) {
      return await api.getLogin(id: id, token: accessToken);
    } else {
      Response response = await dio.get('/logins/$id');
      return Login.fromJson(response.data);
    }
  }

  Future<Login> encryptLogin(Login data) async {
    String password = await SecureStorage().getPassword();
    var passwordData =
        await api.encryptData(data: data.password ?? '', password: password);
    data = data.copyWith(password: passwordData);
    var passwordHintData = await api.encryptData(
        data: data.passwordHint ?? '', password: password);
    data = data.copyWith(passwordHint: passwordHintData);
    // var apiKeysData =
    //     await api.encryptData(data: data.apiKeys ?? '', password: password);
    // data = data.copyWith(apiKeys: apiKeysData);
    return data;
  }

  Future<Login> postLogin(Login data) async {
    data = await encryptLogin(data);

    if (_config.type == DatabaseType.local) {
      return await api.postLogin(data: data, token: accessToken);
    } else {
      Response response = await dio.post('/logins', data: data.toJson());
      return Login.fromJson(response.data);
    }
  }

  Future<Login> putLogin(String id, Login data) async {
    data = await encryptLogin(data);

    if (_config.type == DatabaseType.local) {
      return await api.putLogin(id: id, data: data, token: accessToken);
    } else {
      Response response = await dio.put('/logins/$id', data: data.toJson());
      return Login.fromJson(response.data);
    }
  }

  Future<Login> deleteLogin(String id) async {
    if (_config.type == DatabaseType.local) {
      return await api.deleteLogin(id: id, token: accessToken);
    } else {
      Response response = await dio.delete('/logins/$id');
      return Login.fromJson(response.data);
    }
  }

  Future<List<Login>> listLogin(String query) async {
    if (_config.type == DatabaseType.local) {
      return await api.listLogin(query: query, token: accessToken);
    } else {
      Response response = await dio.get('/logins?query=$query');
      return (response.data as List).map((e) => Login.fromJson(e)).toList();
    }
  }

  Future<Note> getNote(String id) async {
    if (_config.type == DatabaseType.local) {
      return await api.getNote(id: id, token: accessToken);
    } else {
      Response response = await dio.get('/notes/$id');
      return Note.fromJson(response.data);
    }
  }

  Future<Note> postNote(Note data) async {
    data = await encryptNote(data);

    if (_config.type == DatabaseType.local) {
      return await api.postNote(data: data, token: accessToken);
    } else {
      Response response = await dio.post('/notes', data: data.toJson());
      return Note.fromJson(response.data);
    }
  }

  Future<Note> putNote(String id, Note data) async {
    data = await encryptNote(data);

    if (_config.type == DatabaseType.local) {
      return await api.putNote(id: id, data: data, token: accessToken);
    } else {
      Response response = await dio.put('/notes/$id', data: data.toJson());
      return Note.fromJson(response.data);
    }
  }

  Future<Note> deleteNote(String id) async {
    if (_config.type == DatabaseType.local) {
      return await api.deleteNote(id: id, token: accessToken);
    } else {
      Response response = await dio.delete('/notes/$id');
      return Note.fromJson(response.data);
    }
  }

  Future<List<Note>> listNote(String query) async {
    if (_config.type == DatabaseType.local) {
      return await api.listNote(query: query, token: accessToken);
    } else {
      Response response = await dio.get('/notes?query=$query');
      return (response.data as List).map((e) => Note.fromJson(e)).toList();
    }
  }

  Future<IdentityCard> getIdentityCard(String id) async {
    if (_config.type == DatabaseType.local) {
      return await api.getIdentityCard(id: id, token: accessToken);
    } else {
      Response response = await dio.get('/identity_cards/$id');
      return IdentityCard.fromJson(response.data);
    }
  }

  Future<IdentityCard> encryptIdentityCard(IdentityCard data) async {
    String password = await SecureStorage().getPassword();
    // Encrypt sensitive fields
    var identityCardNumber = await api.encryptData(
      data: data.identityCardNumber,
      password: password,
    );
    return data.copyWith(
      identityCardNumber: identityCardNumber,
    );
  }

  Future<IdentityCard> postIdentityCard(IdentityCard data) async {
    data = await encryptIdentityCard(data);

    if (_config.type == DatabaseType.local) {
      return await api.postIdentityCard(data: data, token: accessToken);
    } else {
      Response response =
          await dio.post('/identity_cards', data: data.toJson());
      return IdentityCard.fromJson(response.data);
    }
  }

  Future<IdentityCard> putIdentityCard(String id, IdentityCard data) async {
    data = await encryptIdentityCard(data);

    if (_config.type == DatabaseType.local) {
      return await api.putIdentityCard(id: id, data: data, token: accessToken);
    } else {
      Response response =
          await dio.put('/identity_cards/$id', data: data.toJson());
      return IdentityCard.fromJson(response.data);
    }
  }

  Future<IdentityCard> deleteIdentityCard(String id) async {
    if (_config.type == DatabaseType.local) {
      return await api.deleteIdentityCard(id: id, token: accessToken);
    } else {
      Response response = await dio.delete('/identity_cards/$id');
      return IdentityCard.fromJson(response.data);
    }
  }

  Future<List<IdentityCard>> listIdentityCard(String query) async {
    if (_config.type == DatabaseType.local) {
      return await api.listIdentityCard(query: query, token: accessToken);
    } else {
      Response response = await dio.get('/identity_cards?query=$query');
      return (response.data as List)
          .map((e) => IdentityCard.fromJson(e))
          .toList();
    }
  }

  Future<FinancialCard> getFinancialCard(String id) async {
    if (_config.type == DatabaseType.local) {
      return await api.getFinancialCard(id: id, token: accessToken);
    } else {
      Response response = await dio.get('/financial_cards/$id');
      return FinancialCard.fromJson(response.data);
    }
  }

  Future<FinancialCard> encryptFinancialCard(FinancialCard data) async {
    String password = await SecureStorage().getPassword();
    // Encrypt sensitive fields
    var cardNumber = await api.encryptData(
      data: data.cardNumber,
      password: password,
    );
    var cvv = await api.encryptData(
      data: data.cvv ?? '',
      password: password,
    );
    var pin = await api.encryptData(
      data: data.pin ?? '',
      password: password,
    );
    return data.copyWith(
      cardNumber: cardNumber,
      cvv: cvv,
      pin: pin,
    );
  }

  Future<FinancialCard> postFinancialCard(FinancialCard data) async {
    data = await encryptFinancialCard(data);

    if (_config.type == DatabaseType.local) {
      return await api.postFinancialCard(data: data, token: accessToken);
    } else {
      Response response =
          await dio.post('/financial_cards', data: data.toJson());
      return FinancialCard.fromJson(response.data);
    }
  }

  Future<FinancialCard> putFinancialCard(String id, FinancialCard data) async {
    data = await encryptFinancialCard(data);

    if (_config.type == DatabaseType.local) {
      return await api.putFinancialCard(id: id, data: data, token: accessToken);
    } else {
      Response response =
          await dio.put('/financial_cards/$id', data: data.toJson());
      return FinancialCard.fromJson(response.data);
    }
  }

  Future<FinancialCard> deleteFinancialCard(String id) async {
    if (_config.type == DatabaseType.local) {
      return await api.deleteFinancialCard(id: id, token: accessToken);
    } else {
      Response response = await dio.delete('/financial_cards/$id');
      return FinancialCard.fromJson(response.data);
    }
  }

  Future<List<FinancialCard>> listFinancialCard(String query) async {
    if (_config.type == DatabaseType.local) {
      return await api.listFinancialCard(query: query, token: accessToken);
    } else {
      Response response = await dio.get('/financial_cards?query=$query');
      return (response.data as List)
          .map((e) => FinancialCard.fromJson(e))
          .toList();
    }
  }

  Future<Tag> getTag(String id) async {
    if (_config.type == DatabaseType.local) {
      return await api.getTag(id: id, token: accessToken);
    } else {
      Response response = await dio.get('/tags/$id');
      return Tag.fromJson(response.data);
    }
  }

  Future<Tag> postTag(Tag tag) async {
    if (_config.type == DatabaseType.local) {
      return await api.createTag(tag: tag, token: accessToken);
    } else {
      Response response = await dio.post('/tags', data: tag.toJson());
      return Tag.fromJson(response.data);
    }
  }

  Future<Tag> putTag(String id, Tag tag) async {
    if (_config.type == DatabaseType.local) {
      return await api.putTag(id: id, tag: tag, token: accessToken);
    } else {
      Response response = await dio.put('/tags/$id', data: tag.toJson());
      return Tag.fromJson(response.data);
    }
  }

  Future<Tag> deleteTag(String id) async {
    if (_config.type == DatabaseType.local) {
      return await api.deleteTag(id: id, token: accessToken);
    } else {
      Response response = await dio.delete('/tags/$id');
      return Tag.fromJson(response.data);
    }
  }

  Future<List<Tag>> listTags(String query) async {
    if (_config.type == DatabaseType.local) {
      return await api.listTags(query: query, token: accessToken);
    } else {
      Response response = await dio.get('/tags');
      return (response.data as List).map((e) => Tag.fromJson(e)).toList();
    }
  }

  Future<Note> encryptNote(Note data) async {
    String password = await SecureStorage().getPassword();
    // Encrypt content
    var note = await api.encryptData(data: data.note ?? '', password: password);
    return data.copyWith(note: note);
  }

  Stream<double> createDummyData() async* {
    // Simulate creating dummy data
    var total = 26;
    final Tag personalTag = await postTag(Tag(name: 'Personal'));
    yield 1 / total;
    final Tag workTag = await postTag(Tag(name: 'Work'));
    yield 2 / total;
    final Tag travelTag = await postTag(Tag(name: 'Travel'));
    yield 3 / total;
    final Tag bankingTag = await postTag(Tag(name: 'Banking'));
    yield 4 / total;
    final Tag socialTag = await postTag(Tag(name: 'Social'));
    yield 5 / total;
    final Tag shoppingTag = await postTag(Tag(name: 'Shopping'));
    yield 6 / total;
    final Tag entertainmentTag = await postTag(Tag(name: 'Entertainment'));
    yield 7 / total;
    final Tag _ = await postTag(Tag(name: 'Other'));
    yield 8 / total;

    final List<IdentityCard> identityCards = DummyData.identityCards(
      personalTag: personalTag,
      workTag: workTag,
    );
    for (int i = 0; i < identityCards.length; i++) {
      await postIdentityCard(identityCards[i]);
      yield (9 + i) / total;
    }

    final List<FinancialCard> financialCards = DummyData.financialCards(
      bankingTag: bankingTag,
      personalTag: personalTag,
      workTag: workTag,
    );
    for (int i = 0; i < financialCards.length; i++) {
      await postFinancialCard(financialCards[i]);
      yield (12 + i) / total;
    }
    final List<Note> notes = DummyData.notes(
      personalTag: personalTag,
      workTag: workTag,
    );
    for (int i = 0; i < notes.length; i++) {
      await postNote(notes[i]);
      yield (14 + i) / total;
    }
    final List<Login> logins = DummyData.logins(
      travelTag: travelTag,
      socialTag: socialTag,
      shoppingTag: shoppingTag,
      entertainmentTag: entertainmentTag,
      personalTag: personalTag,
      workTag: workTag,
    );
    for (int i = 0; i < logins.length; i++) {
      await postLogin(logins[i]);
      yield (16 + i) / total;
    }
  }
}
