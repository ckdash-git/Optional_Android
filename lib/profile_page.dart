import 'package:flutter/material.dart';
import 'package:optional/theme_controller.dart';
import 'package:optional/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:optional/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _showAppearanceOptions = false;

  // Text controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with default empty values
    _nameController = TextEditingController(text: '');
    _emailController = TextEditingController(text: '');

    // Fetch user profile asynchronously
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      // Get the currently logged-in user
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final email = user.email;

        // Fetch user data from Firestore (or Realtime Database)
        final userDoc = await FirebaseFirestore.instance
            .collection('users') // Replace 'users' with your collection name
            .doc(email) // Assuming email is used as the document ID
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          setState(() {
            _nameController.text = userData?['name'] ?? '';
            _emailController.text = email ?? '';
          });
        } else {
          // Handle case where user data is not found
          print('User data not found for email: $email');
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _editProfileDialog() {
    // Ensure the controllers are updated with the latest profile data
    _nameController.text = _nameController.text.isNotEmpty
        ? _nameController.text
        : "Enter your name"; // Default placeholder if empty
    _emailController.text = _emailController.text.isNotEmpty
        ? _emailController.text
        : "Enter your email"; // Default placeholder if empty

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController, // Display current name
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name', // Placeholder text
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController, // Display current email
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email', // Placeholder text
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save the updated profile data
                Provider.of<UserProfileProvider>(
                  context,
                  listen: false,
                ).updateProfile(
                  name: _nameController.text,
                  email: _emailController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Logout function
  void _logout() {
    // Get the current theme brightness
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode =
        ThemeController.themeModeNotifier.value == ThemeMode.dark ||
            (ThemeController.themeModeNotifier.value == ThemeMode.system &&
                brightness == Brightness.dark);

    // Show iOS-style confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            "Logout",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            // Cancel button (bottom)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.blue : Colors.blue,
                ),
              ),
            ),
            // Logout button (top)
            TextButton(
              onPressed: () {
                logoutUser(context);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: Text(
                "Logout",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginSignupScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use ValueListenableBuilder to listen to theme changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeModeNotifier,
      builder: (context, themeMode, _) {
        final brightness = MediaQuery.of(context).platformBrightness;
        final isDarkMode = themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system && brightness == Brightness.dark);

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32), // Increased margin from the top
                SizedBox(
                  height: 120, // Decreased the height of the profile box
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Consumer<UserProfileProvider>(
                          builder: (context, userProfileProvider, _) {
                            final profile = userProfileProvider.profile;
                            return Row(
                              children: [
                                const CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        profile.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        profile.email,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 14,
                                              color: isDarkMode
                                                  ? Colors.grey[300]
                                                  : Colors.grey[700],
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      GestureDetector(
                                        onTap: _editProfileDialog,
                                        child: Text(
                                          "Edit",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontSize: 12,
                                                color: Colors.blue,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionCard(
                          isDarkMode,
                          title: "SETTINGS",
                          children: [
                            buildTile("Change Password", isDarkMode),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: SwitchListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                title: Text(
                                  "Enable Notifications",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                ),
                                value: _notificationsEnabled,
                                onChanged: (val) {
                                  setState(() => _notificationsEnabled = val);
                                },
                              ),
                            ),
                            buildTile("Privacy Settings", isDarkMode),
                            buildTile("Language", isDarkMode),
                          ],
                        ),
                        const SizedBox(height: 16),
                        sectionCard(
                          isDarkMode,
                          title: "APPEARANCE",
                          children: [
                            ListTile(
                              title: Text(
                                "Theme Mode",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                              ),
                              trailing: Icon(
                                _showAppearanceOptions
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              onTap: () {
                                setState(() {
                                  _showAppearanceOptions =
                                      !_showAppearanceOptions;
                                });
                              },
                            ),
                            if (_showAppearanceOptions) ...[
                              buildRadioTile(
                                icon: Icons.settings,
                                label: "System Default",
                                value: ThemeMode.system,
                                groupValue: themeMode,
                                isDarkMode: isDarkMode,
                              ),
                              buildRadioTile(
                                icon: Icons.light_mode,
                                label: "Light Mode",
                                value: ThemeMode.light,
                                groupValue: themeMode,
                                isDarkMode: isDarkMode,
                              ),
                              buildRadioTile(
                                icon: Icons.dark_mode,
                                label: "Dark Mode",
                                value: ThemeMode.dark,
                                groupValue: themeMode,
                                isDarkMode: isDarkMode,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        sectionCard(
                          isDarkMode,
                          title: "ABOUT",
                          children: [
                            buildTile("About the App", isDarkMode),
                            buildTile("Terms & Conditions", isDarkMode),
                            buildTile("Report a Bug", isDarkMode),
                            // Add logout button
                            ListTile(
                              title: Text(
                                "Logout",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                              ),
                              leading: Icon(Icons.logout, color: Colors.red),
                              onTap: _logout,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Optional",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                ),
                                const TextSpan(
                                  text: ".",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 163, 26, 237),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget sectionCard(
    bool isDarkMode, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget buildTile(String title, bool isDarkMode) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

  Widget buildRadioTile({
    required IconData icon,
    required String label,
    required ThemeMode value,
    required ThemeMode groupValue,
    required bool isDarkMode,
  }) {
    return RadioListTile<ThemeMode>(
      title: Row(
        children: [
          Icon(icon, size: 20, color: isDarkMode ? Colors.white : Colors.black),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
          ),
        ],
      ),
      value: value,
      groupValue: groupValue,
      onChanged: (ThemeMode? newValue) {
        if (newValue != null) {
          ThemeController.updateThemeMode(newValue);
        }
      },
    );
  }
}
