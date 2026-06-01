import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitializing = true;
  String _errorMessage = '';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isInitializing = true;
    notifyListeners();

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        _currentUser = await _authService.getCurrentUserModel();
      }
    } catch (_) {}

    _isInitializing = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      UserModel? user = await _authService.signIn(email, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Login gagal, coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUserModel();
      notifyListeners();
    } catch (_) {}
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) return 'Email tidak ditemukan.';
    if (error.contains('wrong-password')) return 'Password salah.';
    if (error.contains('invalid-email')) return 'Format email tidak valid.';
    if (error.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    }
    if (error.contains('invalid-credential')) {
      return 'Email atau password salah.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
