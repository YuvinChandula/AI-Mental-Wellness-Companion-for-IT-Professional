import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class WelcomeHeader extends ConsumerWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final profileState = ref.watch(profileStateProvider);
    final int unreadCount = ref.watch(unreadNotificationsCountProvider);

    String fullName = authState is AuthSuccess ? authState.user.fullName : 'Guest Professional';
    profileState.whenData((profile) {
      if (profile.fullName.isNotEmpty) {
        fullName = profile.fullName;
      }
    });
    final String firstName = fullName.trim().split(' ').first;

    // Time-based greeting
    final hour = DateTime.now().hour;
    final String greeting;
    final IconData greetingIcon;
    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny_outlined;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_cloudy_outlined;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nights_stay_outlined;
    }

    final String dateString = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // User Avatar
              Semantics(
                label: 'View Profile',
                button: true,
                child: GestureDetector(
                  onTap: () => context.go(AppRouter.profile),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: context.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Greeting and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          greetingIcon,
                          size: 16,
                          color: context.colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          greeting,
                          style: context.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      firstName,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Quick Actions: Notifications & Settings
              Semantics(
                label: 'Notifications',
                button: true,
                child: IconButton(
                  icon: unreadCount > 0
                      ? Badge(
                          label: Text(unreadCount.toString()),
                          child: const Icon(Icons.notifications_outlined),
                        )
                      : const Icon(Icons.notifications_none_outlined),
                  onPressed: () {
                    context.push(AppRouter.notifications);
                  },
                ),
              ),
              Semantics(
                label: 'Settings',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push(AppRouter.settings),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sub-greeting / Date & Motivational quote placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                dateString,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Focus & Breathe 🧘',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
