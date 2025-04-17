// This is the main screen of the app that contains the bottom navigation bar and the three tabs: Home, Search, and Profile.
// It uses a StatefulWidget to manage the state of the selected tab and updates the UI accordingly.
// The screen is built using a Scaffold widget, which contains the body and the bottom navigation bar.  
// The body of the screen is a list of widgets that correspond to each tab, and the bottom navigation bar allows the user to switch between them.

import 'package:flutter/material.dart';
import 'package:optional/home_page.dart'; // Home
import 'package:optional/profile_page.dart'; // Profile
import 'package:optional/search_screen.dart'; // Your custom search

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomePage(),    // Home
    SearchScreen(),      // Search tab
    ProfileScreen(),     // Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
