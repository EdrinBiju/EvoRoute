import 'package:flutter/material.dart';

class UpdatePageTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  const UpdatePageTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
      maxLines: 2,
      minLines: 1,
    );
  }
}
