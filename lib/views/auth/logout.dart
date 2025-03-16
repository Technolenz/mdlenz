import 'package:flutter/material.dart';
import 'package:mdlenz/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogOut extends StatefulWidget {
  const LogOut({super.key});

  @override
  State<LogOut> createState() => _LogOutState();
}

class _LogOutState extends State<LogOut> {
  bool _isLoggingOut = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Schedule the dialog after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _confirmLogout(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _isLoggingOut
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 16),
                    const Text('Logging out...', style: TextStyle(color: Colors.grey)),
                  ],
                )
                : const SizedBox(),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
                child: const Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // Use rootNavigator to ensure we're modifying the correct navigation stack
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      await _logout(context);
    } else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _logout(BuildContext context) async {
    setState(() => _isLoggingOut = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_pin');
      await prefs.setBool('isLocalAuthEnabled', false); // Ensure this is cleared

      // Navigate using root navigator
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }
}
