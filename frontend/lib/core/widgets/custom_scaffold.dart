import 'package:flutter/material.dart';
import '../../shared/widgets/loading_overlay.dart';
import 'primary_app_bar.dart';

class CustomScaffold extends StatelessWidget {
  final String? appBarTitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool isLoading;
  final bool resizeToAvoidBottomInset;

  const CustomScaffold({
    super.key,
    this.appBarTitle,
    required this.body,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.isLoading = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTitle != null
          ? PrimaryAppBar(
              title: appBarTitle!,
              leading: leading,
              actions: actions,
            )
          : null,
      body: LoadingOverlay(
        isLoading: isLoading,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: body,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
