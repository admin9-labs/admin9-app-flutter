import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [const FCircularProgress(), Text(label)],
    ),
  );
}
