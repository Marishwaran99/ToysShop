import 'package:flutter/material.dart';

class Custom {
  Color appBarColor = Colors.grey[100];
  Color bodyTextColor = Color(0xff333333);
  Color titleTextColor = Color(0xff222222);

  TextStyle appbarTitleTextStyle = TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff222222));
  TextStyle bodyTextStyle =
      TextStyle(height: 1.25, fontSize: 16, color: Color(0xff333333));
  TextStyle titleTextStyle = TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xff333333));
  TextStyle cardTitleTextStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff444444));
  TextStyle inputLabelTextStyle =
      TextStyle(fontSize: 14, color: Color(0xff444444));
  TextStyle headlineTextStyle = TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff444444));
  TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
