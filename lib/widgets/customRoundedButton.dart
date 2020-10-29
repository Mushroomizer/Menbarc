import 'package:flutter/material.dart';

Widget customRoundedButton(Icon icon, Function onpressed,
    {Color fillcolor = Colors.white}) {
  return RawMaterialButton(
    elevation: 2.0,
    fillColor: fillcolor,
    child: icon,
    padding: EdgeInsets.all(5.0),
    shape: CircleBorder(),
    onPressed: onpressed,
  );
}