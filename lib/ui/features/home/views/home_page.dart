import 'package:flutter/material.dart';

import '../../../../app/app_identity.dart';
import '../../../shared/brand_mark.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppIdentity.name)),
      body: SafeArea(
        top: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandMark(size: 72, showName: false),
                const SizedBox(height: 24),
                Text('暂无内容', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
