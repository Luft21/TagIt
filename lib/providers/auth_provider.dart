import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tag_it/firebase_options.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        kIsWeb
            ? '192089773032-vboegihsentgbe4mn4g4l35vfkik00fa.apps.googleusercontent.com'
            : null,
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  User? get user => _user;

  bool _isNewUser = false;
  bool get isNewUser => _isNewUser;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _checkAndSetUserStatus(user);
      } else {
        _isNewUser = false;
      }
      notifyListeners();
    });
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      _user = userCredential.user;

      if (_user != null) {
        await _checkAndSetUserStatus(_user!);
      }

      return _user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _checkAndSetUserStatus(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      _isNewUser = !(userDoc.data()?['hasCompletedOnboarding'] ?? false);
    } else {
      await _firestore.collection('users').doc(user.uid).set({
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
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).update({
        'hasCompletedOnboarding': true,
      });
      _isNewUser = false;
      notifyListeners();
    }
  }
}
