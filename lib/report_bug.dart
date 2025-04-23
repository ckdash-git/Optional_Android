import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:firebase_core/firebase_core.dart'; // Import FirebaseCore

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bug Report App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReportBugScreen(),
    );
  }
}

class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({super.key});

  @override
  State<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  File? _screenshot;
  bool _isUploading = false;
  final TextEditingController _bugdescriptionController =
      TextEditingController();

  Future<void> _pickImage() async {
    final permissionStatus = await Permission.photos.request();
    if (!permissionStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access gallery')),
      );
      return;
    }

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      setState(() {
        _screenshot = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref =
          FirebaseStorage.instance.ref().child('bug_reports/$fileName.jpg');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final screeeshot = await snapshot.ref.getDownloadURL();

      print("Image uploaded to: $screeeshot");
      return screeeshot;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _submitReport() async {
    final currentUser = FirebaseAuth.instance.currentUser; // Get current user
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to submit a bug report.')),
      );
      return;
    }

    if (_bugdescriptionController.text.trim().isEmpty && _screenshot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please describe the issue or attach a screenshot.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? screeeshot;
      if (_screenshot != null) {
        screeeshot = await _uploadImage(_screenshot!);
      }

      await FirebaseFirestore.instance.collection('bugReports').add({
        'userId': currentUser.uid, // Add the user's uid to the bug report
        'description': _bugdescriptionController.text.trim(),
        'status': 'Open',
        'timestamp': FieldValue.serverTimestamp(),
        'screeeshot': screeeshot,
      });

      setState(() {
        _bugdescriptionController.clear();
        _screenshot = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bug report submitted successfully!')),
      );
    } catch (e) {
      print("Error submitting bug report: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Failed to submit the bug report. Please try again.')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Report a Bug')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("DESCRIBE THE ISSUE *"),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[900]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: _bugdescriptionController,
                            maxLines: 5,
                            decoration: const InputDecoration.collapsed(
                              hintText:
                                  "What's going wrong? Tell us everything...",
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text("UPLOAD SCREENSHOT (OPTIONAL)"),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload),
                          label: const Text("Choose Screenshot"),
                        ),
                        if (_screenshot != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Image.file(_screenshot!, height: 150),
                          ),
                        const SizedBox(height: 20),
                        const Text("YOUR BUG TICKETS"),
                        const SizedBox(height: 24),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseAuth.instance.currentUser == null
                              ? null
                              : FirebaseFirestore.instance
                                  .collection('bugReports')
                                  .where('userId',
                                      isEqualTo: FirebaseAuth.instance
                                          .currentUser!.uid) // Filter by userId
                                  // .orderBy('timestamp',
                                  //     descending:
                                  //         true) // Optional: Order by timestamp
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (FirebaseAuth.instance.currentUser == null) {
                              return const Center(
                                child: Text(
                                    "You must be logged in to view your bug tickets."),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              print(
                                  "Error loading bug reports: ${snapshot.error}");
                              return const Center(
                                  child: Text("Error loading bug reports."));
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  color: Colors.grey.shade100,
                                ),
                                child: const Center(
                                  child: Text(
                                    "No bug tickets yet.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final bugDoc = snapshot.data!.docs[index];
                                final bug =
                                    bugDoc.data() as Map<String, dynamic>;
                                final description =
                                    bug['description']?.toString() ?? '';
                                final status =
                                    bug['status']?.toString() ?? 'Unknown';
                                final screeeshot =
                                    bug['screeeshot']?.toString() ?? '';

                                if (description.isEmpty)
                                  return const SizedBox();

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.blueGrey[50],
                                    border: Border.all(
                                      color: Colors.blueAccent.withOpacity(0.4),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "description:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        description,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Status: $status",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: status.toLowerCase() == 'open'
                                              ? Colors.orange
                                              : Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (screeeshot.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              screeeshot,
                                              height: 100,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Text(
                                                      "Failed to load image",
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: _submitReport,
              icon: const Icon(Icons.bug_report),
              label: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Submit",
                      style: TextStyle(fontSize: 16),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// extension on User {
//   get userId => null;
// }
