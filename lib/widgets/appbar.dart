import 'package:flutter/material.dart';
import 'package:mdlenz/views/auth/logout.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const AppBarWidget({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('MD-Lenz'),
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          scaffoldKey.currentState?.openDrawer(); // Open the drawer
        },
        icon: const Icon(Icons.menu),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LogOut()));
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
