import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:optional/about_app.dart';
import 'package:optional/change_password_screen.dart';
import 'package:optional/login_page.dart';
import 'package:optional/report_bug.dart';
import 'package:optional/terms_condition.dart';
import 'package:optional/theme_controller.dart';
import 'package:optional/user_profile.dart';
import 'package:optional/referal_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

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
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;

          final fullName =
              userData['fullName'] ?? user.displayName ?? 'Name Not Available';
          final email = user.email ?? 'No email Available';
          
          // Get notification preference from Firebase - default to true if not set
          final notificationsEnabled = userData['notificationsEnabled'] ?? true;

          // Update controllers and state
          setState(() {
            _nameController.text = fullName;
            _emailController.text = email;
            _notificationsEnabled = notificationsEnabled;
          });

          // Also update the provider so the UI reflects the changes
          Provider.of<UserProfileProvider>(context, listen: false)
              .updateProfile(
            fullName: fullName,
            email: email,
          );
        } else {
          // Create a new document for this user if it doesn't exist
          final fullName = user.displayName ?? 'User';
          final email = user.email ?? 'No Email';

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'fullName': fullName,
            'email': email,
            'notificationsEnabled': true, // Default to true for new users
            // 'createdAt': Timestamp.now(),
          });

          // Update with default values
          setState(() {
            _nameController.text = fullName;
            _emailController.text = email;
            _notificationsEnabled = true;
          });

          Provider.of<UserProfileProvider>(context, listen: false)
              .updateProfile(
            fullName: fullName,
            email: email,
          );
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      // Show an error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  // Function to update notification preference in Firebase
  Future<void> _updateNotificationPreference(bool value) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Update the value in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'notificationsEnabled': value});

      // Update UI state
      setState(() {
        _notificationsEnabled = value;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Notifications enabled' : 'Notifications disabled'
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating notification preference: $e');
      // Revert switch state in case of error
      setState(() {
        _notificationsEnabled = !value;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update notification preference: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  final TextEditingController _passwordController = TextEditingController();
  void _editProfileDialog() {
    final userProfile =
        Provider.of<UserProfileProvider>(context, listen: false);

    // Pre-fill controllers with latest data
    _nameController.text = userProfile.profile.fullName;
    _emailController.text = userProfile.profile.email;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text('Edit Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
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
                onPressed: () async {
                  final fullName = _nameController.text.trim();
                  final email = _emailController.text.trim();

                  // Update Provider
                  final userProfile = Provider.of<UserProfileProvider>(
                    context,
                    listen: false,
                  );

                  // Update Firestore

                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User not logged in')),
                    );
                    return;
                  }
                  try {
                    // 🔹 Update name in Firestore
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'fullName': fullName});

                    // 🔹 Update email in FirebaseAuth
                    if (email != user.email) {
                      // Re-authenticate before changing email
                      final cred = EmailAuthProvider.credential(
                        email: user.email!,
                        password:
                            _passwordController.text.trim(), // Ask for password
                      );

                      await user.reauthenticateWithCredential(cred);
                      await user.updateEmail(email);

                      // Optional: You may want to verify new email
                      await user.sendEmailVerification();
                      // Update email in Firestore too (if you're storing it)
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({'email': email});
                    }
                    userProfile.updateProfile(fullName: fullName, email: email);

                    // This is the important line - update the local state too
                    setState(() {
                      _nameController.text = fullName;
                      _emailController.text = email;
                    });

                    Navigator.pop(context);
                  } catch (e) {
                    print('Error updating profile: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Failed to update: ${e.toString()}')),
                    );
                  }
                },
                child: const Text('Save'),
              )
            ]);
      },
    );
  }

  // Shows a dialog with referral history
  void _showReferralHistory() async {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUserReferrals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              title: Text("Loading Referrals"),
              content: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Failed to load referrals: ${snapshot.error}"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return AlertDialog(
              title: Text("No Referrals"),
              content: Text("You haven't sent any referrals yet."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const ReferalScreen())
                    );
                  },
                  child: Text("Send a Referral"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            );
          } else {
            final referrals = snapshot.data!;
            return AlertDialog(
              title: Text("Your Referrals"),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: referrals.length,
                  itemBuilder: (context, index) {
                    final referral = referrals[index];
                    final timestamp = referral['timestamp'] as Timestamp;
                    final dateTime = timestamp.toDate();
                    final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
                    
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(referral['toName'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(referral['toCompany'] ?? 'Unknown Company'),
                            Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        trailing: Icon(Icons.email),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const ReferalScreen())
                    );
                  },
                  child: Text("Send New"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // Fetch user referrals from Firestore
  Future<List<Map<String, dynamic>>> _fetchUserReferrals() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Query the 'userReferrals' collection for this user's referrals
      final querySnapshot = await FirebaseFirestore.instance
          .collection('referralRequests')
          .where('fromUID', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching referrals: $e');
      rethrow;
    }
  }

  // New function to show language alert
  void _showLanguageAlert() {
    // Get the current theme brightness
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode =
        ThemeController.themeModeNotifier.value == ThemeMode.dark ||
            (ThemeController.themeModeNotifier.value == ThemeMode.system &&
                brightness == Brightness.dark);
                
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            "Coming Soon",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            "We are working hard on this to available soon.",
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
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
                "OK",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.blue : Colors.blue,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          actionsAlignment: MainAxisAlignment.center,
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
                Navigator.of(context).pop(); // Dismiss the logout dialog
                _performLogout(context); // Proceed with updated logout method
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

  // New method for handling the logout process
  Future<void> _performLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // First sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      
      // Then sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Close loading indicator
      Navigator.of(context).pop();
      
      // Clear any stored user data if needed
      if (context.mounted) {
        Provider.of<UserProfileProvider>(context, listen: false).clearProfile();
      }
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      // Close loading indicator if it's showing
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Navigate to the login page after signing out
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
        (route) => false, // Remove all previous routes
      );
    } catch (e) {
      print('Logout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $e')),
      );
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
                                        profile.fullName,
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
                            buildSettingsTile("Change Password", isDarkMode),
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
                            // buildTile("Privacy Settings", isDarkMode),
                            // Modified this line to use the new function
                            buildTile("Language", isDarkMode, onTap: _showLanguageAlert),
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
                        // New My Datas section
                        sectionCard(
                          isDarkMode,
                          title: "MY DATAS",
                          children: [
                            ListTile(
                              title: Text(
                                "Referrals",
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
                              leading: Icon(
                                Icons.people_outline,
                                color: isDarkMode ? Colors.white : Colors.blue,
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              onTap: _showReferralHistory,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        sectionCard(
                          isDarkMode,
                          title: "ABOUT",
                          children: [
                            buildTile(
                              "About the App",
                              isDarkMode,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AboutAppScreen(),
                                  ),
                                );
                              },
                            ),
                            buildTile("Terms & Conditions", isDarkMode,
                                onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TermsAndConditionsScreen()),
                              );
                            }),

                            buildTile("Report a Bug", isDarkMode, onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ReportBugScreen()),
                              );
                            }),
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
                                    color: Color(0xFFA31AED),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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
            // ignore: deprecated_member_use
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
  Widget buildTile(String title, bool isDarkMode, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget buildSettingsTile(String title, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        if (title == "Change Password") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ChangePasswordScreen()),
          );
        }
        // Add more actions here if needed
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          // color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
            ),
          ],
        ),
      ),
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