import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/presentation/providers/auth_provider.dart';
import 'package:student_app/presentation/providers/order_provider.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  Future<void> _checkSession() async {
    await ref.read(authStateProvider.notifier).checkSession();
    // After session is checked, router will automatically redirect.
    // However, if user is logged in, initialize socket.
    if (!mounted) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      ref.read(orderProvider.notifier).initSocket();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const Center(
                  child: Text('🍽️', style: TextStyle(fontSize: 52)),
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              )
                  .animate()
                  .slideY(begin: 0.5, duration: 500.ms, delay: 200.ms)
                  .fadeIn(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                'Food at your fingertips',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w400,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
