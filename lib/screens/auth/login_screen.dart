import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _fillDemo() {
    _emailController.text = AppConstants.demoEmail;
    _passwordController.text = AppConstants.demoPassword;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
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
                  // Background dots
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
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
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  // Content
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
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: const Center(
                            child: Text('🍽️', style: TextStyle(fontSize: 40)),
                          ),
                        ).animate().scale(
                            duration: 500.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 16),
                        const Text(
                          'CampusEats',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to order delicious food',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
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
                      'Welcome back 👋',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 4),
                    Text(
                      'Login to continue',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 450.ms),
                    const SizedBox(height: 28),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'demo@canteen.com',
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

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
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
                    const SizedBox(height: 12),

                    // Demo credentials hint
                    GestureDetector(
                      onTap: _fillDemo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Tap to fill demo: demo@canteen.com / password123',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 28),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _login,
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Sign In'),
                      ),
                    ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.3),
                    const SizedBox(height: 20),

                    // Divider hint
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
