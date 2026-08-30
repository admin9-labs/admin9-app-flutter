import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class ComponentExampleSection extends StatelessWidget {
  const ComponentExampleSection({
    super.key,
    required this.title,
    required this.child,
    this.description,
  });

  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 10,
    children: [
      Text(title, style: context.theme.typography.body.lg),
      if (description case final description?)
        Text(description, style: context.theme.typography.body.sm),
      child,
    ],
  );
}
