import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController pinController = TextEditingController();
  String? _savedPin;
  bool _isAuthenticating = false;
  bool _isBiometricsEnabled = false;
  bool _isLocalAuthEnabled = false;
  bool _hasBiometricSupport = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _savedPin = prefs.getString('user_pin');
        _isBiometricsEnabled = prefs.getBool('isBiometricsEnabled') ?? false;
        _isLocalAuthEnabled = prefs.getBool('isLocalAuthEnabled') ?? false;
      });
      await _checkBiometrics();
    } catch (e) {
      _showError('Failed to load settings: $e');
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final bool isSupported = await auth.isDeviceSupported();

      setState(() {
        _hasBiometricSupport = canCheckBiometrics && isSupported;
      });

      if (!_hasBiometricSupport) {
        _showMessage('Biometrics not supported or not set up');
      }
    } catch (e) {
      _showError('Biometric check failed: $e');
    }
  }

  // Add this to your existing _AuthScreenState class

  Future<bool> _checkSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAuthTime = prefs.getString('lastAuthTime');

    if (lastAuthTime == null) return true;

    final lastAuth = DateTime.parse(lastAuthTime);
    final now = DateTime.now();
    final difference = now.difference(lastAuth);

    return difference.inMinutes >= 60; // 1 hour expiration
  }

  Future<void> _updateAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('lastAuthTime', DateTime.now().toIso8601String());
  }

  // Modify your authentication methods to call _updateAuthStatus on success
  Future<void> _authenticateWithBiometrics() async {
    if (!_hasBiometricSupport) return;

    setState(() => _isAuthenticating = true);

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate && mounted) {
        await _updateAuthStatus();
        widget.onAuthenticated();
      } else {
        _showMessage('Authentication cancelled');
      }
    } catch (e) {
      _showError('Biometric authentication failed: $e');
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  void _authenticateWithPin() {
    final enteredPin = pinController.text;

    if (enteredPin.isEmpty) {
      _showMessage('Please enter a PIN');
      return;
    }

    if (enteredPin.length != 4) {
      _showMessage('PIN must be 4 digits');
      return;
    }

    if (enteredPin == _savedPin) {
      _updateAuthStatus().then((_) {
        widget.onAuthenticated();
      });
    } else {
      _showMessage('Incorrect PIN');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  void _showError(String error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authenticate'), centerTitle: true, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'MDLenz',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 32),

                if (_isBiometricsEnabled && _hasBiometricSupport && _savedPin != null)
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.fingerprint, size: 48),
                        onPressed: _isAuthenticating ? null : _authenticateWithBiometrics,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Use Biometrics',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),

                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Enter PIN',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isAuthenticating ? null : _authenticateWithPin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child:
                        _isAuthenticating
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Authenticate with PIN', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
