import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:optional/login_page.dart';
import 'package:optional/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        else if(snapshot.hasData) {
          return MainScreen();
        }
        else {
          return LoginSignupScreen();
        }
      },
    );
  }
}
