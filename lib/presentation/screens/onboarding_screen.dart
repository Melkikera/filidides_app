import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required Null Function(dynamic firebaseUser) onSignIn,
  });

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState(onSignIn: (User user) {});
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final void Function(User user) onSignIn;
  _OnboardingScreenState({required this.onSignIn});

  // Instances Firebase
  Future<void> ensureInitialized() async {
    return GoogleSignInPlatform.instance.init(const InitParameters());
  }

  Future<void> signInWithGoogle() async {
    try {
      await ensureInitialized();
      final AuthenticationResults result = await GoogleSignInPlatform.instance
          .authenticate(const AuthenticateParameters());

      final String? idToken = result.authenticationTokens.idToken;
      if (idToken != null) {
        //connecté !
        //récupérer les infos utilisateur
        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: idToken,
        );
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);
        final firebaseUser = userCredential.user;
        if (firebaseUser != null) {
          onSignIn(firebaseUser);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Connecté avec Google ! ${firebaseUser.displayName ?? firebaseUser.email}",
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la récupmération du token")),
        );
      }
    } on GoogleSignInException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur Signin: $e")));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur Firebase Auth: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 100),
            const SizedBox(height: 32),
            const Text(
              'Bienvenue sur Filidides',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Découvrez les fonctionnalités et connectez-vous pour commencer.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Se connecter avec Google'),
              onPressed: () => signInWithGoogle(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.facebook),
              label: const Text('Se connecter avec Facebook'),
              onPressed: () {
                // TODO: Add Facebook sign-in logic
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'En continuant, vous acceptez les conditions d’utilisation.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
