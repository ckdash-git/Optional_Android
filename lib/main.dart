import 'package:flutter/material.dart';
import 'package:optional/auth_gate.dart';
import 'package:optional/theme_controller.dart';
import 'package:optional/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
            fontFamily: 'OpenSauce',
          ),
          themeMode: currentThemeMode,
          home: const AuthGate(), // Replace LoginSignupScreen with AuthGate
        );
      },
    );
  }
}
