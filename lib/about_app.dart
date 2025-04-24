import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About the App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          '''
About the App

Welcome to our application!

This app is designed to provide users with a seamless experience for learning, exploring, and engaging with useful features like:
- Code Compiler
- Document Viewer
- Class Management
- Blog Access
- Community Discussions

Our mission is to make education and development accessible to everyone through a clean and powerful mobile platform.

Version: 1.0.0
Developed by: [Optional Team]
Release Date: April 2025

We’re continuously working to improve your experience. Thank you for using our app!
          ''',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
