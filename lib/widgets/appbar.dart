import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toys_shop/styles/custom.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget{
  final Custom custom = Custom();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: custom.appBarColor,
      title: Row(
        children:[
          GestureDetector(onTap:(){},child:Container(height: 48, child: Icon(Icons.menu, color: custom.titleTextColor))),
          SizedBox(width: 8),
          Text('Toys', style: custom.appbarTitleTextStyle,)
        ]
      ),
      
      actions: <Widget>[
        IconButton(icon: Icon(Icons.search),onPressed: (){},color: custom.titleTextColor,),
        IconButton(icon: Icon(Icons.shopping_cart),onPressed: (){},color: custom.titleTextColor,)
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(48);
}