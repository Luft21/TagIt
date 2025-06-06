import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  User? get currentUser => FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '192089773032-vboegihsentgbe4mn4g4l35vfkik00fa.apps.googleusercontent.com'
        : null,
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      await _checkAndSetUserStatus(user);
    }
    return user;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<bool> isNewUser(User user) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    if (userDoc.exists) {
      return !(userDoc.data()?['hasCompletedOnboarding'] ?? false);
    } else {
      await userDocRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'hasCompletedOnboarding': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    }
  }

  Future<void> markOnboardingComplete(User user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'hasCompletedOnboarding': true,
    });
  }

  Future<void> _checkAndSetUserStatus(User user) async {
    await isNewUser(user);
  }
}