import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutline;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ButtonStyle baseStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
    );

    if (isLoading) {
      return Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : theme.colorScheme.primary.withOpacity(0.7),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: isOutline ? Border.all(color: theme.colorScheme.primary) : null,
        ),
        child: Center(
          child: SpinKitThreeBounce(
            color: isOutline ? theme.colorScheme.primary : Colors.white,
            size: 24,
          ),
        ),
      );
    }

    if (isOutline) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(color: theme.colorScheme.primary),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      );
    }

    return ElevatedButton(
      style: baseStyle,
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
