import 'package:flutter/material.dart';

class ObsTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const ObsTextFormField({
    super.key,
    required this.hintText,
    required this.validator,
    required this.controller,
  });

  @override
  State<ObsTextFormField> createState() => _ObsTextFormFieldState();
}

class _ObsTextFormFieldState extends State<ObsTextFormField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        controller: widget.controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          // contentPadding: const EdgeInsets.symmetric(vertical: 15),
          //   enabledBorder: const OutlineInputBorder(
          //     borderSide: BorderSide(color: Colors.white),
          //   ),
          //   focusedBorder: OutlineInputBorder(
          //     borderSide: BorderSide(color: Colors.grey.shade400),
          //   ),
          //   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          // fillColor: Colors.grey.shade200,
          // filled: true,
          hintText: widget.hintText,
          // hintStyle: TextStyle(color: Colors.grey[500]),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                obscureText = !obscureText;
              });
            },
            icon: obscureText
                ? const Icon(Icons.visibility_off)
                : const Icon(
                    Icons.visibility,
                    color: Colors.black,
                  ),
          ),
          prefixIcon: const Icon(Icons.lock),
        ),
        obscureText: obscureText,
        validator: widget.validator,
      ),
    );
  }
}
