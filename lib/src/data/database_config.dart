import 'package:dio/dio.dart';

import 'database_type.dart';

abstract class DatabaseConfig {
  DatabaseConfig._({
    required this.type,
  });

  factory DatabaseConfig.local() {
    return LocalDatabaseConfig();
  }

  factory DatabaseConfig.api({required Dio dio}) {
    return ApiDatabaseConfig(dio: dio);
  }

  final DatabaseType type;
}

class LocalDatabaseConfig extends DatabaseConfig {
  LocalDatabaseConfig() : super._(type: DatabaseType.local);
}

class ApiDatabaseConfig extends DatabaseConfig {
  ApiDatabaseConfig({required this.dio}) : super._(type: DatabaseType.api);
  final Dio dio;
}
