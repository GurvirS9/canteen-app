import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/presentation/providers/auth_provider.dart';
import 'package:student_app/presentation/providers/order_provider.dart';
import 'package:student_app/core/theme/app_theme.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: '');
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final authNotifier = ref.read(authStateProvider.notifier);
    final success = await authNotifier.signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      ref.read(orderProvider.notifier).initSocket();
      // Router handles redirect automatically
    } else {
      final errorMsg = ref.read(authStateProvider).error?.toString() ?? 'Signup failed';
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
            // Hero header
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
                            child: Text('👋', style: TextStyle(fontSize: 40)),
                          ),
                        ).animate().scale(
                            duration: 500.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 16),
                        const Text(
                          'Join CampusEats',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 4),
                        Text(
                          'Create an account to start ordering',
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

            // Form
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account ✨',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 4),
                    Text(
                      'Sign up to continue',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 450.ms),
                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'John Doe',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 480.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _signup(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _signup,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Sign Up'),
                      ),
                    ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.3),
                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Change to go
                          context.go('/login');
                        },
                        child: Text(
                          'Already have an account? Login',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 680.ms),
                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        'Protected by CampusEats Security 🔒',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12),
                      ),
                    ).animate().fadeIn(delay: 700.ms),
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
