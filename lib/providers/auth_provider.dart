import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '192089773032-vboegihsentgbe4mn4g4l35vfkik00fa.apps.googleusercontent.com'
        : null,
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  User? get user => _user;

  bool _isNewUser = false;
  bool get isNewUser => _isNewUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _checkAndSetUserStatus(user);
      } else {
        _isNewUser = false;
        _errorMessage = null;
      }
      notifyListeners();
    });
  }

  Future<User?> signInWithGoogle() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google sign-in cancelled by user.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      if (_user != null) {
        await _checkAndSetUserStatus(_user!);
      }

      return _user;
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message ?? 'An unknown Firebase error occurred.');
      return null;
    } catch (e) {
      _setErrorMessage('Failed to sign in with Google: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      _setErrorMessage('Failed to sign out: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _checkAndSetUserStatus(User user) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    if (userDoc.exists) {
      _isNewUser = !(userDoc.data()?['hasCompletedOnboarding'] ?? false);
      print('Existing user. Onboarding complete: ${!_isNewUser}');
    } else {
      await userDocRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'hasCompletedOnboarding': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _isNewUser = true;
    }
  }

  Future<void> markOnboardingComplete() async {
    if (_user == null) {
      _setErrorMessage('No user signed in to mark onboarding complete.');
      return;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'hasCompletedOnboarding': true,
      });
      _isNewUser = false;
    } catch (e) {
      _setErrorMessage('Failed to mark onboarding complete: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setErrorMessage(String? message) {
    if (_errorMessage != message) {
      _errorMessage = message;
      notifyListeners();
    }
  }
}
