import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_pallete.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader {
  static Future showLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (context) {
        return const Center(
          child: SpinKitSpinningLines(
            color: AppPallete.whiteColor,
            size: 80,
          ),
        );
      },
    );
  }
}
