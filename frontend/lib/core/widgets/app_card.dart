import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final CardTheme cardTheme = Theme.of(context).cardTheme;
    final Widget cardContent = Padding(
      padding: padding ?? cardTheme.margin ?? const EdgeInsets.all(16.0),
      child: child,
    );

    return Card(
      color: color ?? cardTheme.color,
      margin: margin ?? cardTheme.margin,
      elevation: cardTheme.elevation,
      shape: cardTheme.shape,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: cardContent,
            )
          : cardContent,
    );
  }
}
// Placeholder class mappings for testing imports consistency
class AppCardHeader extends StatelessWidget {
  final String title;
  const AppCardHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleMedium);
}
