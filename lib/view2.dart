import 'package:flutter/material.dart';

class CustomUIScreen extends StatelessWidget {
  const CustomUIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Unbox',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: const TextSpan(
                  text: 'Based on ',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: 'Your\n',
                      style: TextStyle(
                        color: Color.fromRGBO(58, 89, 209, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'needs',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: [
                    _buildFeatureCard(
                      context,
                      title: 'Compiler',
                      subtitle: 'Run and test code within the App.',
                      gradient: const LinearGradient(
                        colors: [Colors.purpleAccent, Colors.pinkAccent],
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      title: 'Classes',
                      subtitle: 'Watch Classes from Popular Creators.',
                      gradient: const LinearGradient(
                        colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      title: 'Classes',
                      subtitle: 'Watch Classes from Popular Creators.',
                      gradient: const LinearGradient(
                        colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      title: 'Classes',
                      subtitle: 'Watch Classes from Popular Creators.',
                      gradient: const LinearGradient(
                        colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Unwrap!\nThe Optional?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        text: 'Crafted with ',
                        style: TextStyle(color: Colors.grey),
                        children: [
                          WidgetSpan(
                            child: Icon(Icons.favorite, size: 16, color: Colors.red),
                          ),
                          TextSpan(
                            text: ' in Bengaluru, India',
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: () {
        // You can add specific navigation here later if needed
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Icon(Icons.open_in_new, color: Colors.black),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            )
          ],
        ),
      ),
    );
  }
}
