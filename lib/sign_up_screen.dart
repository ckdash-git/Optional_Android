import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:optional/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreePolicy = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _errorMessage; // Holds the error message to display on the screen

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Check if the email already exists
        final signInMethods = await _auth.fetchSignInMethodsForEmail(
          _emailController.text.trim(),
        );

        if (signInMethods.isNotEmpty) {
          // Close loading indicator
          Navigator.of(context).pop();

          // Set error message
          setState(() {
            _errorMessage = "This email is already registered. Please log in.";
          });
          return;
        }

        // Attempt to create a user with email and password
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Close loading indicator
        Navigator.of(context).pop();

        // Clear error message
        setState(() {
          _errorMessage = null;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );

        // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
        );
      } on FirebaseAuthException catch (e) {
        // Close loading indicator
        Navigator.of(context).pop();

        // Handle specific Firebase errors
        String errorMessage;
        if (e.code == 'weak-password') {
          errorMessage = 'The password is too weak.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is invalid.';
        } else {
          errorMessage = 'This email is already registered.';
        }

        // Set error message
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: TextStyle(
            color: isDarkMode ? Colors.white : Colors.red, // Error text color
          ),
        ),
      ),
      home: Scaffold(
        resizeToAvoidBottomInset:
            true, // Prevents overflow when the keyboard is open
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            // Allows scrolling when the keyboard is open
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Content takes most of the screen
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading
                      Text(
                        "Create Account",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Sign up to continue",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color:
                              isDarkMode ? Colors.grey.shade300 : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _labelText("Full Name", isDarkMode, theme),
                      _textField(
                        _firstNameController,
                        "Enter your first name",
                        isDarkMode,
                        (value) => value == null || value.isEmpty
                            ? 'First name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      _labelText("Email Address", isDarkMode, theme),
                      _textField(
                        _emailController,
                        "Enter email address",
                        isDarkMode,
                        (value) => value == null || value.isEmpty
                            ? 'Email is required'
                            : null,
                      ),
                      if (_errorMessage !=
                          null) // Display error message if it exists
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Password Field
                      _labelText("Password", isDarkMode, theme),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          "Create password",
                          isDarkMode,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            onPressed: () {
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Password is required'
                            : null,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black, // Input text color
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Confirm Password Field
                      _labelText("Confirm Password", isDarkMode, theme),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: _inputDecoration(
                          "Re-enter password",
                          isDarkMode,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            onPressed: () {
                              setState(() => _obscureConfirmPassword =
                                  !_obscureConfirmPassword);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm password is required';
                          } else if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black, // Input text color
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Checkbox(
                            value: _agreePolicy,
                            onChanged: (value) => setState(
                              () => _agreePolicy = value ?? false,
                            ),
                            activeColor: Colors.blue,
                          ),
                          Expanded(
                            child: Text(
                              "I agree with privacy policy",
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agreePolicy ? _signUp : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(163, 33, 243, 1),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Or sign up with
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "or sign up with",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Social Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _socialIcon('assets/google-logo.png'),
                      _socialIcon('assets/apple.png'),
                      _socialIcon('assets/facebook.jpg'),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Login Redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LoginSignupScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue, // Text color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _labelText(String text, bool isDarkMode, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hint,
    bool isDark,
    String? Function(String?) validator,
  ) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(hint, isDark),
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black, // Input text color
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.black54),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: isDark ? Colors.grey : Colors.black54),
      ),
      labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    );
  }

  Widget _socialIcon(String path) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(path, width: 30, height: 30),
    );
  }
}
