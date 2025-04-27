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
            "title": "Swift",
            "url":
                "https://www.programiz.com/swift-programming/online-compiler/"
          },
          {
            "title": "Kotlin",
            "url":
                "https://www.programiz.com/kotlin-programming/online-compiler/"
          },
          {
            "title": "Python",
            "url":
                "https://www.programiz.com/python-programming/online-compiler/"
          },
          {
            "title": "Java",
            "url": "https://www.programiz.com/java-programming/online-compiler/"
          },
          {
            "title": "JavaScript",
            "url": "https://www.programiz.com/javascript/online-compiler/"
          },
          {
            "title": "C++",
            "url": "https://www.programiz.com/cpp-programming/online-compiler/"
          },
          {
            "title": "C",
            "url": "https://www.programiz.com/c-programming/online-compiler/"
          },
          {
            "title": "PHP",
            "url": "https://www.programiz.com/php-programming/online-compiler/"
          },
          {
            "title": "SQL",
            "url": "https://www.programiz.com/sql/online-compiler/"
          },
          {
            "title": "TypeScript",
            "url": "https://www.programiz.com/typescript/online-compiler/"
          },
          {
            "title": "Rust",
            "url": "https://www.programiz.com/rust/online-compiler/"
          },
          {
            "title": "HTML",
            "url": "https://www.programiz.com/html/online-compiler/"
          },
          {"title": "R", "url": "https://www.programiz.com/r/online-compiler/"},
          {
            "title": "Go",
            "url": "https://www.programiz.com/golang/online-compiler/"
          },
          {"title": "Dart", "url": "https://dartpad.dev/"},
          {"title": "Scala", "url": "https://scastie.scala-lang.org/"},
          {"title": "Perl", "url": "https://onecompiler.com/perl"}
        ];

      case 'frameworks':
        return [
          {
            "title": "SwiftUI",
            "url": "https://developer.apple.com/xcode/swiftui/",
            "iconName": "swift"
          },
          {
            "title": "UIKit",
            "url": "https://developer.apple.com/documentation/uikit",
            "iconName": "iphone"
          },
          {
            "title": "Combine",
            "url": "https://developer.apple.com/documentation/combine/",
            "iconName": "link"
          },
          {
            "title": "CoreData",
            "url": "https://developer.apple.com/documentation/coredata",
            "iconName": "tray"
          },
          {
            "title": "Flutter",
            "url": "https://flutter.dev/",
            "iconName": "circle.grid.cross"
          },
          {
            "title": "React",
            "url": "https://reactjs.org/docs/getting-started.html",
            "iconName": "atom"
          },
          {
            "title": "React Native",
            "url": "https://reactnative.dev/docs/getting-started",
            "iconName": "app.badge"
          },
          {
            "title": "Angular",
            "url": "https://angular.io/docs",
            "iconName": "chevron.right"
          },
          {
            "title": "Vue.js",
            "url": "https://vuejs.org/guide/introduction.html",
            "iconName": "eye"
          },
          {
            "title": "Svelte",
            "url": "https://svelte.dev/docs",
            "iconName": "flame"
          },
          {
            "title": "Next.js",
            "url": "https://nextjs.org/docs",
            "iconName": "forward"
          },
          {
            "title": "Nuxt.js",
            "url": "https://nuxt.com/docs",
            "iconName": "arrow.up.right"
          },
          {
            "title": "Express",
            "url": "https://expressjs.com/",
            "iconName": "bolt"
          },
          {
            "title": "NestJS",
            "url": "https://docs.nestjs.com/",
            "iconName": "bolt.shield"
          },
          {
            "title": "Django",
            "url": "https://docs.djangoproject.com/en/stable/",
            "iconName": "book"
          },
          {
            "title": "Flask",
            "url": "https://flask.palletsprojects.com/",
            "iconName": "flask"
          },
          {
            "title": "FastAPI",
            "url": "https://fastapi.tiangolo.com/",
            "iconName": "bolt.horizontal"
          },
          {
            "title": "Rails",
            "url": "https://guides.rubyonrails.org/",
            "iconName": "cube"
          },
          {
            "title": "Laravel",
            "url": "https://laravel.com/docs",
            "iconName": "square.stack"
          },
          {
            "title": "Symfony",
            "url": "https://symfony.com/doc/current/index.html",
            "iconName": "circle"
          },
          {
            "title": "CodeIgniter",
            "url": "https://codeigniter.com/user_guide/",
            "iconName": "flame"
          },
          {
            "title": "Spring Boot",
            "url": "https://spring.io/projects/spring-boot",
            "iconName": "leaf"
          },
          {
            "title": "Spring",
            "url": "https://spring.io/projects/spring-framework",
            "iconName": "leaf.fill"
          },
          {
            "title": "Micronaut",
            "url": "https://docs.micronaut.io/latest/guide/",
            "iconName": "thermometer"
          },
          {
            "title": "Quarkus",
            "url": "https://quarkus.io/guides/",
            "iconName": "speedometer"
          },
          {
            "title": "ASP.NET",
            "url":
                "https://learn.microsoft.com/en-us/aspnet/core/?view=aspnetcore-7.0",
            "iconName": "dotnet"
          },
          {
            "title": ".NET",
            "url": "https://learn.microsoft.com/en-us/dotnet/",
            "iconName": "circlebadge"
          },
          {
            "title": "Electron",
            "url": "https://www.electronjs.org/docs",
            "iconName": "desktopcomputer"
          },
          {
            "title": "Capacitor",
            "url": "https://capacitorjs.com/docs",
            "iconName": "bolt.ring.closed"
          },
          {
            "title": "Ionic",
            "url": "https://ionicframework.com/docs",
            "iconName": "waveform"
          }
          // ...and so on for the rest
        ];

      case 'blogs':
        return [
          {"title": "GeeksforGeeks", "url": "https://www.geeksforgeeks.org"},
          {
            "title": "Medium - Programming",
            "url": "https://medium.com/topic/programming"
          },
          {"title": "Dev.to", "url": "https://dev.to"},
          {"title": "Stack Overflow Blog", "url": "https://stackoverflow.blog"},
          {"title": "Hackernoon", "url": "https://hackernoon.com"},
          {"title": "Hashnode", "url": "https://hashnode.com"},
          {
            "title": "Towards Data Science",
            "url": "https://towardsdatascience.com"
          },
          {"title": "freeCodeCamp", "url": "https://www.freecodecamp.org/news"},
          {
            "title": "Smashing Magazine",
            "url": "https://www.smashingmagazine.com"
          },
          {"title": "CSS-Tricks", "url": "https://css-tricks.com"},
          {"title": "CodeProject", "url": "https://www.codeproject.com"},
          {"title": "Scotch.io", "url": "https://scotch.io"},
          {"title": "SitePoint", "url": "https://www.sitepoint.com"},
          {
            "title": "Reddit - Programming",
            "url": "https://www.reddit.com/r/programming/"
          },
          {"title": "Lobsters", "url": "https://lobste.rs"},
          {"title": "Codedamn", "url": "https://codedamn.com"},
          {"title": "RayWenderlich", "url": "https://www.raywenderlich.com"},
          {"title": "iOS Dev Weekly", "url": "https://iosdevweekly.com"},
          {
            "title": "Android Developers Blog",
            "url": "https://android-developers.googleblog.com"
          },
          {
            "title": "Google Developers Blog",
            "url": "https://developers.googleblog.com"
          },
          {
            "title": "Microsoft Developer Blog",
            "url": "https://devblogs.microsoft.com"
          },
          {"title": "GitHub Blog", "url": "https://github.blog"},
          {"title": "Netflix TechBlog", "url": "https://netflixtechblog.com"},
          {"title": "Uber Engineering", "url": "https://eng.uber.com"},
          {
            "title": "Airbnb Engineering",
            "url": "https://medium.com/airbnb-engineering"
          },
          {"title": "Dropbox Tech Blog", "url": "https://dropbox.tech"},
          {
            "title": "Facebook Engineering",
            "url": "https://engineering.fb.com"
          },
          {
            "title": "Twitter Engineering",
            "url": "https://blog.twitter.com/engineering"
          },
          {
            "title": "Pinterest Engineering",
            "url": "https://medium.com/@Pinterest_Engineering"
          },
          {
            "title": "Spotify Engineering",
            "url": "https://engineering.atspotify.com"
          },
          {
            "title": "LinkedIn Engineering",
            "url": "https://engineering.linkedin.com/blog"
          },
          {"title": "Slack Engineering", "url": "https://slack.engineering"},
          {"title": "Stripe Engineering", "url": "https://stripe.com/blog"},
          {
            "title": "Shopify Engineering",
            "url": "https://shopify.engineering/"
          },
          {"title": "Google AI Blog", "url": "https://ai.googleblog.com"},
          {
            "title": "AWS Compute Blog",
            "url": "https://aws.amazon.com/blogs/compute"
          },
          {
            "title": "Azure Blog",
            "url": "https://azure.microsoft.com/en-us/blog"
          },
          {
            "title": "Khan Academy Engineering",
            "url": "https://engineering.khanacademy.org"
          },
          {"title": "Mozilla Hacks", "url": "https://hacks.mozilla.org"},
          {"title": "Elastic Blog", "url": "https://www.elastic.co/blog"},
          {
            "title": "DigitalOcean Community",
            "url": "https://www.digitalocean.com/community/tutorials"
          },
          {"title": "JetBrains Blog", "url": "https://blog.jetbrains.com"},
          {"title": "Twilio Blog", "url": "https://www.twilio.com/blog"},
          {"title": "Heroku Blog", "url": "https://blog.heroku.com"},
          {
            "title": "Red Hat Developer Blog",
            "url": "https://developers.redhat.com/blog"
          },
          {"title": "HashiCorp Blog", "url": "https://www.hashicorp.com/blog"},
          {"title": "Okta Developer Blog", "url": "https://developer.okta.com"},
          {"title": "Cloudflare Blog", "url": "https://blog.cloudflare.com"},
          {"title": "GitLab Blog", "url": "https://about.gitlab.com/blog"},
          {
            "title": "NVIDIA Developer Blog",
            "url": "https://developer.nvidia.com/blog"
          },
          {
            "title": "Salesforce Engineering",
            "url": "https://engineering.salesforce.com"
          },
          {"title": "Docker Blog", "url": "https://www.docker.com/blog"},
          {"title": "Hashnode Dev Blog", "url": "https://hashnode.com"},
          {"title": "Scala Blog", "url": "https://www.scala-lang.org/blog"},
          {"title": "Go Blog", "url": "https://blog.golang.org"},
          {"title": "Rust Blog", "url": "https://blog.rust-lang.org"},
          {
            "title": "Python Software Foundation Blog",
            "url": "https://pyfound.blogspot.com"
          },
          {"title": "Ruby Inside", "url": "https://www.rubyinside.com"},
          {"title": "PHP Developer Blog", "url": "https://phpdeveloper.org"},
          {"title": "Node.js Blog", "url": "https://nodejs.org/en/blog"},
          {"title": "React Blog", "url": "https://reactjs.org/blog"},
          {"title": "Vue.js Blog", "url": "https://blog.vuejs.org"},
          {"title": "Angular Blog", "url": "https://blog.angular.io"},
          {"title": "Svelte Blog", "url": "https://svelte.dev/blog"},
          {
            "title": "Django Blog",
            "url": "https://www.djangoproject.com/weblog"
          },
          {
            "title": "Flask Blog",
            "url": "https://flask.palletsprojects.com/en/latest/blog"
          },
          {"title": "TensorFlow Blog", "url": "https://blog.tensorflow.org"},
          {"title": "Kubernetes Blog", "url": "https://kubernetes.io/blog"},
          {"title": "Ansible Blog", "url": "https://www.ansible.com/blog"},
          {"title": "Terraform Blog", "url": "https://www.terraform.io/blog"},
          {"title": "Jenkins Blog", "url": "https://www.jenkins.io/blog"},
          {
            "title": "Apache Kafka Blog",
            "url": "https://kafka.apache.org/blog"
          },
          {
            "title": "ElasticSearch Blog",
            "url": "https://www.elastic.co/blog/category/elasticsearch"
          },
          {"title": "MongoDB Blog", "url": "https://www.mongodb.com/blog"},
          {
            "title": "PostgreSQL Blog",
            "url": "https://www.postgresql.org/about/news"
          },
          {"title": "MySQL Blog", "url": "https://mysqlserverteam.com"},
          {"title": "Redis Blog", "url": "https://redis.com/blog"},
          {
            "title": "Apache Spark Blog",
            "url": "https://databricks.com/blog/category/apache-spark"
          },
          {"title": "Hacker News", "url": "https://news.ycombinator.com"},
          {"title": "TechCrunch", "url": "https://techcrunch.com"},
          {"title": "The Verge", "url": "https://www.theverge.com"},
          {"title": "Wired", "url": "https://www.wired.com"},
          {"title": "Ars Technica", "url": "https://arstechnica.com"},
          {"title": "Engadget", "url": "https://www.engadget.com"},
          {"title": "VentureBeat", "url": "https://venturebeat.com"},
          {"title": "ZDNet", "url": "https://www.zdnet.com"},
          {"title": "InfoWorld", "url": "https://www.infoworld.com"},
          {"title": "Slashdot", "url": "https://slashdot.org"},
          {"title": "CodePen Blog", "url": "https://blog.codepen.io"},
          {"title": "SitePoint PHP", "url": "https://www.sitepoint.com/php"},
          {"title": "Codrops", "url": "https://tympanus.net/codrops"},
          {
            "title": "Tutorialspoint",
            "url": "https://www.tutorialspoint.com/blog"
          },
          {
            "title": "Scotch.io Tutorials",
            "url": "https://scotch.io/tutorials"
          },
          {"title": "Envato Tuts+", "url": "https://tutsplus.com"},
          {
            "title": "CSS-Tricks Almanac",
            "url": "https://css-tricks.com/almanac"
          },
          {
            "title": "SitePoint JavaScript",
            "url": "https://www.sitepoint.com/javascript"
          },
          {
            "title": "Smashing Magazine CSS",
            "url": "https://www.smashingmagazine.com/category/css"
          },
          {"title": "A List Apart", "url": "https://alistapart.com"},
          {"title": "David Walsh Blog", "url": "https://davidwalsh.name"},
          {"title": "Paul Irish Blog", "url": "https://paulirish.com"},
          {"title": "Addy Osmani Blog", "url": "https://addyosmani.com/blog"},
          {"title": "Jake Archibald Blog", "url": "https://jakearchibald.com"},
          {"title": "Codementor Blog", "url": "https://www.codementor.io/blog"},
          {"title": "Dev.to Community", "url": "https://dev.to/t"},
          {"title": "Hashnode Community", "url": "https://hashnode.com"},
          {
            "title": "Medium Programming",
            "url": "https://medium.com/topic/programming"
          }
        ];

      case 'documention':
        return [
          {
    "title": "Swift",
    "url": "https://swift.org/documentation/",
    "iconName": "swift"
  },
  {
    "title": "Kotlin",
    "url": "https://kotlinlang.org/docs/home.html",
    "iconName": "k.circle"
  },
  {
    "title": "Python",
    "url": "https://docs.python.org/3/",
    "iconName": "p.circle"
  },
  {
    "title": "Java",
    "url": "https://docs.oracle.com/en/java/",
    "iconName": "j.circle"
  },
  {
    "title": "JavaScript",
    "url": "https://developer.mozilla.org/en-US/docs/Web/JavaScript",
    "iconName": "safari"
  },
  {
    "title": "C++",
    "url": "https://en.cppreference.com/w/",
    "iconName": "c.circle"
  },
  {
    "title": "C#",
    "url": "https://learn.microsoft.com/en-us/dotnet/csharp/",
    "iconName": "number.circle"
  },
  {
    "title": "Go",
    "url": "https://pkg.go.dev/std",
    "iconName": "g.circle"
  },
  {
    "title": "Rust",
    "url": "https://doc.rust-lang.org/book/",
    "iconName": "r.circle"
  },
  {
    "title": "Ruby",
    "url": "https://www.ruby-lang.org/en/documentation/",
    "iconName": "r.square"
  },
  {
    "title": "PHP",
    "url": "https://www.php.net/docs.php",
    "iconName": "p.square"
  },
  {
    "title": "HTML",
    "url": "https://developer.mozilla.org/en-US/docs/Web/HTML",
    "iconName": "curlybraces"
  },
  {
    "title": "CSS",
    "url": "https://developer.mozilla.org/en-US/docs/Web/CSS",
    "iconName": "paintbrush"
  },
  {
    "title": "TypeScript",
    "url": "https://www.typescriptlang.org/docs/",
    "iconName": "doc.richtext"
  },
  {
    "title": "SQL",
    "url": "https://www.w3schools.com/sql/",
    "iconName": "tablecells"
  },
  {
    "title": "Dart",
    "url": "https://dart.dev/guides",
    "iconName": "d.circle"
  },
  {
    "title": "Scala",
    "url": "https://docs.scala-lang.org/",
    "iconName": "s.circle"
  },
  {
    "title": "Perl",
    "url": "https://perldoc.perl.org/",
    "iconName": "doc.text"
  },
  {
    "title": "R",
    "url": "https://cran.r-project.org/manuals.html",
    "iconName": "r.circle.fill"
  },
  {
    "title": "Elixir",
    "url": "https://elixir-lang.org/learning.html",
    "iconName": "e.circle"
  },
  {
    "title": "Haskell",
    "url": "https://www.haskell.org/documentation/",
    "iconName": "h.circle"
  },
  {
    "title": "Lua",
    "url": "https://www.lua.org/manual/5.4/",
    "iconName": "l.circle"
  },
  {
    "title": "Clojure",
    "url": "https://clojure.org/guides/learn",
    "iconName": "c.circle.fill"
  },
  {
    "title": "F#",
    "url": "https://learn.microsoft.com/en-us/dotnet/fsharp/",
    "iconName": "f.circle"
  },
  {
    "title": "Assembly",
    "url": "https://cs.lmu.edu/~ray/notes/asm/",
    "iconName": "a.circle"
  },
  {
    "title": "COBOL",
    "url": "https://www.ibm.com/docs/en/cobol-zos/6.3",
    "iconName": "c.square"
  },
  {
    "title": "Objective-C",
    "url": "https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html",
    "iconName": "o.circle"
  },
  {
    "title": "Shell",
    "url": "https://www.gnu.org/software/bash/manual/",
    "iconName": "terminal"
  },
  {
    "title": "MATLAB",
    "url": "https://www.mathworks.com/help/matlab/",
    "iconName": "m.circle"
  }
        ];

      case 'documents':
        return [
          {
            "title": "Swift",
            "url": "https://swift.org/documentation/",
            "iconName": "swift"
          },
          {
            "title": "Kotlin",
            "url": "https://kotlinlang.org/docs/home.html",
            "iconName": "k.circle"
          },
          {
            "title": "Python",
            "url": "https://docs.python.org/3/",
            "iconName": "p.circle"
          },
          {
            "title": "Java",
            "url": "https://docs.oracle.com/en/java/",
            "iconName": "j.circle"
          },
          {
            "title": "JavaScript",
            "url": "https://developer.mozilla.org/en-US/docs/Web/JavaScript",
            "iconName": "safari"
          },
          {
            "title": "C++",
            "url": "https://en.cppreference.com/w/",
            "iconName": "c.circle"
          },
          {
            "title": "C#",
            "url": "https://learn.microsoft.com/en-us/dotnet/csharp/",
            "iconName": "number.circle"
          },
          {
            "title": "Go",
            "url": "https://pkg.go.dev/std",
            "iconName": "g.circle"
          },
          {
            "title": "Rust",
            "url": "https://doc.rust-lang.org/book/",
            "iconName": "r.circle"
          },
          {
            "title": "Ruby",
            "url": "https://www.ruby-lang.org/en/documentation/",
            "iconName": "r.square"
          },
          {
            "title": "PHP",
            "url": "https://www.php.net/docs.php",
            "iconName": "p.square"
          },
          {
            "title": "HTML",
            "url": "https://developer.mozilla.org/en-US/docs/Web/HTML",
            "iconName": "curlybraces"
          },
          {
            "title": "CSS",
            "url": "https://developer.mozilla.org/en-US/docs/Web/CSS",
            "iconName": "paintbrush"
          },
          {
            "title": "TypeScript",
            "url": "https://www.typescriptlang.org/docs/",
            "iconName": "doc.richtext"
          },
          {
            "title": "SQL",
            "url": "https://www.w3schools.com/sql/",
            "iconName": "tablecells"
          },
          {
            "title": "Dart",
            "url": "https://dart.dev/guides",
            "iconName": "d.circle"
          },
          {
            "title": "Scala",
            "url": "https://docs.scala-lang.org/",
            "iconName": "s.circle"
          },
          {
            "title": "Perl",
            "url": "https://perldoc.perl.org/",
            "iconName": "doc.text"
          },
          {
            "title": "R",
            "url": "https://cran.r-project.org/manuals.html",
            "iconName": "r.circle.fill"
          },
          {
            "title": "Elixir",
            "url": "https://elixir-lang.org/learning.html",
            "iconName": "e.circle"
          },
          {
            "title": "Haskell",
            "url": "https://www.haskell.org/documentation/",
            "iconName": "h.circle"
          },
          {
            "title": "Lua",
            "url": "https://www.lua.org/manual/5.4/",
            "iconName": "l.circle"
          },
          {
            "title": "Clojure",
            "url": "https://clojure.org/guides/learn",
            "iconName": "c.circle.fill"
          },
          {
            "title": "F#",
            "url": "https://learn.microsoft.com/en-us/dotnet/fsharp/",
            "iconName": "f.circle"
          },
          {
            "title": "COBOL",
            "url": "https://www.ibm.com/docs/en/cobol-zos/6.3",
            "iconName": "c.square"
          },
          {
            "title": "Objective-C",
            "url":
                "https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html",
            "iconName": "o.circle"
          },
          {
            "title": "Shell",
            "url": "https://www.gnu.org/software/bash/manual/",
            "iconName": "terminal"
          },
          {
            "title": "MATLAB",
            "url": "https://www.mathworks.com/help/matlab/",
            "iconName": "m.circle"
          }
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
