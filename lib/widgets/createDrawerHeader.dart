import 'package:flutter/material.dart';

Widget createDrawerHeader(String title) {
  return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
          image: DecorationImage(
              fit: BoxFit.cover,
              image:  AssetImage('assets/images/bg_header.jpg'))),
      child: Stack(children: <Widget>[
        Positioned(
            bottom: 12.0,
            left: 16.0,
            child: Text(title,
                style: TextStyle(
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.blueGrey,blurRadius: 1)],
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500))),
      ]));
}