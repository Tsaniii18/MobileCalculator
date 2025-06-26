import 'package:hive/hive.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _boxName = 'authBox';
  static const String _usersBox = 'usersBox';
  static const String _rememberedUserKey = 'rememberedUser';

  Future<void> init() async {
    await Hive.openBox(_boxName);
    await Hive.openBox(_usersBox);
  }

  Future<bool> login(String username, String password, {bool rememberMe = false}) async {
    final box = Hive.box(_boxName);
    final usersBox = Hive.box(_usersBox);

    final savedPassword = usersBox.get(username);
    if (savedPassword != null && savedPassword == password) {
      await box.put('isLoggedIn', true);
      if (rememberMe) {
        await box.put(_rememberedUserKey, username);
      } else {
        await box.delete(_rememberedUserKey);
      }
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password) async {
    if (username.isEmpty || password.isEmpty) return false;

    final usersBox = Hive.box(_usersBox);
    if (usersBox.containsKey(username)) {
      throw Exception('Username already exists');
    }

    await usersBox.put(username, password);
    await Hive.box(_boxName).put('isLoggedIn', true);
    return true;
  }

  Future<bool> isLoggedIn() async {
    final box = Hive.box(_boxName);
    return box.get('isLoggedIn', defaultValue: false);
  }

  Future<void> logout() async {
    final box = Hive.box(_boxName);
    await box.put('isLoggedIn', false);
  }

  Future<String?> getRememberedUser() async {
    final box = Hive.box(_boxName);
    return box.get(_rememberedUserKey);
  }
} 