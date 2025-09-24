import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() { _checkAuth(); }

  Future<void> _checkAuth() async {
    final token = await SecureStorage.getToken();
    _isAuthenticated = token != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final user = await AuthService.login(email, password);
    if (user != null) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await AuthService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}
