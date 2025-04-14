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

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
            updateNavigationState();
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            updateNavigationState();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> updateNavigationState() async {
    final canNavigateBack = await controller.canGoBack();
    final canNavigateForward = await controller.canGoForward();

    if (mounted) {
      setState(() {
        canGoBack = canNavigateBack;
        canGoForward = canNavigateForward;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.blue,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: isDark ? Colors.white : Colors.blue,
              ),
              onPressed: () {
                controller.reload();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 65,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavigationButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: canGoBack
                        ? () {
                            controller.goBack();
                            updateNavigationState();
                          }
                        : null,
                    isDark: isDark,
                    tooltip: 'Back',
                  ),
                  _buildNavigationButton(
                    icon: Icons.arrow_forward_ios,
                    onPressed: canGoForward
                        ? () {
                            controller.goForward();
                            updateNavigationState();
                          }
                        : null,
                    isDark: isDark,
                    tooltip: 'Forward',
                  ),
                  _buildNavigationButton(
                    icon: Icons.close,
                    onPressed: () => _showExitDialog(context, isDark),
                    isDark: isDark,
                    tooltip: 'Close',
                    isExit: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showExitDialog(BuildContext context, bool isDark) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.exit_to_app_rounded,
                  size: 40,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Exit Page',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to exit?',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? Colors.grey[800] : Colors.grey[200],
                        foregroundColor: isDark ? Colors.white : Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(100, 45),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Exit WebView
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(100, 45),
                      ),
                      child: const Text(
                        'Exit',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
    required String tooltip,
    bool isExit = false,
  }) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isEnabled
                  ? isExit
                      ? (isDark
                          ? Colors.red.withOpacity(0.2)
                          : Colors.red.withOpacity(0.1))
                      : (isDark
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.1))
                  : Colors.transparent,
              border: Border.all(
                color: isEnabled
                    ? isExit
                        ? (isDark
                            ? Colors.red.withOpacity(0.3)
                            : Colors.red.withOpacity(0.2))
                        : (isDark
                            ? Colors.blue.withOpacity(0.3)
                            : Colors.blue.withOpacity(0.2))
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: isEnabled
                  ? isExit
                      ? Colors.red[400]
                      : (isDark ? Colors.blue : Colors.blue[700])
                  : isDark
                      ? Colors.grey[600]
                      : Colors.grey[400],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
