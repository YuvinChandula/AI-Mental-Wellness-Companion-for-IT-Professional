import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routing/app_router.dart';

class BottomNavigation extends StatelessWidget {
  final String currentPath;

  const BottomNavigation({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _getSelectedIndex(currentPath);

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (int index) {
        final String targetPath = _getPathFromIndex(index);
        context.go(targetPath);
      },
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: 'Mood',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'AI Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Reports',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  int _getSelectedIndex(String path) {
    if (path.startsWith(AppRouter.moodJournal)) return 1;
    if (path.startsWith(AppRouter.aiChat)) return 2;
    if (path.startsWith(AppRouter.reports)) return 3;
    if (path.startsWith(AppRouter.profile)) return 4;
    return 0; // Default to Dashboard Tab
  }

  String _getPathFromIndex(int index) {
    switch (index) {
      case 1:
        return AppRouter.moodJournal;
      case 2:
        return AppRouter.aiChat;
      case 3:
        return AppRouter.reports;
      case 4:
        return AppRouter.profile;
      default:
        return AppRouter.dashboard;
    }
  }
}
