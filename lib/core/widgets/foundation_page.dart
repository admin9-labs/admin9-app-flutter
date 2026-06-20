import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class FoundationPage extends StatelessWidget {
  const FoundationPage({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.pageX,
      AppSpacing.pageTop,
      AppSpacing.pageX,
      AppSpacing.pageBottom,
    ),
    this.maxContentWidth = AppSpacing.contentMaxWidth,
  });

  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > maxContentWidth
                ? maxContentWidth
                : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                child: ListView(padding: padding, children: children),
              ),
            );
          },
        ),
      ),
    );
  }
}
