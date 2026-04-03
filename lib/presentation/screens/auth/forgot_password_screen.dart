import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/presentation/providers/auth_provider.dart';
import 'package:student_app/core/theme/app_theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: '');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authStateProvider.notifier).sendPasswordResetEmail(
      _emailController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password reset link sent! Check your email.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      context.pop(); // Back to login
    } else {
      final errorMsg = ref.read(authStateProvider).error?.toString() ?? 'Failed to send reset link';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg.replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height * 0.38,
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.lock_reset_rounded, size: 40, color: AppColors.primary),
                          ),
                        ).animate().scale(
                            duration: 500.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 16),
                        const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 4),
                        Text(
                          'Get a link to reset your password',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forgot Password? 🤔',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your email address',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 450.ms),
                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _resetPassword(),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'student@canteen.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(v)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _resetPassword,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Send Reset Link'),
                      ),
                    ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.3),
                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: Text(
                          'Back to Login',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
