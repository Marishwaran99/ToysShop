import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toys_shop/pages/home_page.dart';
import 'package:toys_shop/pages/auth_page.dart';
import 'package:toys_shop/pages/product_page.dart';
import 'package:toys_shop/pages/profile_page.dart';
import 'package:toys_shop/pages/wishlist_page.dart';
import 'package:toys_shop/styles/custom.dart';
import 'package:toys_shop/widgets/SectionTitle.dart';
import 'package:toys_shop/widgets/appbar.dart';
import 'package:toys_shop/widgets/bottom_appbar.dart';
import 'package:toys_shop/widgets/home_page_carousel.dart';
import 'package:toys_shop/widgets/in_section_spacing.dart';
import 'package:toys_shop/widgets/product_carousel.dart';
import 'package:toys_shop/widgets/section_spacing.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toys Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Josefin'),
      home: _firebaseAuth.currentUser() != null ? MainPage() : AuthPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _index = 0;
  // List<Map<String,> _drawerItem = [
  //   BarItem(title: 'Home', iconData: Icons.home),
  //   BarItem(title: 'Products', iconData: Icons.shopping_basket),
  //   BarItem(title: 'Wishlist', iconData: CupertinoIcons.heart_solid),
  // ];
  List<IconData> _bottomBarItem = [
    Icons.home,
    Icons.shopping_basket,
    Icons.shopping_cart,
    CupertinoIcons.person_solid
  ];
  Custom custom = Custom();
  final List<Widget> _screens = [
    HomePage(),
    ProductPage(),
    WishlistPage(),
    ProfilePage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: MyAppBar(
          back: false,
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        body: _screens[_index],
        bottomNavigationBar: AnimatedBottomBar(
            barItems: _bottomBarItem,
            duration: Duration(milliseconds: 200),
            onBarTap: (i) {
              setState(() {
                _index = i;
              });
            }));
  }
}
