import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  // Create the GoogleSignIn instance with proper configuration
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // This forces the account picker to show every time
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard,
  );
  
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserCredential> signInWithGoogle() async {
    try {
      // First, ensure we're signed out from Google
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      // Force account selection by setting forceCodeForRefreshToken to true
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // If sign in was canceled by user
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'popup-closed-by-user',
          message: 'Sign-in cancelled by user',
        );
      }

      // Obtain the auth details from the sign in
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow; // Propagate error for handling in the UI
    }
  }
  
  // Method to handle proper sign out
  static Future<void> signOut() async {
    try {
      // Disconnect will revoke all access tokens
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
}