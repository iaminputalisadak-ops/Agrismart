import 'package:shared_preferences/shared_preferences.dart';

/// Local demo auth: passwords are stored on-device only (not for production).
class AuthSession {
  AuthSession._();

  static const _kFarmerPassword = 'agrismart_farmer_password';
  static const _kAuthRole = 'agrismart_auth_role';
  static const _kAuthEmail = 'agrismart_auth_email';

  static Future<void> saveFarmerPassword(String password) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kFarmerPassword, password);
  }

  static Future<String?> loadFarmerPassword() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kFarmerPassword);
  }

  static Future<void> persistLogin({required String role, required String email}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAuthRole, role);
    await p.setString(_kAuthEmail, email);
  }

  static Future<({String? role, String? email})> loadLogin() async {
    final p = await SharedPreferences.getInstance();
    return (role: p.getString(_kAuthRole), email: p.getString(_kAuthEmail));
  }

  static Future<void> clearLogin() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kAuthRole);
    await p.remove(_kAuthEmail);
  }
}
