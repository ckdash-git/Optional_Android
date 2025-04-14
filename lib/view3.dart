// import 'package:flutter/material.dart';
// // import 'package:speech_to_text/speech_to_text.dart' as stt;
// // import 'package:permission_handler/permission_handler.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _controller = TextEditingController();
//   // late stt.SpeechToText _speech;
//   bool _isListening = false;
//   bool _speechEnabled = false;

//   @override
//   void initState() {
//     super.initState();
//     // _speech = stt.SpeechToText();
//     _initSpeech();
//   }

//   Future<void> _initSpeech() async {
//     // _speechEnabled = await _speech.initialize();
//   }

//   // Future<void> _listen() async {
//   //   // Step 1: Ask for microphone permission
//   //   var status = await Permission.microphone.status;
//   //   if (!status.isGranted) {
//   //     status = await Permission.microphone.request();
//   //   }

//   //   // Step 2: If granted, start listening
//   //   if (status.isGranted && _speechEnabled) {
//   //     if (!_isListening) {
//   //       setState(() => _isListening = true);
//   //       _speech.listen(
//   //         onResult: (val) {
//   //           setState(() {
//   //             _controller.text = val.recognizedWords;
//   //           });
//   //         },
//   //         listenMode: stt.ListenMode.confirmation,
//   //       );
//   //     } else {
//   //       setState(() => _isListening = false);
//   //       _speech.stop();
//   //     }
//   //   } else {
//   //     // Optional: show alert if permission is denied
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text('Microphone permission denied'),
//   //       ),
//   //     );
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.search, color: Colors.grey),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: "Search everything...",
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: _listen,
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade100,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       _isListening ? Icons.mic : Icons.mic_none,
//                       color: Colors.black,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 1,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//       ),
//     );
//   }
// }
