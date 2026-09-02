import 'package:flutter/widgets.dart';

class ResponsivePageBody extends StatelessWidget {
  const ResponsivePageBody({
    super.key,
    required this.children,
    this.maxWidth = 720,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 24,
    this.safeAreaBottom = true,
  });

  final List<Widget> children;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    bottom: safeAreaBottom,
    child: SingleChildScrollView(
      padding: padding,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing,
            children: children,
          ),
        ),
      ),
    ),
  );
}
