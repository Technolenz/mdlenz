import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mdlenz/functions/navigation.dart';
import 'package:mdlenz/functions/router.dart';
import 'package:mdlenz/providers/theme_provider.dart';
import 'package:mdlenz/views/Misc/about_screen.dart';
import 'package:mdlenz/views/Misc/info_screen.dart';
import 'package:mdlenz/views/auth/logout.dart';
import 'package:mdlenz/views/fileman/main_manager.dart';
import 'package:mdlenz/views/home/home_screen.dart';
import 'package:mdlenz/views/settings_screen/settings_screen.dart';
import 'package:mdlenz/widgets/appbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

import 'views/auth/localauth_screen.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (_) => ThemeProvider(), child: const MDLenz()));
}

class MDLenz extends StatelessWidget {
  const MDLenz({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    FileHandler.setupFileHandler(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme, // Use the current theme
      home: const AuthWrapper(), // Use AuthWrapper to handle authentication
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkLocalAuthEnabled(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          final bool isLocalAuthEnabled = snapshot.data ?? false;
          return isLocalAuthEnabled
              ? AuthScreen(
                onAuthenticated: () => navigateTo(context: context, page: const MainScreen()),
              )
              : const MainScreen();
        }
      },
    );
  }

  // Check if local authentication is enabled
  Future<bool> _checkLocalAuthEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLocalAuthEnabled') ?? false;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const HomeScreen(),
    const MainManagerScreen(),
    const SettingsScreen(),
    const AboutScreen(),
    const InfoScreen(),
    const LogOut(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarWidget(scaffoldKey: _scaffoldKey),
      drawer: MyNavigationDrawer(onItemTapped: _onItemTapped),
      body: _screens[_selectedIndex],
    );
  }
}

class FileHandler {
  static const MethodChannel _channel = MethodChannel('com.technolenz.mdlenz/file');

  static void setupFileHandler(BuildContext context) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openFile') {
        final String fileContent = call.arguments;
        // Open the file content in the HomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen(initialText: fileContent)),
        );
      }
    });
  }
}
