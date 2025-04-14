import 'package:flutter/material.dart';
// import 'package:optional/main_screen.dart';
import 'package:optional/theme_controller.dart';
import 'package:optional/view1.dart';
import 'package:optional/user_profile.dart';
import 'package:provider/provider.dart';

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
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              displayMedium: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              displaySmall: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              headlineLarge: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              headlineMedium: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              headlineSmall: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              titleLarge: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              titleMedium: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              titleSmall: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              bodyLarge: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              bodyMedium: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              bodySmall: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              labelLarge: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              labelMedium: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
              labelSmall: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.black,
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
            fontFamily: 'OpenSauce',
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              displayMedium: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              displaySmall: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              headlineLarge: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              headlineMedium: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              headlineSmall: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              titleLarge: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              titleMedium: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              titleSmall: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              bodyLarge: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              bodyMedium: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              bodySmall: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              labelLarge: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              labelMedium: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
              labelSmall: TextStyle(
                fontFamily: 'OpenSauce',
                color: Colors.white,
              ),
            ),
          ),
          themeMode: currentThemeMode,
          // home: const MainScreen(),
          // home: const ProfileScreen(),
          home: const LoginSignupScreen(),
        );
      },
    );
  }
}
