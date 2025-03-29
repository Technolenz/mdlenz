import 'package:flutter/material.dart';
import 'package:mdlenz/providers/googleprovider.dart';
import 'package:mdlenz/providers/theme_provider.dart';
import 'package:mdlenz/views/auth/logout.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLocalAuthEnabled = false;
  bool _isBiometricsEnabled = false;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocalAuthEnabled = prefs.getBool('isLocalAuthEnabled') ?? false;
      _isBiometricsEnabled = prefs.getBool('isBiometricsEnabled') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

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
              decoration: const InputDecoration(
                labelText: 'Enter a 4-digit PIN',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final pin = _pinController.text;
                  if (pin.length == 4) Navigator.pop(context, pin);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (newPin != null) {
      await prefs.setString('user_pin', newPin);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PIN saved successfully')));
      }
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _manualSync(GoogleProvider googleProvider) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('markdown_')).toList();
    for (final key in keys) {
      final content = prefs.getString(key) ?? '';
      await googleProvider.syncMarkdown(key, content);
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Manual sync completed')));
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(8.0), child: Column(children: children)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final googleProvider = Provider.of<GoogleProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'App Information'),
            _buildSectionCard([
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Developer'),
                subtitle: const Text('Michael Tunwashe (Technolenz)'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('GitHub Repository'),
                subtitle: const Text('github.com/Technolenz/mdlenz'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _launchURL('https://github.com/Technolenz/mdlenz'),
              ),
            ]),

            _buildSectionHeader(context, 'Appearance'),
            _buildSectionCard([
              SwitchListTile(
                secondary: const Icon(Icons.color_lens_outlined),
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between light and dark theme'),
                value: theme.brightness == Brightness.dark,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ]),

            _buildSectionHeader(context, 'Cloud Sync'),
            _buildSectionCard([
              SwitchListTile(
                secondary: const Icon(Icons.cloud_outlined),
                title: const Text('Google Cloud Sync'),
                subtitle:
                    googleProvider.isSignedIn
                        ? Text('Connected as ${googleProvider.user?.email}')
                        : const Text('Sync your markdown files to the cloud'),
                value: googleProvider.isSyncEnabled,
                onChanged: googleProvider.isSyncing ? null : googleProvider.toggleSync,
              ),
              if (googleProvider.isSyncing) const LinearProgressIndicator(),
              if (googleProvider.isSyncEnabled && !googleProvider.isSyncing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.cloud_off),
                          label: const Text('Disconnect'),
                          onPressed: () => googleProvider.toggleSync(false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.sync),
                          label: const Text('Sync Now'),
                          onPressed: () => _manualSync(googleProvider),
                        ),
                      ),
                    ],
                  ),
                ),
            ]),

            _buildSectionHeader(context, 'Security'),
            _buildSectionCard([
              SwitchListTile(
                secondary: const Icon(Icons.lock_outline),
                title: const Text('App Lock'),
                subtitle: const Text('Require authentication to open the app'),
                value: _isLocalAuthEnabled,
                onChanged: (value) {
                  setState(() => _isLocalAuthEnabled = value);
                  _saveSetting('isLocalAuthEnabled', value);
                },
              ),
              if (_isLocalAuthEnabled)
                ListTile(
                  leading: const Icon(Icons.pin_outlined),
                  title: const Text('Change PIN'),
                  subtitle: const Text('Set a 4-digit security PIN'),
                  onTap: () => _setPin(context),
                ),
            ]),

            _buildSectionHeader(context, 'Account'),
            _buildSectionCard([
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Logout'),
                textColor: theme.colorScheme.error,
                iconColor: theme.colorScheme.error,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LogOut()),
                    ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
