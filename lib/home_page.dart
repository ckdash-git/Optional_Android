import 'package:flutter/material.dart';
import 'package:optional/blog_list_screen.dart';
import 'package:optional/referal_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Title
              Text(
                'Unbox',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              
              // Subtitle
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

              // Feature Cards Grid
              GridView.count(
                shrinkWrap: true, // Important for nested scrolling
                physics: const NeverScrollableScrollPhysics(), // Disables grid scrolling
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
                    title: 'Documents',
                    subtitle: 'Get all the Documentations.',
                    gradient: const LinearGradient(
                      colors: [Colors.purpleAccent, Colors.pinkAccent],
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Frameworks',
                    subtitle: 'Find all the Frameworks Here.',
                    gradient: const LinearGradient(
                      colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Blogs',
                    subtitle: 'Read latest posts over all the popular sites.',
                    gradient: const LinearGradient(
                      colors: [Colors.greenAccent, Colors.teal],
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Referal',
                    subtitle: 'Ask for referal to your dream company employees.',
                    gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.indigo],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Footer
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
                    const SizedBox(height: 20),
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
        if (title == 'Referal') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReferalScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogListScreen(title: title),
            ),
          );
        }
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
                      fontSize: 13,
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