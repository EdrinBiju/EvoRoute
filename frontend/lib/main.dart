import 'package:flutter/material.dart';
import 'package:frontend/Pages/Admin/AddLocation/addlocation.dart';
import 'package:frontend/Pages/Admin/AddStaff/addstaff.dart';
import 'package:frontend/Pages/Admin/DeleteLocation/deletelocation.dart';
import 'package:frontend/Pages/Admin/UpdateLocation/updatelocation.dart';
import 'package:frontend/Pages/Admin/admin.dart';
import 'package:frontend/Pages/Admin/ViewStaffs/viewallstaffs.dart';
import 'package:frontend/Pages/Admin/ViewUsers/viewallusers.dart';
import 'package:frontend/Pages/Employee/Add/addroute.dart';
import 'package:frontend/Pages/Employee/Delete/deleteroute.dart';
import 'package:frontend/Pages/Employee/Update/listroute.dart';
import 'package:frontend/Pages/Employee/employee.dart';
import 'package:frontend/Pages/Login/forgot_password.dart';
import 'package:frontend/Pages/Login/login.dart';
import 'package:frontend/Pages/Register/register.dart';
import 'package:frontend/Pages/Users/Home/home.dart';
import 'package:frontend/Pages/Settings/about.dart';
import 'package:frontend/Pages/Settings/changepassword.dart';
import 'package:frontend/Pages/Settings/settings.dart';
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
        '/forgot_password': (context) => ForgotPasswordPage(),
        '/home': (context) => HomePage(),
        '/admin': (context) => AdminPage(),
        '/employee': (context) => EmployeePage(),
        '/addRoute': (context) => AddRoutePage(),
        '/deleteRoute': (context) => DeleteRoutePage(),
        '/updateRoute': (context) => ListRoutePage(),
        '/viewUsers': (context) => ViewAllUsersPage(),
        '/viewStaffs': (context) => ViewAllStaffsPage(),
        '/addLocation': (context) => AddLocationPage(),
        '/updateLocation': (context) => UpdateLocationPage(),
        '/deleteLocation': (context) => DeleteLocationPage(),
        '/addStaff': (context) => AddStaffPage(),
        '/settings': (context) => SettingsPage(),
        '/changePassword': (context) => ChangePasswordPage(),
        '/about': (context) => AboutPage(),
        
      },
    );
  }
}