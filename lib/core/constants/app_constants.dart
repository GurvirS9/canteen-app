class AppConstants {
  // API — production backend on Railway
  static const String baseUrl = 'https://kanteen-queue-production.up.railway.app/api';

  /// Socket.IO URL — same host as API but without /api path
  static String get socketUrl {
    if (baseUrl.endsWith('/api')) {
      return baseUrl.substring(0, baseUrl.length - 4);
    }
    return baseUrl;
  }

  /// Root URL for resolving uploaded image paths like /uploads/xyz.jpg
  /// e.g. https://kanteen-queue-production.up.railway.app
  static String get imageBaseUrl => socketUrl;

  static const String menuEndpoint = '/menu';
  static String menuItemEndpoint(String id) => '/menu/$id';
  static String menuItemImageEndpoint(String id) => '/menu/$id/image';

  static const String slotsEndpoint = '/slots';
  static const String slotsCheckEndpoint = '/slots/check';
  static const String ordersEndpoint = '/orders';
  static const String activeOrdersEndpoint = '/orders/active';
  static const String ordersQueueEndpoint = '/orders/queue';
  // Use with string interpolation: '/orders/$id/status'
  static String orderStatusEndpoint(String id) => '/orders/$id/status';

  // Shops
  static const String shopsEndpoint = '/shops';
  static String shopEndpoint(String id) => '/shops/$id';
  static String shopStatusEndpoint(String id) => '/shops/$id/status';

  // Users
  static String userFcmEndpoint(String id) => '/users/$id/fcm-token';

  // Analytics
  static const String analyticsEndpoint = '/analytics';
  static const String predictionEndpoint = '/prediction';
  static const String summaryEndpoint = '/summary';



  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String homeRoute = '/home';
  static const String cartRoute = '/cart';
  static const String orderSuccessRoute = '/order-success';

  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Categories
  static const List<String> categories = [
    'All',
    'Snacks',
    'Meals',
    'Beverages',
    'Desserts',
  ];

  // App info
  static const String appName = 'CampusEats';
  static const String appVersion = '1.0.0';
  static const String canteenName = 'Main Canteen';

  // Auth
  /// Dev bypass key accepted by the backend's auth middleware.
  /// Used as fallback when Firebase token is unavailable.
  /// ⚠️ Development/testing only — do NOT ship in production without gating.
  static const String devAuthKey = 'swagger-local-dev-2024';

  // Timing
  static const int shimmerDuration = 1500;
  static const int apiTimeout = 30;
  static const int demoDelay = 800; // ms
}
