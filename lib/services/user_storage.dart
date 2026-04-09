import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const _keyName = 'name';
  static const _keyPhone = 'phone';
  static const _keyAvatar = 'avatar';
  static const _keyEmail = 'email';
  static const _keyToken = 'token';

  static Future<void> saveUser({
    required String name,
    required String phone,
    required String avatar,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyAvatar, avatar);
    if (email != null) await prefs.setString(_keyEmail, email);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _keyName: prefs.getString(_keyName) ?? '',
      _keyPhone: prefs.getString(_keyPhone) ?? '',
      _keyAvatar: prefs.getString(_keyAvatar) ?? '',
      _keyEmail: prefs.getString(_keyEmail) ?? '',
    };
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
