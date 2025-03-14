import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _systemVersionKey = '0.1';

  static Future<void> setSystemVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_systemVersionKey, version);
  }

  static Future<String?> getSystemVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_systemVersionKey);
  }
}
