import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';
import 'package:adhan_reminder/core/utils/theme_utils.dart';
import 'package:adhan_reminder/features/adhan/presentation/providers/adhan_provider.dart';

class DynamicScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const DynamicScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {


    final adhanProvider = context.watch<AdhanProvider>();

    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(
        color: context.backgroundColor,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}
