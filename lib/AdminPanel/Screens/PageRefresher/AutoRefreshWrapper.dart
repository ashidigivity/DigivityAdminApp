import 'package:flutter/material.dart';

class AutoRefreshWrapper extends StatelessWidget {
  final Widget child;

  const AutoRefreshWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.blue,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      displacement: 50,
      onRefresh: () async {
        // Default: rebuild current screen
        (context as Element).markNeedsBuild();
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: child,
        ),
      ),
    );
  }
}
