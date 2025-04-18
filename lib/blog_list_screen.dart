import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<Map<String, dynamic>> recentItems = [];
  Set<String> favorites = {};
  Map<String, int> visitCounts = {};

  @override
  void initState() {
    super.initState();
    items = getItemsForCategory(widget.title);
    _loadFavorites(); // Load favorites from SharedPreferences
    // Initialize visit counts from existing items
    for (var item in items) {
      if (item["visits"] != null) {
        String visitsStr = item["visits"].toString();
        int count = int.tryParse(visitsStr.replaceAll('x', '')) ?? 0;
        visitCounts[item["title"]] = count;
      } else {
        visitCounts[item["title"]] = 0;
      }
    }
    updateFilteredItems();
    _searchController.addListener(_filterItems);
  }

  List<Map<String, dynamic>> getItemsForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'compiler':
        return [
          {
            "title": "Online Python Compiler",
            // "visits": "1x",
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
          {
            "title": "Online C Compiler",
            "url": "https://www.programiz.com/c-programming/online-compiler/"
          },
          {
            "title": "PHP Online Compiler",
            "url": "https://www.programiz.com/php-programming/online-compiler/"
          },
          {
            "title": "Ruby Online Compiler",
            "url": "https://www.programiz.com/ruby-programming/online-compiler/"
          },
          {
            "title": "C# Online Compiler",
            "url":
                "https://www.programiz.com/csharp-programming/online-compiler/"
          },
          {"title": "HTML Editor", "url": "https://www.w3schools.com/html/"},
          {
            "title": "CSS Editor",
            "url":
                "https://www.w3schools.com/css/tryit.asp?filename=trycss_default"
          },
          {
            "title": "JavaScript Editor",
            "url":
                "https://www.w3schools.com/js/tryit.asp?filename=tryjs_default"
          },
          {"title": "DartPad", "url": "https://dartpad.dev/"},
          {"title": "PHP Fiddle", "url": "https://phpfiddle.org/"},
          {"title": "CodePen", "url": "https://codepen.io/"},
          {"title": "JSFiddle", "url": "https://jsfiddle.net/"},
          {"title": "Replit", "url": "https://replit.com/"},
          {"title": "Glitch", "url": "https://glitch.com/"},
          {"title": "CodeSandbox", "url": "https://codesandbox.io/"},
          {"title": "JSBin", "url": "https://jsbin.com/"},
          {"title": "JavaScript Console", "url": "https://jsconsole.com/"},
          {"title": "Kotlin Playground", "url": "https://play.kotlinlang.org/"},
          {
            "title": "Swift Online Compiler",
            "url": "https://www.programiz.com/swift/online-compiler/"
          },
          {"title": "Rust Playground", "url": "https://play.rust-lang.org/"},
          {"title": "Go Playground", "url": "https://go.dev/play/"},
        ];
      case 'classes':
        return [
          {
            "title": "Flutter Development",
            // "visits": "1x",
            "url": "https://flutter.dev/learn"
          },
          {
            "title": "React Native Masterclass",
            "url": "https://reactnative.dev/docs/getting-started"
          },
          {
            "title": "JAVA Class for Beginners",
            "url": "https://www.geeksforgeeks.org/classes-objects-java/"
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
      case 'blogs':
        return [
          {
            "title": "Todo App with Flutter",
            // "visits": "1x",
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
          {"title": "Medium", "url": "https://medium.com/"},
        ];
      case 'community':
        return [
          {
            "title": "Stack Overflow",
            // "visits": "1x",
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

  void addToRecent(Map<String, dynamic> item) {
    setState(() {
      recentItems.removeWhere((element) => element["title"] == item["title"]);

      recentItems.insert(0, Map<String, dynamic>.from(item));

      if (recentItems.length > 10) {
        recentItems.removeLast();
      }

      if (_selectedTabIndex == 1) {
        updateFilteredItems();
      }
    });
  }

  void updateFilteredItems() {
    setState(() {
      final query = _searchController.text.toLowerCase();

      // First, get the base list according to the selected tab
      List<Map<String, dynamic>> baseList;
      if (_selectedTabIndex == 1) {
        // Recent tab
        baseList = List.from(recentItems);
      } else if (_selectedTabIndex == 2) {
        // Favorites tab
        baseList =
            items.where((item) => favorites.contains(item["title"])).toList();
      } else {
        // A-Z tab
        baseList = List.from(items);
        baseList.sort(
            (a, b) => a["title"].toString().compareTo(b["title"].toString()));
      }

      // Then apply search filter if there's a query
      if (query.isEmpty) {
        filteredItems = baseList;
      } else {
        filteredItems = baseList
            .where((item) =>
                item["title"].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _filterItems() {
    updateFilteredItems();
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', favorites.toList());
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      favorites = savedFavorites.toSet();
    });
    updateFilteredItems();
  }

  void toggleFavorite(String title) {
    setState(() {
      if (favorites.contains(title)) {
        favorites.remove(title);
      } else {
        favorites.add(title);
      }
      _saveFavorites(); // Save updated favorites to SharedPreferences
      updateFilteredItems();
    });
  }

  void updateVisitCount(String title) {
    setState(() {
      visitCounts[title] = (visitCounts[title] ?? 0) + 1;
      // Update the visits count in the items list
      for (var item in items) {
        if (item["title"] == title) {
          item["visits"] = "${visitCounts[title]}x";
        }
      }
      // Update the visits count in recent items
      for (var item in recentItems) {
        if (item["title"] == title) {
          item["visits"] = "${visitCounts[title]}x";
        }
      }
      // Update the visits count in filtered items
      for (var item in filteredItems) {
        if (item["title"] == title) {
          item["visits"] = "${visitCounts[title]}x";
        }
      }
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
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton("A-Z", 0),
                      _buildTabButton("Recents", 1),
                      _buildTabButton("Favorites", 2),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      _selectedTabIndex == 1
                          ? 'No recent visits'
                          : _selectedTabIndex == 2
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
                            addToRecent(item);
                            updateVisitCount(item["title"]);
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
                              Text(
                                "${visitCounts[item["title"]] ?? 0}x",
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

  Widget _buildTabButton(String text, int index) {
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? isDark
                    ? Colors.grey[800]
                    : Colors.white
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? isDark
                      ? Colors.white
                      : Colors.black
                  : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
