import 'package:flutter/material.dart';

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
      case 'username':
        return const Icon(Icons.person);
      case 'search':
        return const Icon(Icons.search);
      case 'email':
        return const Icon(Icons.email);
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
          hintText: hintText,
          prefixIcon: getIcon(iconName),
        ),
        validator: validator,
      ),
    );
  }
}
