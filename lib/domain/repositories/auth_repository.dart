import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> signInWithGoogle();
  Future<User?> signInWithFacebook();
  Future<void> signOut();
  Future<User?> getCurrentUser();

  Stream<User?> authStateChanges();
}
