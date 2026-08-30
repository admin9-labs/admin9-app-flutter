import 'package:flutter/widgets.dart';

class ResponsivePageBody extends StatelessWidget {
  const ResponsivePageBody({
    super.key,
    required this.children,
    this.maxWidth = 720,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 24,
  });

  final List<Widget> children;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final double spacing;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
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
