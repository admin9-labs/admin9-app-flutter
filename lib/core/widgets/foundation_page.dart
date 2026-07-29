import 'package:flutter/material.dart';

class FoundationPage extends StatelessWidget {
  const FoundationPage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
