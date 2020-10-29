import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

Widget CopyButton(BuildContext context,String text) {
  return FlatButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: text));
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Copied to clipboard",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Theme.of(context).primaryColor,
            textColor: Colors.white,
            fontSize: 16.0);
      },
      child: Text(
        "Copy",
      ));
}