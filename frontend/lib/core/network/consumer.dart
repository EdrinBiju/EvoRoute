// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'connectivity_services.dart.txt';

// class MyWidget extends StatelessWidget {
//   const MyWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ConnectivityService>(
//       builder: (context, connectivityService, _) {
//         // Check connectivity status
//         if (!connectivityService.isConnected) {
//           // If not connected, show a Snackbar
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('No network connection'),
//               ),
//             );
//           });
//         }
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Home Page'),
//           ),
//           body: const Center(
//             child: const Text('Welcome to the Home Page'),
//           ),
//         );
//       },
//     );
//   }
// }
