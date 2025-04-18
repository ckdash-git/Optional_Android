import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool canGoBack = false;
  bool canGoForward = false;
  bool showNavigationBar = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.144 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              showNavigationBar = false;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              isLoading = false;
              showNavigationBar = true;
            });
            await updateNavigationState();
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> updateNavigationState() async {
    final back = await controller.canGoBack();
    final forward = await controller.canGoForward();
    setState(() {
      canGoBack = back;
      canGoForward = forward;
    });
  }

  Future<void> _onBackPressed() async {
    if (await controller.canGoBack()) {
      await controller.goBack();
      await updateNavigationState();
    } else {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  Future<void> _onForwardPressed() async {
    if (await controller.canGoForward()) {
      await controller.goForward();
      await updateNavigationState();
    }
  }

  void _onExitPressed() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          title: Text(
            'Exit Web View',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: 'OpenSauce',
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to exit?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'OpenSauce',
              color: isDark ? Colors.grey[300] : Colors.black87,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 17,
                        fontFamily: 'OpenSauce',
                      ),
                    ),
                  ),
                ),
                Container(width: 0.5, height: 44, color: Colors.grey),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                      Navigator.of(context).pop(); // close screen
                    },
                    child: Text(
                      'Exit',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'OpenSauce',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Always return false to disable the back button functionality
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 40), // Add margin from the top
              child: WebViewWidget(controller: controller),
            ),
            if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
        bottomNavigationBar: showNavigationBar
            ? SafeArea(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _navIcon(
                          icon: Icons.arrow_back_ios_new,
                          onPressed: canGoBack ? _onBackPressed : null,
                          tooltip: 'Back',
                          color: Colors.blue,
                        ),
                        _navIcon(
                          icon: Icons.arrow_forward_ios,
                          onPressed: canGoForward ? _onForwardPressed : null,
                          tooltip: 'Forward',
                          color: Colors.blue,
                        ),
                        _navIcon(
                          icon: Icons.close,
                          onPressed: _onExitPressed,
                          tooltip: 'Exit',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _navIcon({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        color: onPressed != null ? color : Colors.grey,
      ),
    );
  }
}