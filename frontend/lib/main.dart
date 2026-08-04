import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/app_config.dart';
import 'core/routing/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/services/inactivity_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/user_activity_detector.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Crash Prevention: Catch all unhandled Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[CrashGuard] Caught Flutter Framework Error: ${details.exception}');
  };

  // Global Crash Prevention: Catch all uncaught asynchronous / platform errors
  WidgetsBinding.instance.platformDispatcher.onError = (Object error, StackTrace stack) {
    debugPrint('[CrashGuard] Caught Unhandled Async Error: $error');
    return true; // Prevents app process crash
  };

  // Fallback UI builder for rendering errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red.shade50,
        child: Center(
          child: Text(
            'Something went wrong displaying this section.\nPlease refresh or try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade900, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  };

  if (!AppConfig.demoMode) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Failed to load .env variables: $e');
    }
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAvGbCgHsnqxEIT7qoFlCY3jKhXevG-dAw',
            appId: '1:810647748068:android:4968b9272929eb0237dbf1',
            messagingSenderId: '810647748068',
            projectId: 'mindsync-ai-18fbb',
            storageBucket: 'mindsync-ai-18fbb.firebasestorage.app',
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to initialize Firebase: $e');
    }
  }

  try {
    await StorageService.init();
    if (AppConfig.demoMode) {
      await StorageService.setOnboardingCompleted(true);
    }
  } catch (e) {
    debugPrint('Failed to initialize StorageService: $e');
  }

  runApp(
    const ProviderScope(
      child: MindSyncApp(),
    ),
  );
}

class MindSyncApp extends ConsumerWidget {
  const MindSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(AppRouter.routerProvider);
    final inactivityService = ref.watch(inactivityServiceProvider);
    inactivityService.scaffoldMessengerKey = scaffoldMessengerKey;

    return UserActivityDetector(
      child: MaterialApp.router(
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'MindSync AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
