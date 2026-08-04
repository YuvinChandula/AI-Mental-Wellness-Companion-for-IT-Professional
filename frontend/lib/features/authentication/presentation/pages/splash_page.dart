import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/storage_service.dart';
import '../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Artificial delay to show branding animation/logo
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (AppConfig.demoMode) {
      context.go(AppRouter.dashboard);
      return;
    }

    // Check if onboarding is completed
    final bool onboardingCompleted = StorageService.getOnboardingCompleted();
    if (!onboardingCompleted) {
      context.go(AppRouter.onboarding);
      return;
    }

    // Read authentication state to select routing destination
    final AuthState authState = ref.read(authStateProvider);
    _routeBasedOnState(authState);
  }

  void _routeBasedOnState(AuthState state) {
    if (state is AuthSuccess) {
      context.go(AppRouter.dashboard);
    } else if (state is AuthVerificationPending) {
      // Prompt user to verify email
      context.go(AppRouter.login);
    } else {
      context.go(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Icon(
                    Icons.psychology,
                    size: 100,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'MindSync AI',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Mental Wellness Companion',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            )
          ],
        ),
      ),
    );
  }
}
