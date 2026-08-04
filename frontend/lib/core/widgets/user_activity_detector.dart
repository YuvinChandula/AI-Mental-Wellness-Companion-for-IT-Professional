import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/inactivity_service.dart';

class UserActivityDetector extends ConsumerWidget {
  final Widget child;

  const UserActivityDetector({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => ref.read(inactivityServiceProvider).userActivityDetected(),
      onPointerMove: (_) => ref.read(inactivityServiceProvider).userActivityDetected(),
      onPointerHover: (_) => ref.read(inactivityServiceProvider).userActivityDetected(),
      child: child,
    );
  }
}
