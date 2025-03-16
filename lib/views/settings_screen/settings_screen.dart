import 'package:flutter/material.dart';
import 'package:mdlenz/providers/theme_provider.dart';
import 'package:mdlenz/views/auth/logout.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final bool _isGoogleCloudSyncEnabled = false;
  bool _isLocalAuthEnabled = false;
  bool _isBiometricsEnabled = false;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocalAuthEnabled = prefs.getBool('isLocalAuthEnabled') ?? false;
      _isBiometricsEnabled = prefs.getBool('isBiometricsEnabled') ?? false;
    });
  }

  // Save local auth setting
  Future<void> _saveLocalAuthSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLocalAuthEnabled', value);
  }

  // Save biometrics setting
  Future<void> _saveBiometricsSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBiometricsEnabled', value);
  }

  // Set or change PIN
  Future<void> _setPin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final newPin = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Set PIN'),
            content: TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Enter a 4-digit PIN'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  final pin = _pinController.text;
                  if (pin.length == 4) {
                    Navigator.of(context).pop(pin);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (newPin != null) {
      await prefs.setString('user_pin', newPin);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Information Section
          const Text(
            'App Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const ListTile(title: Text('Version'), subtitle: Text('1.0.0')),
          const ListTile(title: Text('Developer'), subtitle: Text('Michael Tunwashe (Technolenz)')),
          const ListTile(
            title: Text('GitHub Repository'),
            subtitle: Text('https://github.com/Technolenz/mdlenz'),
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Theme Settings Section
          const Text('Theme Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Toggle Theme'),
            subtitle: const Text('Switch between Amber & Blue and Light Blue Accent themes'),
            value: themeProvider.currentTheme == ThemeProvider.amberBlueTheme,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Google Cloud Sync Settings Section
          const Text(
            'Google Cloud Sync',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Enable Google Cloud Sync'),
            subtitle: const Text('Save and sync Markdown files to Google Cloud'),
            value: _isGoogleCloudSyncEnabled,
            onChanged: (value) {
              null;
            },
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Authentication Settings Section
          const Text('Authentication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Enable Local Authentication'),
            subtitle: const Text('Lock the app using biometrics or PIN'),
            value: _isLocalAuthEnabled,
            onChanged: (value) async {
              setState(() {
                _isLocalAuthEnabled = value;
              });
              await _saveLocalAuthSetting(value);
            },
          ),
          SwitchListTile(
            title: const Text('Enable Biometrics'),
            subtitle: const Text('Use biometrics for authentication'),
            value: _isBiometricsEnabled,
            onChanged: (value) async {
              setState(() {
                _isBiometricsEnabled = value;
              });
              await _saveBiometricsSetting(value);
            },
          ),
          ListTile(
            title: const Text('Set or Change PIN'),
            subtitle: const Text('Set a 4-digit PIN for authentication'),
            onTap: () => _setPin(context),
          ),
          const Divider(),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LogOut()));
            },
          ),
        ],
      ),
    );
  }
}
