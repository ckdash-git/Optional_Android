import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'web_view_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false;
  String _currentQuery = '';
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final String apiKey = 'b62e917e139b31e288bef54255f46a2cb7b9c75b';

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _results = [];
      _currentQuery = query;
    });

    final url = Uri.parse('https://google.serper.dev/search');
    final headers = {'X-API-KEY': apiKey, 'Content-Type': 'application/json'};
    final body = json.encode({'q': query, 'num': 3});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _results = data['organic'] ?? [];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      debugPrint("Failed to fetch results: ${response.statusCode}");
    }
  }

  Future<void> _listen() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) return;

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('Status: $val'),
        onError: (val) => print('Error: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            _controller.text = val.recognizedWords;
            if (val.finalResult) {
              setState(() => _isListening = false);
              _speech.stop();
            }
            if (val.hasConfidenceRating && val.confidence > 0) {
              _search(val.recognizedWords); // Optional auto search
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _showMoreResults() async {
    final googleSearchUrl =
        'https://www.google.com/search?q=${Uri.encodeComponent(_currentQuery)}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WebViewScreen(url: googleSearchUrl, title: 'Search Results'),
      ),
    );
  }

  void _openLink(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSauce',
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  onSubmitted: _search,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'OpenSauce',
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search anything...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: 'OpenSauce',
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        color: Colors.grey,
                      ),
                      onPressed: _listen,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final item = _results[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  color:
                                      isDark ? Colors.grey[850] : Colors.white,
                                  child: ListTile(
                                    title: Text(
                                      item['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        fontFamily: 'OpenSauce',
                                        color: textColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      item['snippet'],
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[700],
                                        fontFamily: 'OpenSauce',
                                        fontSize: 14,
                                      ),
                                    ),
                                    onTap: () =>
                                        _openLink(item['link'], item['title']),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (_results.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                onPressed: _showMoreResults,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  backgroundColor:
                                      isDark ? Colors.blue[400] : Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Show More Results',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'OpenSauce',
                                  ),
                                ),
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
}
