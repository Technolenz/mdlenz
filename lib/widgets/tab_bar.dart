import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Tab> tabs;

  const CustomTabBar({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: TabBar(
        tabs: tabs,
        indicatorColor: Theme.of(context).tabBarTheme.indicatorColor,
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
        dividerHeight: 0,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
