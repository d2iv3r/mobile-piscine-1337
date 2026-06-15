// import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();


  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  Future<UserCredential?> signInWithGitHub() async {
    try {
      final githubProvider = GithubAuthProvider();

      return await FirebaseAuth.instance.signInWithProvider(
        githubProvider,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        'GitHub sign-in failed: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'GitHub sign-in failed: $e',
      );
    }
}

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-credential':
        return 'The credential is invalid or expired. Please try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Contact support.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}