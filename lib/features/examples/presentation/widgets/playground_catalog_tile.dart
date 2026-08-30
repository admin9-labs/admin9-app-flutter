import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class PlaygroundCatalogTile extends StatelessWidget {
  const PlaygroundCatalogTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.capabilitySummary,
    required this.onPress,
  });

  final IconData icon;
  final String title;
  final String description;
  final String capabilitySummary;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) => FTile(
    prefix: Icon(icon),
    title: Text(title),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(description),
        FBadge(variant: .secondary, child: Text(capabilitySummary)),
      ],
    ),
    suffix: const Icon(FLucideIcons.chevronRight),
    onPress: onPress,
  );
}
