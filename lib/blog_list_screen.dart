import 'package:flutter/material.dart';
import 'web_view_screen.dart';

class BlogListScreen extends StatefulWidget {
  final String title;
  const BlogListScreen({super.key, required this.title});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> items = [];
  Set<String> favorites = {};

  @override
  void initState() {
    super.initState();
    // Initialize items based on the category
    items = getItemsForCategory(widget.title);
    updateFilteredItems();
    _searchController.addListener(_filterItems);
  }

  List<Map<String, dynamic>> getItemsForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'compiler':
        return [
          {
            "title": "Online Python Compiler",
            "visits": "1x",
            "url":
                "https://www.programiz.com/python-programming/online-compiler/"
          },
          {
            "title": "Java Compiler",
            "url": "https://www.programiz.com/java-programming/online-compiler/"
          },
          {
            "title": "C++ Online IDE",
            "url": "https://www.programiz.com/cpp-programming/online-compiler/"
          },
          {"title": "JavaScript Console", "url": "https://jsconsole.com/"},
          {"title": "Kotlin Playground", "url": "https://play.kotlinlang.org/"},
          {
            "title": "Swift Online Compiler",
            "url":
                "https://www.programiz.com/swift-programming/online-compiler/"
          },
          {"title": "Rust Playground", "url": "https://play.rust-lang.org/"},
          {"title": "Go Playground", "url": "https://go.dev/play/"},
        ];
      case 'classes':
        return [
          {
            "title": "Flutter Development",
            "visits": "1x",
            "url": "https://flutter.dev/learn"
          },
          {
            "title": "React Native Masterclass",
            "url": "https://reactnative.dev/docs/getting-started"
          },
          {
            "title": "Python for Beginners",
            "url": "https://www.python.org/about/gettingstarted/"
          },
          {"title": "Advanced JavaScript", "url": "https://javascript.info/"},
          {
            "title": "Data Structures & Algorithms",
            "url": "https://www.geeksforgeeks.org/data-structures/"
          },
          {
            "title": "Machine Learning Basics",
            "url": "https://www.tensorflow.org/learn"
          },
          {
            "title": "Web Development Bootcamp",
            "url": "https://www.w3schools.com/"
          },
          {
            "title": "Mobile App Development",
            "url": "https://developer.android.com/courses"
          },
        ];
      case 'projects':
        return [
          {
            "title": "Todo App with Flutter",
            "visits": "1x",
            "url": "https://flutter.dev/docs/cookbook"
          },
          {"title": "Weather App", "url": "https://openweathermap.org/guide"},
          {
            "title": "Chat Application",
            "url": "https://firebase.google.com/docs/cloud-messaging"
          },
          {
            "title": "E-commerce Platform",
            "url": "https://stripe.com/docs/development"
          },
          {
            "title": "Social Media Clone",
            "url": "https://firebase.google.com/docs/auth"
          },
          {"title": "Blog Platform", "url": "https://medium.com/"},
          {
            "title": "Portfolio Website",
            "url": "https://github.com/topics/portfolio-website"
          },
          {"title": "Game Development", "url": "https://unity.com/learn"},
        ];
      case 'community':
        return [
          {
            "title": "Stack Overflow",
            "visits": "1x",
            "url": "https://stackoverflow.com/"
          },
          {
            "title": "GitHub Discussions",
            "url": "https://github.com/discussions"
          },
          {
            "title": "Reddit Programming",
            "url": "https://www.reddit.com/r/programming/"
          },
          {"title": "Dev.to Community", "url": "https://dev.to/"},
          {"title": "Flutter Discord", "url": "https://discord.gg/flutter"},
          {
            "title": "React Native Community",
            "url": "https://reactnative.dev/community/overview"
          },
          {
            "title": "Python Developers Group",
            "url": "https://www.python.org/community/"
          },
          {
            "title": "CodeNewbie Community",
            "url": "https://community.codenewbie.org/"
          },
        ];
      default:
        return [];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void updateFilteredItems() {
    if (_selectedTabIndex == 2) {
      // Favorites tab
      filteredItems =
          items.where((item) => favorites.contains(item["title"])).toList();
    } else {
      filteredItems = List.from(items);
    }
    _filterItems();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (_selectedTabIndex == 2) {
        // Favorites tab
        filteredItems = items
            .where(
              (item) =>
                  favorites.contains(item["title"]) &&
                  (query.isEmpty ||
                      item["title"].toString().toLowerCase().contains(
                            query,
                          )),
            )
            .toList();
      } else if (query.isEmpty) {
        filteredItems = List.from(items);
      } else {
        filteredItems = items
            .where(
              (item) => item["title"].toString().toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  void toggleFavorite(String title) {
    setState(() {
      if (favorites.contains(title)) {
        favorites.remove(title);
      } else {
        favorites.add(title);
      }
      updateFilteredItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Tab buttons
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildTabButton("A-Z", 0, Icons.sort_by_alpha),
                        _buildTabButton("Recents", 1, Icons.history),
                        _buildTabButton("Favorites", 2, Icons.favorite),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Search ${widget.title}...",
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // List of items
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      _selectedTabIndex == 2
                          ? 'No favorites yet'
                          : 'No results found',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isFavorite = favorites.contains(item["title"]);

                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? Colors.grey[900]!
                                  : Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewScreen(
                                  title: item["title"],
                                  url: item["url"],
                                ),
                              ),
                            );
                          },
                          title: Text(
                            item["title"],
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item["visits"] != null)
                                Text(
                                  item["visits"],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                ),
                                onPressed: () => toggleFavorite(item["title"]),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            updateFilteredItems();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? isDark
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: isDark ? Colors.blue.withOpacity(0.5) : Colors.blue,
                    width: 1.5,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? isDark
                        ? Colors.blue
                        : Colors.blue[700]
                    : isDark
                        ? Colors.grey[400]
                        : Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected
                      ? isDark
                          ? Colors.blue
                          : Colors.blue[700]
                      : isDark
                          ? Colors.grey[400]
                          : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
