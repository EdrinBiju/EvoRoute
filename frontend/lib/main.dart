import 'package:flutter/material.dart';
import 'package:frontend/Pages/Admin/admin.dart';
import 'package:frontend/Pages/Employee/addbus.dart';
import 'package:frontend/Pages/Employee/employee.dart';
import 'package:frontend/Pages/Login/login.dart';
import 'package:frontend/Pages/Register/register.dart';
import 'package:frontend/Pages/Users/Home/home.dart';
import 'package:frontend/core/theme/theme_notifier.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EvoRoute',
      theme: themeNotifier.currentTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomePage(),
        '/admin': (context) => AdminPage(),
        '/employee': (context) => EmployeePage(),
        '/addBus': (context) => AddBusPage()
      },
    );
  }
}