import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/presentation/providers/debug_provider.dart';
import 'package:student_app/presentation/providers/theme_provider.dart';
import 'package:student_app/presentation/widgets/debug_overlay.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/utils/logger.dart';
import 'package:student_app/core/router/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  runApp(const ProviderScope(child: CampusEatsApp()));
}




class CampusEatsApp extends ConsumerStatefulWidget {
  const CampusEatsApp({super.key});

  @override
  ConsumerState<CampusEatsApp> createState() => _CampusEatsAppState();
}

class _CampusEatsAppState extends ConsumerState<CampusEatsApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final debugNotifier = ref.read(debugProvider);
      AppLogger.init(debugNotifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          color: isDark ? AppColors.backgroundDark : AppColors.primary,
          child: Stack(
            children: [
              if (child != null) child else const SizedBox.shrink(),
              const DebugOverlay(),
            ],
          ),
        );
      },
    );
  }
}
