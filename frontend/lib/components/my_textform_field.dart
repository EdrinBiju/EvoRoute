import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MyTextFormField extends StatelessWidget {
  final controller;
  final String hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final String iconName;
  const MyTextFormField(
      {super.key,
      required this.hintText,
      required this.validator,
      required this.controller,
      required this.obscureText,
      required this.iconName});

  Icon getIcon(String iconName) {
    switch (iconName) {
      case 'search':
        return const Icon(Icons.search);
      case 'email':
        return const Icon(Icons.email);
      case 'person_alt_circle_fill':
        return const Icon(CupertinoIcons.person_solid);
      case 'mail':
        return const Icon(CupertinoIcons.mail_solid);
      case 'phone':
        return const Icon(CupertinoIcons.phone_solid);
      case 'building':
        return const Icon(CupertinoIcons.building_2_fill);
      // Add more cases for other icons as needed
      default:
        return const Icon(Icons.error); // Default icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          // contentPadding: const EdgeInsets.symmetric(vertical: 15),
          // enabledBorder: const OutlineInputBorder(
          // borderSide: BorderSide(color: Colors.white),
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Colors.grey.shade400),
          // ),
          // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          // fillColor: Colors.grey.shade200,
          // filled: true,
          hintText: hintText,
          // hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: getIcon(iconName),
        ),
        validator: validator,
      ),
    );
  }
}
