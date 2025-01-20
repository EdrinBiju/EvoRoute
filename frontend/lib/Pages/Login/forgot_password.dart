import 'package:flutter/material.dart';
import 'package:frontend/components/my_button_new.dart';
import 'package:frontend/components/my_textform_field.dart';
import 'package:frontend/core/theme/app_pallete.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _forgotpassController = TextEditingController();

  @override
  void dispose() {
    _forgotpassController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text(
                  'Valid Email!\nPassword Reset link sent to your registered email'),
            );
          });
    } catch (e) {
      //print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.barAppNav,
        elevation: 0,
      ),
      // backgroundColor: Colors.blueGrey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "Enter the email address associated with your account and we'll send you a link to reset your password",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 10),
          // MyTextField(
          //   controller: _forgotpassController,
          //   hintText: "Registered Email",
          //   obscureText: false,
          // ),
          MyTextFormField(
            hintText: "Email",
            validator: null,
            controller: _forgotpassController,
            obscureText: false,
            iconName: "email",
          ),
          const SizedBox(height: 10),
          MyNewButton(onTap: passwordReset, text: "Reset Password"),
          // MaterialButton(
          //   onPressed: passwordReset,
          //   color: Colors.black12,
          //   child: const Text('Reset Password'),
          // )
        ],
      ),
    );
  }
}
