import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _register() {
    if (_formKey.currentState!.validate()) {
      if (_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully Registered")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please accept Terms and Conditions")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image at the top
                Image.asset(
                  'assets/images/signup.jpg',
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  validator: (value) =>
                      value != _passwordController.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 16),

                CheckboxListTile(
                  value: _acceptTerms,
                  onChanged: (value) {
                    setState(() => _acceptTerms = value ?? false);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('I accept the Terms and Conditions'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                    backgroundColor: isDarkMode ? Colors.tealAccent[700] : Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Register', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
