import 'package:flutter/material.dart';
import 'package:optional/auth_gate.dart';

class WalkthroughScreen extends StatefulWidget {
  final Function? onComplete;
  
  const WalkthroughScreen({Key? key, this.onComplete}) : super(key: key);

  @override
  _WalkthroughScreenState createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final int _numPages = 5;

  List<WalkthroughContent> getWalkthroughContent(bool isDarkMode) {
    return [
      WalkthroughContent(
        title: "Welcome to Our App",
        description: "Your first step towards an amazing experience.",
        lightImagePath: "assets/walkthrough_images/light/image1.png",
        darkImagePath: "assets/walkthrough_images/dark/image1.png",
      ),
      WalkthroughContent(
        title: "Discover Features",
        description: "Explore all the powerful features we offer.",
        lightImagePath: "assets/walkthrough_images/light/image2.png",
        darkImagePath: "assets/walkthrough_images/dark/image2.png",
      ),
      WalkthroughContent(
        title: "Easy to Use",
        description: "Simple, intuitive interface designed for you.",
        lightImagePath: "assets/walkthrough_images/light/image3.png",
        darkImagePath: "assets/walkthrough_images/dark/image3.png",
      ),
      WalkthroughContent(
        title: "Stay Connected",
        description: "Connect with others and share your experiences.",
        lightImagePath: "assets/walkthrough_images/light/image4.png",
        darkImagePath: "assets/walkthrough_images/dark/image4.png",
      ),
      WalkthroughContent(
        title: "Get Started",
        description: "You're all set! Let's begin your journey.",
        lightImagePath: "assets/walkthrough_images/light/image5.png",
        darkImagePath: "assets/walkthrough_images/dark/image5.png",
      ),
    ];
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey.shade400,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  void _completeWalkthrough() {
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final walkthroughContent = getWalkthroughContent(isDarkMode);

    // Define button background color based on theme
    final buttonBackgroundColor = isDarkMode 
        ? const Color(0xFFa31ade) // Purple color for dark mode
        : Colors.black;         // Black for light mode

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _numPages,
              itemBuilder: (context, index) {
                return WalkthroughPage(
                  content: walkthroughContent[index],
                  isDarkMode: isDarkMode,
                );
              },
            ),
            Positioned(
              bottom: 80.0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
            ),
            Positioned(
              bottom: 30.0,
              left: 20.0,
              child: _currentPage == _numPages - 1
                  ? const SizedBox()
                  : TextButton(
                      onPressed: _completeWalkthrough,
                      child: const Text(
                        'Skip',
                        style: TextStyle(fontSize: 16.0, color: Colors.grey),
                      ),
                    ),
            ),
            Positioned(
              bottom: 30.0,
              right: 20.0,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == _numPages - 1) {
                    _completeWalkthrough();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBackgroundColor, // Setting the button background color
                  foregroundColor: Colors.white, // Setting the text color to white for both themes
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
                  _currentPage == _numPages - 1 ? 'Get Started' : 'Next',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WalkthroughPage extends StatelessWidget {
  final WalkthroughContent content;
  final bool isDarkMode;

  const WalkthroughPage({
    Key? key, 
    required this.content, 
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            isDarkMode ? content.darkImagePath : content.lightImagePath,
            height: MediaQuery.of(context).size.height * 0.35,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40.0),
          Text(
            content.title,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20.0),
          Text(
            content.description,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WalkthroughContent {
  final String title;
  final String description;
  final String lightImagePath;
  final String darkImagePath;

  WalkthroughContent({
    required this.title,
    required this.description,
    required this.lightImagePath,
    required this.darkImagePath,
  });
}