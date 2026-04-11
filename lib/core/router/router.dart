import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/presentation/providers/auth_provider.dart';
import 'package:student_app/presentation/screens/splash/splash_screen.dart';
import 'package:student_app/presentation/screens/auth/login_screen.dart';
import 'package:student_app/presentation/screens/auth/signup_screen.dart';
import 'package:student_app/presentation/screens/auth/forgot_password_screen.dart';
import 'package:student_app/presentation/screens/main_shell.dart';
import 'package:student_app/presentation/screens/shops/shop_list_screen.dart';
import 'package:student_app/presentation/screens/home/home_screen.dart';
import 'package:student_app/presentation/screens/cart/cart_screen.dart';
import 'package:student_app/presentation/screens/queue/queue_screen.dart';
import 'package:student_app/presentation/screens/notifications/notifications_screen.dart';
import 'package:student_app/presentation/screens/profile/profile_screen.dart';
import 'package:student_app/presentation/screens/order_success/order_success_screen.dart';
import 'package:student_app/data/models/order.dart' as student_app_order;

class RouterNotifier extends ChangeNotifier {
  final Ref ref;

  RouterNotifier(this.ref) {
    ref.listen<AsyncValue<dynamic>>(
      authStateProvider,
      (prev, next) => notifyListeners(),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      
      // If authState is loading, don't redirect (let splash screen show)
      if (authState.isLoading) return null;
      
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/signup' || 
                           state.matchedLocation == '/forgot-password';
      final isSplashRoute = state.matchedLocation == '/';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && (isAuthRoute || isSplashRoute)) return '/shops';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/order-success',
        builder: (context, state) {
          final order = state.extra as student_app_order.Order;
          return OrderSuccessScreen(order: order);
        },
      ),
      // Home screen kept as a standalone push-route (accessible from shop detail)
      // but no longer part of the bottom-nav shell.
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final index = _indexFromLocation(state.matchedLocation);
          return MainShell(
            currentIndex: index,
            onTabChanged: (i) {
              context.go(_locationFromIndex(i));
            },
            child: child,
          );
        },
        routes: [
          // Tab 0 — Shops
          GoRoute(
            path: '/shops',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ShopListScreen()),
          ),
          // Tab 1 — Cart
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CartScreen(showBackButton: false)),
          ),
          // Tab 2 — Queue
          GoRoute(
            path: '/queue',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: QueueScreen()),
          ),
          // Tab 3 — Notifications / Alerts
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: NotificationsScreen()),
          ),
          // Tab 4 — Profile
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});

/// Maps a route location to a bottom-nav tab index.
/// Tabs: 0=Shops, 1=Cart, 2=Queue, 3=Notifications, 4=Profile
int _indexFromLocation(String location) {
  if (location.startsWith('/shops')) return 0;
  if (location.startsWith('/cart')) return 1;
  if (location.startsWith('/queue')) return 2;
  if (location.startsWith('/notifications')) return 3;
  if (location.startsWith('/profile')) return 4;
  return 0;
}

String _locationFromIndex(int index) {
  switch (index) {
    case 0:
      return '/shops';
    case 1:
      return '/cart';
    case 2:
      return '/queue';
    case 3:
      return '/notifications';
    case 4:
      return '/profile';
    default:
      return '/shops';
  }
}
