// import 'dart:async';
// import 'package:connectivity/connectivity.dart';
// import 'package:flutter/material.dart';

// class ConnectivityService extends ChangeNotifier {
//   late StreamSubscription<ConnectivityResult> _connectivitySubscription;
//   bool _isConnected = false;

//   ConnectivityService() {
//     _connectivitySubscription = Connectivity()
//         .onConnectivityChanged
//         .listen((ConnectivityResult result) {
//       if (result != ConnectivityResult.none) {
//         _isConnected = true;
//       } else {
//         _isConnected = false;
//       }
//       notifyListeners();
//     });
//   }

//   bool get isConnected => _isConnected;

//   @override
//   void dispose() {
//     _connectivitySubscription.cancel();
//     super.dispose();
//   }
// }
