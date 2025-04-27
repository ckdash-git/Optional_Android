import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferalScreen extends StatefulWidget {
  const ReferalScreen({super.key});

  @override
  State<ReferalScreen> createState() => _ReferalScreenState();
}

class _ReferalScreenState extends State<ReferalScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  bool isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        fetchEmployees(query);
      } else {
        setState(() {
          employees = [];
          filteredEmployees = [];
        });
      }
    });
  }

  Future<void> fetchEmployees(String company) async {
    setState(() {
      isLoading = true;
    });

    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('hrList').get();

      final normalizedInput = company.toLowerCase();

      final List<Map<String, dynamic>> fetchedEmployees = querySnapshot.docs
    .where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data.containsKey("Company") &&
             data["Company"].toString().toLowerCase().contains(normalizedInput);
    })
    .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        "Name": data["Name"] ?? "No Name",
        "Email": data["Email"] ?? "No Email",
        "Company": data["Company"] ?? "Unknown",
      };
    })
    .toList();


      setState(() {
        employees = fetchedEmployees;
        filteredEmployees = fetchedEmployees;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching employees: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Open Gmail with pre-filled content
  void _openGmailApp(String email, String name, String company) async {
    final Uri gmailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull(
        'subject=Referral Opportunity at $company&body=Hi $name,\n\nI’d like to refer you for a position at $company. Please let me know if you’re interested!\n\nBest regards,\n[Your Name]',
      ),
    );

    try {
      await launchUrl(
        gmailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Gmail app")),
      );
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Employees"),
        backgroundColor: isDark ? Colors.black : Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search company...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: filteredEmployees.isEmpty
                      ? const Center(
                          child: Text("No employees found."),
                        )
                      : ListView.builder(
                          itemCount: filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final employee = filteredEmployees[index];
                            return ListTile(
                              onTap: () => _openGmailApp(
                                employee["Email"],
                                employee["Name"],
                                employee["Company"],
                              ),
                              leading: const CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.blueAccent,
                                child: Icon(Icons.email, color: Colors.white),
                              ),
                              title: Text(employee["Name"]),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Company: ${employee["Company"]}"),
                                  // Text("Email: ${employee["Email"]}"),
                                ],
                              ),
                              isThreeLine: true,
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
