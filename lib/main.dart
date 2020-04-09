import 'package:flutter/material.dart';
import 'package:toys_shop/pages/add_to_cart_page.dart';
import 'package:toys_shop/pages/home_page.dart';
import 'package:toys_shop/pages/product_page.dart';
import 'package:toys_shop/widgets/SectionTitle.dart';
import 'package:toys_shop/widgets/appbar.dart';
import 'package:toys_shop/widgets/bottom_appbar.dart';
import 'package:toys_shop/widgets/home_page_carousel.dart';
import 'package:toys_shop/widgets/in_section_spacing.dart';
import 'package:toys_shop/widgets/product_carousel.dart';
import 'package:toys_shop/widgets/section_spacing.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toys Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Josefin'),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;
  List<BarItem> _bottomBarItem = [
    BarItem(title: 'Home', iconData: Icons.home),
    BarItem(title: 'Shop', iconData: Icons.shopping_basket),
    BarItem(title: 'Cart', iconData: Icons.shopping_cart),
  ];
  final List<Widget> _screens = [
    HomePage(),
    ProductPage(),
    AddToCartPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(back: false),
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
