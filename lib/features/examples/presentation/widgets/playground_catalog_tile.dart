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
  Widget build(BuildContext context) {
    final capabilities = capabilitySummary
        .split('、')
        .where((capability) => capability.isNotEmpty);
    return FTile(
      prefix: Icon(icon),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(description, maxLines: 2, overflow: TextOverflow.visible),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final capability in capabilities)
                FBadge(
                  variant: .secondary,
                  child: Text(
                    capability,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
            ],
          ),
        ],
      ),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: onPress,
    );
  }
}
