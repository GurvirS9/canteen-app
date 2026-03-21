import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/order_success/order_success_screen.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

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
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: ThemeMode.system,
          initialRoute: AppConstants.splashRoute,
          routes: {
            AppConstants.splashRoute: (_) => const SplashScreen(),
            AppConstants.loginRoute: (_) => const LoginScreen(),
            AppConstants.homeRoute: (_) => const MainNavigationScreen(),
            AppConstants.orderSuccessRoute: (_) => const OrderSuccessScreen(),
          },
        ),
      ),
    );
  }
}
