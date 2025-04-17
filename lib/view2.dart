import 'package:flutter/material.dart';
import 'package:optional/blog_list_screen.dart';

class CustomUIScreen extends StatelessWidget {
  const CustomUIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unbox',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Based on ',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                  children: [
                    const TextSpan(
                      text: 'Your\n',
                      style: TextStyle(
                        color: Color.fromRGBO(58, 89, 209, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'needs',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Instead of Expanded, use a fixed-height container inside scroll view
              SizedBox(
                height:
                    screenHeight * 0.7, // Adjust as per screen or content needs
                child: GridView.count(
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable nested scrolling
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
                      title: 'Compiler2',
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
                      title: 'Projects',
                      subtitle: 'Hands-on coding challenges.',
                      gradient: const LinearGradient(
                        colors: [Colors.greenAccent, Colors.teal],
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      title: 'Community',
                      subtitle: 'Connect with others.',
                      gradient: const LinearGradient(
                        colors: [Colors.blueAccent, Colors.indigo],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    const Text(
                      'Unwrap!\nThe Optional?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        text: 'Crafted with ',
                        style: const TextStyle(color: Colors.grey),
                        children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.favorite,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                          const TextSpan(text: ' in Bengaluru, India'),
                        ],
                      ),
                    ),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlogListScreen(title: title),
          ),
        );
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
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.open_in_new, color: Colors.black),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
