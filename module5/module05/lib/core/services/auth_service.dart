import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // return current user
  User? get currentUser => _firebaseAuth.currentUser;

  // login with google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // Usuário cancelou o login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Google Login error: $e');
      return null;
    }
  }

  // Login with Github
  Future<User?> signInWithGitHub(BuildContext context) async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();

      final UserCredential userCredential = await _firebaseAuth
          .signInWithProvider(githubProvider);
      return userCredential.user;
    } catch (e) {
      debugPrint('Github Login Error: $e');
      return null;
    }
  }

  // verify login
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Logout
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut(); // desconect (soon :D)
  }
}
