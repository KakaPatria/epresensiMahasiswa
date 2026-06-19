import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../database/database_helper.dart';
import '../services/session_service.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SessionService _sessionService = SessionService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> checkLoginStatus() async {
    bool isLoggedIn = await _sessionService.isLoggedIn();
    if (isLoggedIn) {
      int? userId = await _sessionService.getUserId();
      if (userId != null) {
        await fetchCurrentUser(userId);
      }
    }
  }

  Future<void> fetchCurrentUser(int userId) async {
    _currentUser = await _dbHelper.getUserById(userId);
    notifyListeners();
  }

  Future<bool> register(UserModel user) async {
    _setLoading(true);
    _errorMessage = '';
    
    int result = await _dbHelper.registerUser(user);
    _setLoading(false);

    if (result == -1) {
      _errorMessage = 'Email sudah terdaftar.';
      return false;
    }
    return true;
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = '';

    UserModel? user = await _dbHelper.loginUser(email, password);
    _setLoading(false);

    if (user != null) {
      _currentUser = user;
      await _sessionService.saveSession(user.id!);
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Email atau password salah.';
      return false;
    }
  }

  Future<void> logout() async {
    await _sessionService.clearSession();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    int result = await _dbHelper.updateUser(updatedUser);
    _setLoading(false);

    if (result > 0) {
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    }
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
