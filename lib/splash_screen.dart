// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'main.dart'; // Import your main home page

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Timer to navigate to the home page after 3 seconds
//     Timer(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const ColorDetectionHomePage()),
//       );
//     });

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFFF6F00), Color(0xFFFFC107)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Image.asset(
//                 'assets/logo.png', // <- Place your logo here
//                 width: 200,
//                 height: 200,
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'COLOR TIFY',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 2,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'A Color Recognition System',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white70,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }