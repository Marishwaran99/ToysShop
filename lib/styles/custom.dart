import 'package:flutter/material.dart';

class Custom {
  Color appBarColor = Colors.grey[100];
  Color bodyTextColor = Color(0xff333333);
  Color titleTextColor = Color(0xff222222);

  Color darkText = Color(0xff555555);
  Color lightText = Color(0xff777777);
    TextStyle appbarTitleTextStyle = TextStyle(letterSpacing: 0.5, fontSize:18, fontWeight:FontWeight.bold, color: Color(0xff555555));
  TextStyle bodyTextStyle = TextStyle(fontSize:14, color: Color(0xff777777), letterSpacing: 0.25);
  TextStyle inputTextStyle = TextStyle(fontSize:14, color: Color(0xff333333));
  TextStyle buttonTextStyle = TextStyle(fontSize:16,letterSpacing: 0.5, fontWeight: FontWeight.bold, color: Color(0xffeeeeee));
  TextStyle linkButtonTextStyle = TextStyle(fontSize:14, letterSpacing: 0.5, fontWeight: FontWeight.bold, color: Color(0xff555555));

  TextStyle titleTextStyle = TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xff333333));
  TextStyle cardTitleTextStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff444444));
  TextStyle inputLabelTextStyle =
      TextStyle(fontSize: 14, color: Color(0xff444444));
  TextStyle headlineTextStyle = TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff444444));
}
