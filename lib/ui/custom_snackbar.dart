import 'package:flutter/material.dart';

class CustomSnackbar extends SnackBar {
  CustomSnackbar(
      {Key? key,
      required String message,
      Duration duration = const Duration(seconds: 2),
      String btnLabel = 'OK',
      VoidCallback? onOk
      
      
      })
      : super(key: key, content: Text(message), duration: duration, action: SnackBarAction(label: btnLabel, onPressed: (){
        if(onOk != null){
          onOk();
        }
      }));
}
