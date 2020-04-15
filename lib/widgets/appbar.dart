import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toys_shop/pages/wishlist_page.dart';
import 'package:toys_shop/pages/product_page.dart';
import 'package:toys_shop/styles/custom.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Custom custom = Custom();
  final String title;
  MyAppBar({this.title});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Text(
        title,
        style: custom.appbarTitleTextStyle,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(48);
}
