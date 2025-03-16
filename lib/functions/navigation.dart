import 'package:flutter/material.dart';

class MyNavigationDrawer extends StatelessWidget {
  final Function(int) onItemTapped;

  const MyNavigationDrawer({super.key, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MDLenz',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(0); // Navigate to Home
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_open),
            title: const Text('Files'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(1); // Navigate to Files
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(2); // Navigate to Settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(3); // Navigate to About
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(4); // Navigate to Help
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log-out'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(5); // Navigate to Help
            },
          ),
        ],
      ),
    );
  }
}
