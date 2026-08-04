import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/onboarding_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/main_layout_page.dart';
import '../../features/mood/domain/entities/mood_log.dart';
import '../../features/mood/presentation/pages/mood_journal_page.dart';
import '../../features/mood/presentation/pages/mood_logging_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/recommendations/presentation/pages/recommendations_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/notifications/presentation/pages/notification_center_page.dart';
import '../../features/notifications/presentation/pages/notification_settings_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/privacy_settings_page.dart';
import '../../features/settings/presentation/pages/security_settings_page.dart';
import '../../features/settings/presentation/pages/data_management_page.dart';
import '../../features/settings/presentation/pages/help_support_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String moodJournal = '/mood';
  static const String aiChat = '/chat';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String logMood = '/log-mood';
  static const String recommendations = '/recommendations';
  static const String notifications = '/notifications';
  static const String notificationsSettings = '/notifications-settings';
  static const String privacySettings = '/privacy-settings';
  static const String securitySettings = '/security-settings';
  static const String dataManagement = '/data-management';
  static const String helpSupport = '/help-support';
  static const String about = '/about';

  static final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
    final AuthState authState = ref.watch(authStateProvider);

    return GoRouter(
      initialLocation: splash,
      redirect: (BuildContext context, GoRouterState state) {
        final String location = state.uri.toString();

        final bool isUnauthenticatedPage = location == login ||
            location == register ||
            location == forgotPassword ||
            location == onboarding;

        // Splash routing checks
        if (location == splash) return null;

        if (authState is AuthSuccess) {
          // If authenticated, prevent landing back to sign-in page screens
          if (isUnauthenticatedPage) return dashboard;
          return null;
        }

        // If unauthenticated and trying to hit a protected page, force login redirects
        if (authState is AuthInitial && !isUnauthenticatedPage) {
          return login;
        }

        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: splash,
          builder: (BuildContext context, GoRouterState state) => const SplashPage(),
        ),
        GoRoute(
          path: onboarding,
          builder: (BuildContext context, GoRouterState state) => const OnboardingPage(),
        ),
        GoRoute(
          path: login,
          builder: (BuildContext context, GoRouterState state) => const LoginPage(),
        ),
        GoRoute(
          path: register,
          builder: (BuildContext context, GoRouterState state) => const RegisterPage(),
        ),
        GoRoute(
          path: forgotPassword,
          builder: (BuildContext context, GoRouterState state) => const ForgotPasswordPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
            return MainLayoutPage(navigationShell: navigationShell);
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: dashboard,
                  builder: (BuildContext context, GoRouterState state) => const DashboardPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: moodJournal,
                  builder: (BuildContext context, GoRouterState state) => const MoodJournalPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: aiChat,
                  builder: (BuildContext context, GoRouterState state) => const ChatPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: reports,
                  builder: (BuildContext context, GoRouterState state) => const ReportsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: profile,
                  builder: (BuildContext context, GoRouterState state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/recommendations',
          builder: (BuildContext context, GoRouterState state) => const RecommendationsPage(),
        ),
        GoRoute(
          path: settings,
          builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
        ),
        GoRoute(
          path: logMood,
          builder: (BuildContext context, GoRouterState state) {
            final MoodLog? entryToEdit = state.extra as MoodLog?;
            return MoodLoggingPage(entryToEdit: entryToEdit);
          },
        ),
        GoRoute(
          path: notifications,
          builder: (BuildContext context, GoRouterState state) => const NotificationCenterPage(),
        ),
        GoRoute(
          path: notificationsSettings,
          builder: (BuildContext context, GoRouterState state) => const NotificationSettingsPage(),
        ),
        GoRoute(
          path: privacySettings,
          builder: (BuildContext context, GoRouterState state) => const PrivacySettingsPage(),
        ),
        GoRoute(
          path: securitySettings,
          builder: (BuildContext context, GoRouterState state) => const SecuritySettingsPage(),
        ),
        GoRoute(
          path: dataManagement,
          builder: (BuildContext context, GoRouterState state) => const DataManagementPage(),
        ),
        GoRoute(
          path: helpSupport,
          builder: (BuildContext context, GoRouterState state) => const HelpSupportPage(),
        ),
        GoRoute(
          path: about,
          builder: (BuildContext context, GoRouterState state) => const AboutPage(),
        ),
      ],
    );
  });
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Placeholder for $title',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (GoRouter.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go(AppRouter.splash);
                }
              },
              child: const Text('Back to Splash'),
            )
          ],
        ),
      ),
    );
  }
}
