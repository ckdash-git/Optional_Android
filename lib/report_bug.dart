import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({super.key});

  @override
  State<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  File? _screenshot;
  bool _isUploading = false;
  final TextEditingController _bugMessageController = TextEditingController();

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
      final imageUrl = await snapshot.ref.getDownloadURL();

      print("Image uploaded to: $imageUrl");
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _submitReport() async {
    if (_bugMessageController.text.trim().isEmpty && _screenshot == null) {
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
      String? imageUrl;
      if (_screenshot != null) {
        imageUrl = await _uploadImage(_screenshot!);
      }

      await FirebaseFirestore.instance.collection('bugReports').add({
        'message': _bugMessageController.text.trim(),
        'status': 'Open',
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
      });

      setState(() {
        _bugMessageController.clear();
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
                            controller: _bugMessageController,
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
                          stream: FirebaseFirestore.instance
                              .collection('bugReports')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return const Text("Error loading bug reports.");
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
                                final message =
                                    bug['message']?.toString() ?? '';
                                final status =
                                    bug['status']?.toString() ?? 'Unknown';
                                final imageUrl =
                                    bug['imageUrl']?.toString() ?? '';

                                if (message.isEmpty) return const SizedBox();

                                return Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 8), // Reduced margin
                                  padding: const EdgeInsets.all(
                                      8), // Reduced padding
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        8), // Reduced border radius
                                    color: isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.blueGrey[50],
                                    border: Border.all(
                                      color: Colors.blueAccent.withOpacity(0.4),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 2, // Reduced blur radius
                                        offset: Offset(
                                            0, 1), // Reduced shadow offset
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Message:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12, // Reduced font size
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 4), // Reduced spacing
                                      Text(
                                        message,
                                        style: TextStyle(
                                          fontSize: 12, // Reduced font size
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 6), // Reduced spacing
                                      Text(
                                        "Status: $status",
                                        style: TextStyle(
                                          fontSize: 12, // Reduced font size
                                          color: status.toLowerCase() == 'open'
                                              ? Colors.orange
                                              : Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (imageUrl.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8), // Reduced padding
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                8), // Reduced border radius
                                            child: Image.network(
                                              imageUrl,
                                              height:
                                                  100, // Reduced image height
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
                                                if (loadingProgress == null)
                                                  return child;
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
