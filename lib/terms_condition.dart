import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          '''
Terms and Conditions

1. Acceptance of Terms:
By using this application, you agree to be bound by these terms and conditions.

2. Use of the App:
You agree to use the app only for lawful purposes. You must not misuse the app in any way that could harm the service or other users.

3. User Content:
You are responsible for any content you post or upload. We are not liable for any user-generated content.

4. Privacy:
We respect your privacy. Personal data is handled as described in our Privacy Policy.

5. Intellectual Property:
All content in the app including texts, graphics, logos, and icons are the property of the app developers or its licensors.

6. Termination:
We reserve the right to suspend or terminate your access to the app at any time for violations of these terms.

7. Updates and Changes:
We may update these terms occasionally. Continued use of the app means you accept the revised terms.

8. Contact:
For any questions, reach out via the contact section of the app.

Last updated: April 2025
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
