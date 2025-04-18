import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'web_view_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino package

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final PageStorageBucket _bucket =
      PageStorageBucket(); // Add PageStorageBucket

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadRecentSearches(); // Load saved searches

    // Add a listener to clear results when the search box is cleared
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() {
          _results = [];
          print('Results cleared');
        });
      }
    });
  }

  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false;
  String _currentQuery = '';
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final String apiKey = 'b62e917e139b31e288bef54255f46a2cb7b9c75b';
  final List<String> _pastSearches = []; // List to store past searches

  Future<void> _search(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _results = [];
      _currentQuery = query;

      if (!_pastSearches.contains(query)) {
        _pastSearches.insert(0, query);
        if (_pastSearches.length > 20) {
          _pastSearches.removeLast();
        }
        _saveRecentSearches(); // Save to SharedPreferences
      }
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

  void _confirmClearAll() {
    if (_pastSearches.isEmpty) {
      // Show iOS-style alert if there are no recent searches
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('No Recent Searches'),
            content: const Text('You don’t have any search results to clear.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'OpenSauce', // Use the app's font style
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Show iOS-style confirmation dialog to clear all results
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Clear All Results'),
            content: const Text('Are you sure you want to clear all results?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'OpenSauce', // Use the app's font style
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  _clearPastSearches(); // Clear all results
                  Navigator.of(context).pop(); // Close the dialog
                },
                isDestructiveAction: true, // Highlight destructive action
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontFamily: 'OpenSauce', // Use the app's font style
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red, // Red for destructive action
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _clearPastSearches() async {
    setState(() {
      _pastSearches.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recentSearches');
  }

  void _removeSearch(String search) {
    setState(() {
      _pastSearches.remove(search); // Remove the specific search query
      _saveRecentSearches(); // Save recent searches to SharedPreferences
    });
  }

  // Save recent searches to SharedPreferences
  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentSearches', _pastSearches);
  }

  // Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSearches = prefs.getStringList('recentSearches');
    if (savedSearches != null) {
      setState(() {
        _pastSearches.addAll(savedSearches);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: _bucket, // Attach the bucket to the PageStorage
      child: Scaffold(
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSearchBox(),
                const SizedBox(height: 16),
                _buildRecentSearches(),
                const SizedBox(height: 24),
                _buildSearchResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[200],
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
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
          fontFamily: 'OpenSauce',
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Search anything...',
          hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
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
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSauce',
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            TextButton(
              onPressed: _confirmClearAll,
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'OpenSauce',
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_pastSearches.isEmpty)
          Center(
            child: Text(
              'No recent searches',
              style: TextStyle(
                fontFamily: 'OpenSauce',
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _pastSearches.map((search) {
              return GestureDetector(
                onTap: () {
                  _controller.text = search;
                  _search(search);
                },
                child: Chip(
                  labelPadding: const EdgeInsets.only(right: 8),
                  label: Text(
                    search,
                    style: TextStyle(
                      fontFamily: 'OpenSauce',
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  deleteIcon: Icon(
                    Icons.close,
                    size: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  onDeleted: () {
                    _removeSearch(search);
                  },
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[300],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Expanded(
            child: ListView.builder(
              key: const PageStorageKey('searchResults'), // Use PageStorageKey
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.white,
                  child: ListTile(
                    title: Text(
                      item['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'OpenSauce',
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      item['snippet'],
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[700],
                        fontFamily: 'OpenSauce',
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => _openLink(item['link'], item['title']),
                  ),
                );
              },
            ),
          );
  }
}
