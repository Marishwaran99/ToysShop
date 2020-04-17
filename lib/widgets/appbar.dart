import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:toys/pages/product_page.dart';
import 'package:toys/styles/custom.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Custom custom = Custom();
  final bool back;
  final String text ;
  MyAppBar({this.back, this.text});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            letterSpacing: 2,
            fontSize: 24),
      ),
      elevation: 0,
      automaticallyImplyLeading: back ? true : false,
      leading: back ? InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Ionicons.ios_arrow_back,
          color: Theme.of(context).primaryColor,
        ),
      ): null,
      backgroundColor: Colors.white,
      actions: <Widget>[
        GestureDetector(
          child: Icon(
            Ionicons.ios_search,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () {
            print('search');
          },
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(48);
}
