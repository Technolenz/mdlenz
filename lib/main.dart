import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mdlenz/firebase_options.dart';
import 'package:mdlenz/functions/navigation.dart';
import 'package:mdlenz/providers/googleprovider.dart';
import 'package:mdlenz/providers/theme_provider.dart';
import 'package:mdlenz/views/Misc/about_screen.dart';
import 'package:mdlenz/views/Misc/info_screen.dart';
import 'package:mdlenz/views/auth/logout.dart';
import 'package:mdlenz/views/fileman/main_manager.dart';
import 'package:mdlenz/views/home/home_screen.dart';
import 'package:mdlenz/views/settings_screen/settings_screen.dart';
import 'package:mdlenz/widgets/appbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'views/auth/localauth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print('Firebase initialization error: $e'); // Debugging error
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoogleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],

      child: const MDLenz(),
    ),
  );
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
    return PopScope(
      canPop: false,
      child: FutureBuilder(
        future: _checkAuthStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            final requiresAuth = snapshot.data ?? true;
            final isLocalAuthEnabled = snapshot.data?.$1 ?? false;
            final isSessionValid = snapshot.data?.$2 ?? false;

            // If local auth is enabled and session is invalid, show auth screen
            if (isLocalAuthEnabled && !isSessionValid) {
              return AuthScreen(onAuthenticated: () => _navigateToMainScreen(context));
            }
            // Otherwise go straight to main screen
            return const MainScreen();
          }
        },
      ),
    );
  }

  void _navigateToMainScreen(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // Check both auth settings and session status
  Future<(bool, bool)> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLocalAuthEnabled = prefs.getBool('isLocalAuthEnabled') ?? false;
    final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

    // If not using local auth, no need to check session
    if (!isLocalAuthEnabled) return (false, true);

    // Check session expiration if authenticated
    if (isAuthenticated) {
      final lastAuthTime = prefs.getString('lastAuthTime');
      if (lastAuthTime != null) {
        final lastAuth = DateTime.parse(lastAuthTime);
        final now = DateTime.now();
        final difference = now.difference(lastAuth);
        final isSessionValid = difference.inMinutes < 60;

        // Return both auth enabled status and session validity
        return (true, isSessionValid);
      }
    }

    // Default case - requires authentication
    return (true, false);
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
