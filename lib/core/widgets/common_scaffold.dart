import 'package:flutter/material.dart';
import 'package:ocr_interview_assignment/core/core.dart';

class CommonScaffold extends StatelessWidget {
  const CommonScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.space20,
      vertical: AppDimensions.space16,
    ),
    this.showBack = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.scrollable = false,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry padding;
  final bool showBack;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final padded = Padding(padding: padding, child: body);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        child: scrollable ? SingleChildScrollView(child: padded) : padded,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
