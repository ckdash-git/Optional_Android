import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:optional/login_page.dart';
import 'package:optional/main_screen.dart'; // Import your main screen or home page

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has user data, then they're logged in
        if (snapshot.hasData) {
          // Return your app's main screen
          return const MainScreen(); // Replace with your main screen widget
        }
        
        // Otherwise, they're not logged in
        return const LoginSignupScreen();
      },
    );
  }
}
