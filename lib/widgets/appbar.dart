import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toys_shop/pages/add_to_cart_page.dart';
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
      // actions: <Widget>[
      //   IconButton(icon: Icon(Icons.shopping_basket),onPressed: (){
      //     Navigator.push(context, MaterialPageRoute(builder: (BuildContext ctx){
      //       return ProductPage();
      //     }));
      //   },color: custom.titleTextColor,),
      //   IconButton(icon: Icon(Icons.shopping_cart),onPressed: (){
      //     Navigator.push(context, MaterialPageRoute(builder: (BuildContext ctx){
      //       return AddToCartPage();
      //     }));
      //   },color: custom.titleTextColor,)
      // ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(48);
}
