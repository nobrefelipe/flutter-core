import 'package:flutter/material.dart';

import '../../ui/icons/app_icons.dart';
import '../app_config_controller.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return appConfig(
      success: (config) => Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          items: config.navigation
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(AppIcons.resolve(item.icon)),
                  label: item.label,
                ),
              )
              .toList(),
          onTap: (i) => config.navigation[i].navigate(context, forRoot: false),
        ),
      ),
    );
  }
}
