class AppConstants {
  // API
  static const String baseUrl = 'https://api.example.com';
  static const String menuEndpoint = '/menu';
  static const String slotsEndpoint = '/slots';
  static const String orderEndpoint = '/order';

  // Demo mode
  static const bool demoMode = true;

  // Demo credentials
  static const String demoEmail = 'demo@canteen.com';
  static const String demoPassword = 'password123';

  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
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

  // Timing
  static const int shimmerDuration = 1500;
  static const int apiTimeout = 30;
  static const int demoDelay = 800; // ms
}
