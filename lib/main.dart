import 'package:flutter/material.dart';
// ✅ use MainScreen
import 'package:optional/theme_controller.dart';
import 'package:optional/view1.dart';
import 'package:optional/user_profile.dart';
import 'package:provider/provider.dart';
// already imported

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProfileProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeModeNotifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'OpenSauce',
            // your textTheme...
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
            fontFamily: 'OpenSauce',
            // your textTheme...
          ),
          themeMode: currentThemeMode,
          home: const LoginSignupScreen(), // ✅ now using MainScreen
        );
      },
    );
  }
}
