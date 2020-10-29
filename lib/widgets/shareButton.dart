import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

Widget ShareButton(BuildContext context,String text) {
  return FlatButton(
      onPressed: () {
        Share.share(text);
        Navigator.of(context).pop();
      },
      child: Text(
        "Share",
      ));
}