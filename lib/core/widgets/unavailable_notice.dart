import 'package:flutter/material.dart';

class UnavailableNotice extends StatelessWidget {
  const UnavailableNotice({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 10),
          const Expanded(child: Text('服务尚未接入，当前操作不会提交或保存。')),
        ],
      ),
    );
  }
}
