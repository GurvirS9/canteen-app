import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/app_constants.dart';
import '../utils/mock_data.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<User?> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.userDataKey);
    if (userData != null) {
      _currentUser = User.fromJson(json.decode(userData));
      return _currentUser;
    }
    return null;
  }

  Future<User> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (email.trim().toLowerCase() == AppConstants.demoEmail &&
        password == AppConstants.demoPassword) {
      _currentUser = MockData.mockUser;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          AppConstants.userDataKey, json.encode(_currentUser!.toJson()));
      return _currentUser!;
    }
    throw Exception('Invalid email or password. Use demo@canteen.com / password123');
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userDataKey);
    await prefs.remove(AppConstants.authTokenKey);
  }

  bool get isLoggedIn => _currentUser != null;
}
