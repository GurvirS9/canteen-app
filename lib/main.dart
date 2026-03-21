import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_app/presentation/providers/auth_provider.dart';
import 'package:student_app/presentation/providers/menu_provider.dart';
import 'package:student_app/presentation/providers/cart_provider.dart';
import 'package:student_app/presentation/providers/order_provider.dart';
import 'package:student_app/presentation/providers/notification_provider.dart';
import 'package:student_app/presentation/providers/theme_provider.dart';
import 'package:student_app/presentation/screens/splash_screen.dart';
import 'package:student_app/presentation/screens/auth/login_screen.dart';
import 'package:student_app/presentation/screens/main_navigation.dart';
import 'package:student_app/presentation/screens/cart/cart_screen.dart';
import 'package:student_app/presentation/screens/order_success/order_success_screen.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/theme/app_theme.dart';

void main() {
  runApp(const CampusEatsApp());
}

class CampusEatsApp extends StatelessWidget {
  const CampusEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (ctx, auth, themeProvider, _) => MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeProvider.themeMode,
          initialRoute: AppConstants.splashRoute,
          routes: {
            AppConstants.splashRoute: (_) => const SplashScreen(),
            AppConstants.loginRoute: (_) => const LoginScreen(),
            AppConstants.homeRoute: (_) => const MainNavigationScreen(),
            AppConstants.cartRoute: (_) => const CartScreen(showBackButton: true),
            AppConstants.orderSuccessRoute: (_) => const OrderSuccessScreen(),
          },
        ),
      ),
    );
  }
}
