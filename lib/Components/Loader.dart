import 'package:digivity_admin_app/AdminPanel/MobileThemsColors/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showLoaderDialog(BuildContext context, {String message = "Please wait..."}) {
  final uiTheme = Provider.of<UiThemeProvider>(context, listen: false);

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: uiTheme.appBarColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: uiTheme.appbarIconColor ?? Colors.blueAccent),
              const SizedBox(height: 20),
              Flexible(
                child: Text(
                  message,
                  style:  TextStyle(fontSize: 16,color: uiTheme.appbarIconColor ?? Colors.black,fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void hideLoaderDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
