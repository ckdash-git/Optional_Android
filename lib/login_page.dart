
import 'package:flutter/material.dart';
import 'package:optional/helper/google_sign_in.dart';
import 'package:optional/main_screen.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'user_profile.dart';
import 'package:flutter/gestures.dart';
import 'package:optional/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  bool isValidGmail(String email) {
    final gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    return gmailRegex.hasMatch(email);
  }

// Enhanced Firebase Email/Password error handling
void _validateEmail() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (email.isEmpty || !isValidGmail(email) || password.isEmpty) {
    _shakeKey.currentState?.shake();
    
    // More specific feedback on what's missing
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
    } else if (!isValidGmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Gmail address')),
      );
    } else if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
    }
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    User? user = FirebaseAuth.instance.currentUser;

    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(context,
    MaterialPageRoute(builder: (context) => MainScreen()));

    // Rest of your login success logic remains the same
    // ...
  } on FirebaseAuthException catch (e) {
    setState(() {
      _isLoading = false;
    });

    String getFriendlyFirebaseError(String code) {
      switch (code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'Your account has been disabled. Contact support.';
        case 'user-not-found':
          return 'No account found with this email. Would you like to create one?';
        case 'wrong-password':
          return 'Incorrect password. Please try again or use the "Forgot Password" option.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later or reset your password.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email but different sign-in method.';
        case 'invalid-credential':
          return 'The login information is invalid. Please try again.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled. Please contact support.';
        case 'weak-password':
          return 'Your password is too weak. Please choose a stronger password.';
        case 'email-already-in-use':
          return 'An account already exists with this email. Try logging in instead.';
        default:
          return 'Something went wrong. Please try again later. (Error: ${e.code})';
      }
    }
    
    String errorMessage = getFriendlyFirebaseError(e.code);
    
    // Show a more user-friendly error dialog with appropriate actions
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Login Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage),
            if (e.code == 'user-not-found')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'You can create a new account by tapping "Sign Up" below.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),
            if (e.code == 'wrong-password')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'If you forgot your password, use the "Forgot Password" option.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
        actions: [
          if (e.code == 'user-not-found')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToSignup();
              },
              child: const Text('Sign Up'),
            ),
          if (e.code == 'wrong-password')
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                
                final email = _emailController.text.trim();
                if (email.isNotEmpty && isValidGmail(email)) {
                  setState(() {
                    _isLoading = true;
                  });
                  
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset email sent')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              child: const Text('Reset Password'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } catch (e) {
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}

// Enhanced Google Sign-In error handling
void _signInWithGoogle() async {
  setState(() {
    _isGoogleLoading = true;
  });

  try {
    await GoogleSignInService.signInWithGoogle();
    
    // After successful Google sign-in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Provider.of<UserProfileProvider>(context, listen: false).updateProfile(
        email: user.email ?? '',
        fullName: user.displayName ?? '',
        // photoUrl: user.photoURL,
      );
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  } on FirebaseAuthException catch (e) {
    setState(() {
      _isGoogleLoading = false;
    });
    
    String getFriendlyGoogleSignInError(String code) {
      switch (code) {
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email but different sign-in method. Try signing in with your email and password.';
        case 'invalid-credential':
          return 'Your Google sign-in information is invalid or has expired. Please try again.';
        case 'operation-not-allowed':
          return 'Google sign-in is not enabled for this app. Please contact support.';
        case 'user-disabled':
          return 'Your account has been disabled. Please contact support.';
        case 'user-not-found':
          return 'No account found with this email.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        case 'popup-closed-by-user':
          return 'Sign-in cancelled. Please try again.';
        case 'cancelled-popup-request':
          return 'Another sign-in operation is already in progress.';
        default:
          return 'Google Sign-In failed. Please try again later. (Error: ${e.code})';
      }
    }
    
    String errorMessage = getFriendlyGoogleSignInError(e.code);
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Google Sign-In Failed'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } catch (e) {
    setState(() {
      _isGoogleLoading = false;
    });
    
    // Handle any other exceptions
    String errorMessage = 'Google Sign-In failed. Please try again.';
    
    // Check if error message contains specific keywords to provide better guidance
    String errorString = e.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('connection')) {
      errorMessage = 'Network error. Please check your internet connection and try again.';
    } else if (errorString.contains('timeout')) {
      errorMessage = 'The request timed out. Please try again.';
    } else if (errorString.contains('cancel')) {
      errorMessage = 'Sign-in was cancelled. Please try again.';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}
  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colors based on theme
    final loginButtonColor =
        isDarkMode ? const Color(0xFFa31ade) : Colors.black;
    final googleButtonColor = isDarkMode ? Colors.white : Colors.black;
    final googleTextColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Change to false to prevent resizing
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content in an Expanded widget with SingleChildScrollView
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: height * 0.05),
                      Text.rich(
                        TextSpan(
                          text: 'Optional',
                          style: TextStyle(
                            fontSize: width * 0.17,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
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
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ShakeWidget(
                        key: _shakeKey,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _emailController,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _validateEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: loginButtonColor,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor:
                                loginButtonColor.withOpacity(0.6),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        isDarkMode ? Colors.white : Colors.white,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  final email = _emailController.text.trim();
                                  if (email.isEmpty || !isValidGmail(email)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Enter a valid Gmail address first')),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(email: email);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Password reset email sent')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Error: ${e.toString()}')),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Or',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isLoading || _isGoogleLoading)
                              ? null
                              : _signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: googleButtonColor,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor:
                                googleButtonColor.withOpacity(0.6),
                          ),
                          child: _isGoogleLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: googleTextColor,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 26,
                                      width: 26,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/google-logo.png',
                                          height: 24,
                                          width: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Login with Google',
                                      style: TextStyle(
                                        color: googleTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = (_isLoading || _isGoogleLoading)
                                    ? null
                                    : _navigateToSignup,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Version text fixed at the bottom
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.grey.shade500
                      : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to shake email box on invalid input
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
