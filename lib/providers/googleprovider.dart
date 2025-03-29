import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleProvider with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/drive.file'],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSyncing = false;
  bool _isSignedIn = false;
  bool _isSyncEnabled = false;
  User? _user;

  bool get isSyncing => _isSyncing;
  bool get isSignedIn => _isSignedIn;
  bool get isSyncEnabled => _isSyncEnabled;
  User? get user => _user;

  GoogleProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSyncEnabled = prefs.getBool('google_sync_enabled') ?? false;

    if (_isSyncEnabled) {
      await _silentSignIn();
    }
    notifyListeners();
  }

  Future<void> _silentSignIn() async {
    try {
      final googleUser = await _googleSignIn.signInSilently();
      if (googleUser != null) {
        await _handleSignIn(googleUser);
      }
    } catch (e) {
      debugPrint('Silent sign-in failed: $e');
    }
  }

  @override
  notifyListeners();
  Future<void> toggleSync(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('google_sync_enabled', enabled);
    _isSyncEnabled = enabled;

    if (enabled) {
      await _signIn();
    } else {
      await _signOut();
    }
    notifyListeners();
  }

  Future<void> _signIn() async {
    try {
      _isSyncing = true;
      notifyListeners();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      await _handleSignIn(googleUser);
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      _isSyncEnabled = false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _handleSignIn(GoogleSignInAccount googleUser) async {
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    _user = userCredential.user;
    _isSignedIn = true;
  }

  Future<void> _signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _isSignedIn = false;
      _user = null;
    } catch (e) {
      debugPrint('Sign-out failed: $e');
    }
  }

  Future<void> syncMarkdown(String key, String content) async {
    if (!_isSyncEnabled || !_isSignedIn) return;

    try {
      await _firestore.collection('markdowns').doc(key).set({
        'content': content,
        'lastUpdated': FieldValue.serverTimestamp(),
        'ownerId': _user?.uid,
      });
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  Future<String?> getMarkdown(String key) async {
    if (!_isSyncEnabled || !_isSignedIn) return null;

    try {
      final doc = await _firestore.collection('markdowns').doc(key).get();
      return doc.data()?['content'] as String?;
    } catch (e) {
      debugPrint('Fetch failed: $e');
      return null;
    }
  }
}
