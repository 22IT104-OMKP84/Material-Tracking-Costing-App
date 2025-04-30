import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _role;
  bool _isLoading = false;

  User? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _role == 'admin';

  AuthProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserRole();
      } else {
        _role = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserRole() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      _role = doc.data()?['role'] as String?;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user role: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _user;
      if (user == null) throw Exception('No user logged in');

      // Reauthenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 