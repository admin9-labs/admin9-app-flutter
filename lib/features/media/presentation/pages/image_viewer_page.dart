import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../../../../shared/ui/media/image_viewer/a_image_viewer.dart';
import '../../../../shared/ui/media/image_viewer/a_image_viewer_item.dart';

@RoutePage()
class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  final List<AImageViewerItem> items;
  final int initialIndex;

  @override
  Widget build(BuildContext context) => AImageViewer(
    items: items,
    initialIndex: initialIndex,
    onClose: () => context.router.root.maybePop(),
  );
}
