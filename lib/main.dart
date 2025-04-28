import 'package:flutter/material.dart';
import 'package:optional/auth_gate.dart';
import 'package:optional/theme_controller.dart';
import 'package:optional/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optional/walkthrough_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission (important for Android 13+)
  NotificationSettings settings = await messaging.requestPermission();

  // Get FCM token
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // Foreground message handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Foreground Message: ${message.notification?.title}");
  });

  // Check if walkthrough has been shown before
  final prefs = await SharedPreferences.getInstance();
  final bool showWalkthrough = prefs.getBool('show_walkthrough') ?? true;

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProfileProvider(),
      child: MyApp(showWalkthrough: showWalkthrough),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showWalkthrough;
  
  const MyApp({super.key, this.showWalkthrough = true});

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
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
            fontFamily: 'OpenSauce',
          ),
          themeMode: currentThemeMode,
          home: showWalkthrough ? WalkthroughScreen(onComplete: () async {
            // Save that walkthrough has been shown
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('show_walkthrough', false);
          }) : const AuthGate(),
        );
      },
    );
  }
}