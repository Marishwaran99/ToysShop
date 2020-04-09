import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toys_shop/pages/wishlist_page.dart';
import 'package:toys_shop/pages/product_page.dart';
import 'package:toys_shop/styles/custom.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Custom custom = Custom();
  final bool back;
  MyAppBar({this.back});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: custom.appBarColor,
      leading: GestureDetector(
          onTap: () {
            back ? Navigator.pop(context) : log('draawer');
          },
          child: IconButton(
              onPressed: () {
                back ? Navigator.pop(context) : log('drawer');
              },
              icon: back
                  ? Icon(
                      Icons.chevron_left,
                      color: Colors.black87,
                    )
                  : Icon(Icons.menu, color: custom.titleTextColor))),
      title: Text(
        'Toys',
        style: custom.appbarTitleTextStyle,
      ),
      
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(48);
}
