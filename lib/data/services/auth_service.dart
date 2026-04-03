import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:student_app/data/models/user.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/utils/logger.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;

  Future<User?> checkSession() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        _currentUser = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Student',
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber ?? '',
          rollNumber: '',
          avatarUrl: firebaseUser.photoURL ?? '',
        );
        return _currentUser;
      }
    } catch (e) {
      AppLogger.e('AuthService', 'Firebase Auth session check failed: $e');
    }
    return null;
  }

  Future<User> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) throw Exception('Login failed. User is null.');

      _currentUser = User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Student',
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        rollNumber: '',
        avatarUrl: firebaseUser.photoURL ?? '',
      );

      final token = await firebaseUser.getIdToken();
      final prefs = await SharedPreferences.getInstance();
      if (token != null) {
        await prefs.setString(AppConstants.authTokenKey, token);
      }

      return _currentUser!;
    } on firebase.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided for that user.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = e.message ?? 'Authentication failed.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<User> signup(String name, String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) throw Exception('Signup failed. User is null.');

      await firebaseUser.updateDisplayName(name.trim());

      _currentUser = User(
        id: firebaseUser.uid,
        name: name.trim(),
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        rollNumber: '',
        avatarUrl: firebaseUser.photoURL ?? '',
      );

      final token = await firebaseUser.getIdToken();
      final prefs = await SharedPreferences.getInstance();
      if (token != null) {
        await prefs.setString(AppConstants.authTokenKey, token);
      }

      return _currentUser!;
    } on firebase.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists for that email.';
          break;
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = e.message ?? 'Registration failed.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on firebase.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = e.message ?? 'Failed to send password reset email.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      AppLogger.e('AuthService', 'Firebase logout failed: $e');
    } finally {
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userDataKey);
      await prefs.remove(AppConstants.authTokenKey);
    }
  }

  bool get isLoggedIn => _currentUser != null;
}
