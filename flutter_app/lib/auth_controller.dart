import 'package:flutter/foundation.dart';

import 'auth_session.dart';
import 'farmer_profile_storage.dart';

enum AuthRole { none, farmer, admin }

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// In-memory session + SharedPreferences restore (demo; replace with secure backend for production).
class AuthController extends ChangeNotifier {
  AuthController._();
  static final AuthController instance = AuthController._();

  AuthRole _role = AuthRole.none;
  String _email = '';

  AuthRole get role => _role;
  String get email => _email;

  bool get isAuthenticated => _role != AuthRole.none;
  bool get isAdmin => _role == AuthRole.admin;
  bool get isFarmer => _role == AuthRole.farmer;

  Future<void> restoreSession() async {
    final s = await AuthSession.loadLogin();
    final r = s.role;
    if (r == 'admin') {
      _role = AuthRole.admin;
      _email = s.email ?? '';
    } else if (r == 'farmer') {
      _role = AuthRole.farmer;
      _email = s.email ?? '';
    } else {
      _role = AuthRole.none;
      _email = '';
    }
    notifyListeners();
  }

  Future<void> loginAsFarmer({
    required String email,
    required String password,
  }) async {
    final profile = await FarmerProfileStorage.load();
    final savedEmail = profile.email.trim().toLowerCase();
    final entered = email.trim().toLowerCase();
    if (savedEmail.isEmpty) {
      throw AuthException(
        'No farmer profile found. Tap “Create new account” to register first.',
      );
    }
    if (savedEmail != entered) {
      throw AuthException('Email does not match your registered profile.');
    }
    final savedPassword = await AuthSession.loadFarmerPassword();
    if (savedPassword == null || savedPassword != password) {
      throw AuthException('Incorrect password. Use the password you set at registration.');
    }
    await AuthSession.persistLogin(role: 'farmer', email: profile.email.trim());
    _role = AuthRole.farmer;
    _email = profile.email.trim();
    notifyListeners();
  }

  Future<void> loginAsAdmin({
    required String email,
    required String password,
  }) async {
    final e = email.trim().toLowerCase();
    if (e == 'admin@agrismart.com' && password == 'admin123') {
      await AuthSession.persistLogin(role: 'admin', email: email.trim());
      _role = AuthRole.admin;
      _email = email.trim();
      notifyListeners();
      return;
    }
    throw AuthException('Invalid admin credentials.');
  }

  Future<void> logout() async {
    await AuthSession.clearLogin();
    _role = AuthRole.none;
    _email = '';
    notifyListeners();
  }
}
