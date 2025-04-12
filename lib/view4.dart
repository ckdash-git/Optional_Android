// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:optional/view2.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _showAppearanceOptions = false;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && brightness == Brightness.dark);

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.black,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
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
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person,
                                color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Chandan Kumar Dash",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black)),
                                const SizedBox(height: 4),
                                Text("chandan@email.com",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: isDarkMode
                                            ? Colors.grey[300]
                                            : Colors.grey[700])),
                                const SizedBox(height: 2),
                                const Text("Edit",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionCard(
                        isDarkMode,
                        title: "SETTINGS",
                        children: [
                          buildTile("Change Password", isDarkMode),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: SwitchListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: Text(
                                "Enable Notifications",
                                style: TextStyle(
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
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
                                _showAppearanceOptions = !_showAppearanceOptions;
                              });
                            },
                          ),
                          if (_showAppearanceOptions)
                            ...[
                              buildRadioTile(
                                icon: Icons.settings,
                                label: "System Default",
                                value: ThemeMode.system,
                                groupValue: _themeMode,
                                isDarkMode: isDarkMode,
                              ),
                              buildRadioTile(
                                icon: Icons.light_mode,
                                label: "Light Mode",
                                value: ThemeMode.light,
                                groupValue: _themeMode,
                                isDarkMode: isDarkMode,
                              ),
                              buildRadioTile(
                                icon: Icons.dark_mode,
                                label: "Dark Mode",
                                value: ThemeMode.dark,
                                groupValue: _themeMode,
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Optional",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: ".",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      const Color.fromARGB(255, 163, 26, 237),
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
        bottomNavigationBar: BottomNavigationBar(
  currentIndex: 2,
  onTap: (index) {
    if (index == 0) {
      // Navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CustomUIScreen()),
      );
    } else if (index == 1) {
      // Handle navigation to search screen if any
    } else if (index == 2) {
      // You're already on the profile screen, do nothing
    }
  },
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
  ],
),

      ),
    );
  }

  Widget sectionCard(bool isDarkMode,
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700])),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildTile(String title, bool isDarkMode) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      onTap: () {
        // Handle tap
      },
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
      value: value,
      groupValue: groupValue,
      onChanged: (ThemeMode? mode) {
        setState(() => _themeMode = mode ?? ThemeMode.system);
      },
      title: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black)),
      secondary: Icon(icon,
          color: isDarkMode ? Colors.white : Colors.black, size: 22),
      activeColor: Colors.blue,
      contentPadding: EdgeInsets.zero,
    );
  }
}