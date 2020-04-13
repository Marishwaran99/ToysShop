import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toys_shop/pages/home_page.dart';
import 'package:toys_shop/pages/product_page.dart';
import 'package:toys_shop/pages/profile_page.dart';
import 'package:toys_shop/pages/shopping_cart_page.dart';
import 'package:toys_shop/services/auth.dart';
import 'package:toys_shop/services/datastore.dart';
import 'package:toys_shop/styles/custom.dart';
import 'package:toys_shop/widgets/appbar.dart';
import 'package:toys_shop/widgets/bottom_appbar.dart';

class MainPage extends StatefulWidget {
  final Auth auth;
  final Datastore datastore;
  final VoidCallback logoutCallback;
  MainPage({this.auth, this.datastore, this.logoutCallback});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _index = 0;
  List<IconData> _bottomBarItem = [
    Icons.home,
    Icons.shopping_basket,
    Icons.shopping_cart,
    CupertinoIcons.person_solid
  ];
  Custom custom = Custom();
  List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomePage(),
      ProductPage(),
      ShoppingCartPage(),
      ProfilePage(
          auth: widget.auth,
          datastore: widget.datastore,
          logoutCallback: widget.logoutCallback)
    ];
    setState(() {});
  }

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
