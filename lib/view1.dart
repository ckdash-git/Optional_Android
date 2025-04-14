import 'package:flutter/material.dart';
import 'dart:math';
import 'main_screen.dart'; // Update this import
import 'package:provider/provider.dart';
import 'user_profile.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  bool isValidGmail(String email) {
    // Basic validation for name@gmail.com format
    final gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    return gmailRegex.hasMatch(email);
  }

  void _validateEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty || !isValidGmail(email)) {
      _shakeKey.currentState?.shake();
    } else {
      // Update the user profile with the entered email
      Provider.of<UserProfileProvider>(
        context,
        listen: false,
      ).updateProfile(email: email);

      // Navigate to MainScreen instead of CustomUIScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Get the system theme brightness (dark/light)
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor:
          isDarkMode ? Colors.black : Colors.white, // Dynamic background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Text.rich(
                  TextSpan(
                    text: 'Optional',
                    style: TextStyle(
                      fontSize: width * 0.17,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode
                              ? Colors.white
                              : Colors.black, // Dynamic text color
                    ),
                    children: [
                      TextSpan(
                        text: '.',
                        style: TextStyle(color: Colors.purpleAccent),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                Text(
                  'Login or Signup',
                  style: TextStyle(
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.w600,
                    color:
                        isDarkMode
                            ? Colors.white
                            : Colors.black, // Dynamic text color
                  ),
                ),

                const SizedBox(height: 24),

                // Email TextField with Shake animation
                ShakeWidget(
                  key: _shakeKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.grey.shade800
                              : Colors
                                  .grey
                                  .shade100, // Dynamic background color
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _emailController,
                      style: TextStyle(
                        color:
                            isDarkMode
                                ? Colors.white
                                : Colors.black, // Keeps input text black
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color:
                              isDarkMode
                                  ? Colors.white70
                                  : Colors
                                      .grey
                                      .shade600, // Hint text color based on theme
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _validateEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode
                              ? Colors.blueAccent
                              : Colors.black, // Button color based on theme
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color:
                            isDarkMode
                                ? Colors.black
                                : Colors
                                    .white, // Button text color based on theme
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Or',
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? Colors.white70
                            : Colors.grey.shade600, // Text color based on theme
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    SocialButton(icon: Icons.language),
                    SocialButton(icon: Icons.apple),
                    SocialButton(icon: Icons.person),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final IconData icon;

  const SocialButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? Colors.white : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        size: 30,
        color: isDarkMode ? Colors.white : Colors.black,
      ), // Icon color based on theme
    );
  }
}

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  void shake() {
    _controller.forward(from: 0.0);
  }

  @override
  void initState() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0,
      end: 24,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(sin(_animation.value * pi) * 6, 0),
          child: widget.child,
        );
      },
    );
  }
}
