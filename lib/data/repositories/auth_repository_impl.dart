import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/google_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GoogleAuthDataSource googleAuthDataSource;

  AuthRepositoryImpl(this.googleAuthDataSource);

  @override
  Future<User?> signInWithGoogle() async {
    final user = await googleAuthDataSource.signIn();
    if (user == null) return null;
    // Convert your domain User to FirebaseAuth User if needed, or update the return type everywhere to use your domain User.
    // For now, assuming you want to return your domain User:
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Future<User?> signInWithFacebook() async {
    // TODO: Implement Facebook sign-in
    return null;
  }

  @override
  Future<void> signOut() async {
    // TODO: Implement sign out
  }

  @override
  Future<User?> getCurrentUser() async {
    // TODO: Implement get current user
    return null;
  }

  @override
  Stream<User?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;

      return firebaseUser;
    });
  }
}
