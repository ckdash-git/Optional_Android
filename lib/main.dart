import 'package:flutter/material.dart';
// import 'view1.dart'; // Import your new UI screen
// import 'view2.dart';
// import 'view4.dart';
import 'view4.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // debugShowCheckedModeBanner: false
      // home: const LoginSignupScreen(), // Set your custom screen here
      // home: const CustomUIScreen()
      
      // home: const SearchScreen(),
      home: const ProfileScreen(),
    );
  }
}
