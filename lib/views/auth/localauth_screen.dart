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
  String get enteredPin => pinController.text;
  String? _savedPin;
  bool _isAuthenticating = false;
  bool _isBiometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved settings and PIN
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPin = prefs.getString('user_pin');
      _isBiometricsEnabled = prefs.getBool('isBiometricsEnabled') ?? false;
    });
    _checkBiometrics();
  }

  // Check if biometrics are supported
  Future<void> _checkBiometrics() async {
    final bool canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();

    if (!canAuthenticate) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Biometrics not supported or not set up')));
    }
  }

  // Authenticate using biometrics
  Future<void> _authenticateWithBiometrics() async {
    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        widget.onAuthenticated();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Biometric authentication failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Biometric authentication failed: $e')));
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  // Authenticate using PIN
  void _authenticateWithPin() {
    final enteredPin = pinController.text;

    if (enteredPin.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a PIN')));
      return;
    }

    if (enteredPin.length != 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN must be 4 digits')));
      return;
    }

    if (enteredPin == _savedPin) {
      widget.onAuthenticated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authenticate'),
        centerTitle: true,
        elevation: 0, // Remove app bar shadow
      ),
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

                if (_isBiometricsEnabled && _savedPin != null)
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
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
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
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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
