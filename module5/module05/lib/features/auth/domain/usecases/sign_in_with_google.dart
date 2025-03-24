import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository _repository;

  SignInWithGoogle(this._repository);

  Future<User?> call() async {
    return await _repository.signInWithGoogle();
  }
}
