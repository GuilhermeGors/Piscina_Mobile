import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Retorna o usuário atual, se houver
  User? get currentUser => _firebaseAuth.currentUser;

  // Login com Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // Usuário cancelou o login

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Erro no login com Google: $e');
      return null;
    }
  }

  // Login com GitHub
  Future<User?> signInWithGitHub(BuildContext context) async {
    try {
       GithubAuthProvider githubProvider = GithubAuthProvider();

      final UserCredential userCredential =
          await _firebaseAuth.signInWithProvider(githubProvider);
      return userCredential.user;
    } catch (e) {
      print('Erro no login com GitHub: $e');
      return null;
    }
  }

  // Verifica se o usuário está logado
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Logout
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut(); // Desconecta do Google, se aplicável
  }
}