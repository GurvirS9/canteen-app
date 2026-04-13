import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:student_app/data/models/user.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _auth = supa.Supabase.instance.client.auth;

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  User _mapSession(supa.Session session, [supa.User? supaUser]) {
    final u = supaUser ?? session.user;
    final meta = u.userMetadata ?? {};
    return User(
      id: u.id, // proper UUID ✅
      name: meta['full_name'] as String? ??
            meta['name'] as String? ?? 'Student',
      email: u.email ?? '',
      role: 'user',
    );
  }

  User? checkSession() {
    final session = _auth.currentSession;
    if (session == null) return null;
    _currentUser = _mapSession(session);
    return _currentUser;
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.session == null) {
        throw Exception('Login failed. No session returned.');
      }
      _currentUser = _mapSession(response.session!, response.user);
      return _currentUser!;
    } on supa.AuthException catch (e) {
      String message;
      switch (e.statusCode) {
        case '400':
          message = 'Invalid email or password.';
          break;
        default:
          message = e.message;
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<User> signup(String name, String email, String password) async {
    try {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name.trim()},
      );
      if (response.session == null) {
        // Email confirmation required
        final u = response.user;
        if (u == null) throw Exception('Signup failed. User is null.');
        _currentUser = User(
          id: u.id,
          name: name.trim(),
          email: u.email ?? email,
          role: 'user',
        );
        AppLogger.w('AuthService', 'signup() email confirmation required');
        return _currentUser!;
      }
      _currentUser = _mapSession(response.session!, response.user);
      return _currentUser!;
    } on supa.AuthException catch (e) {
      String message;
      switch (e.statusCode) {
        case '422':
          message = 'An account already exists for that email.';
          break;
        default:
          message = e.message;
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.resetPasswordForEmail(email.trim());
    } on supa.AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      AppLogger.e('AuthService', 'Supabase logout failed: $e');
    } finally {
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userDataKey);
      await prefs.remove(AppConstants.authTokenKey);
    }
  }
}
