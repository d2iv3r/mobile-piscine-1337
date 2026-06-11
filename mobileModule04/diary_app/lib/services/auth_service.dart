import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ─── Current user ────────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Google Sign-In ──────────────────────────────────────────────────────────

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

  // ─── GitHub Sign-In ──────────────────────────────────────────────────────────
  //
  // Replace the values below with your own GitHub OAuth App credentials.
  // Create one at: https://github.com/settings/developers
  //
  // Authorization callback URL must be set to:
  //   diaryapp://callback
  //
  static const String _githubClientId = 'YOUR_GITHUB_CLIENT_ID';
  static const String _githubClientSecret = 'YOUR_GITHUB_CLIENT_SECRET';

  Future<UserCredential?> signInWithGitHub() async {
    try {
      // Step 1: Open GitHub OAuth page in browser and capture the code
      final result = await FlutterWebAuth2.authenticate(
        url:
            'https://github.com/login/oauth/authorize'
            '?client_id=$_githubClientId'
            '&scope=read:user,user:email',
        callbackUrlScheme: 'diaryapp',
      );

      // Step 2: Extract the authorization code from the redirect URI
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) throw Exception('GitHub auth code not found');

      // Step 3: Exchange the code for an access token
      final tokenResponse = await http.post(
        Uri.parse('https://github.com/login/oauth/access_token'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'client_id': _githubClientId,
          'client_secret': _githubClientSecret,
          'code': code,
        }),
      );

      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'] as String?;
      if (accessToken == null) throw Exception('Failed to get GitHub token');

      // Step 4: Sign in to Firebase with the GitHub token
      final credential = GithubAuthProvider.credential(accessToken);
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      throw Exception('GitHub sign-in failed: $e');
    }
  }

  // ─── Sign Out ────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ─── Error mapping ───────────────────────────────────────────────────────────

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