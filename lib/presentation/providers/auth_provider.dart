import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/data/models/user.dart';
import 'package:student_app/data/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading());

  Future<void> checkSession() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.checkSession();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(email, password);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signup(name, email, password);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authService.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }
}
