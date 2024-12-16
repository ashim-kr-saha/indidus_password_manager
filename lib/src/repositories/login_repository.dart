import '../data/database.dart';
import '../models/login_model.dart';
import '../rust/models/logins.dart';

class LoginRepository {
  final Database _db;

  LoginRepository(this._db);

  Future<LoginModel> getLogin(String id) async {
    return LoginModel.fromLogin(await _db.getLogin(id));
  }

  Future<List<LoginModel>> listLogins(String query) async {
    return (await _db.listLogin(query))
        .map((l) => LoginModel.fromLogin(l))
        .toList();
  }

  Future<LoginModel> addLogin(LoginModel login) async {
    final data = Login.fromLoginModel(login);
    final newLogin = await _db.postLogin(data);
    return LoginModel.fromLogin(newLogin);
  }

  Future<LoginModel> updateLogin(String id, LoginModel login) async {
    final data = Login.fromLoginModel(login);
    final updatedLogin = await _db.putLogin(id, data);
    return LoginModel.fromLogin(updatedLogin);
  }

  Future<LoginModel> deleteLogin(String id) async {
    final deletedLogin = await _db.deleteLogin(id);
    return LoginModel.fromLogin(deletedLogin);
  }
}
