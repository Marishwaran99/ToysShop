import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toys_shop/pages/wishlist_page.dart';
import 'package:toys_shop/pages/product_page.dart';
import 'package:toys_shop/styles/custom.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Custom custom = Custom();
  final bool back;
  final GestureTapCallback onPressed;
  MyAppBar({this.back, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: custom.appBarColor,
      title: Text(
        'Toys',
        style: custom.appbarTitleTextStyle,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56);
}
