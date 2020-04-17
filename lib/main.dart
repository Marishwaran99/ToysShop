import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:toys/models/user.dart';
import 'package:toys/pages/add_to_cart_page.dart';
import 'package:toys/pages/home_page.dart';
import 'package:toys/pages/product_page.dart';
import 'package:toys/pages/profile.dart';
import 'package:toys/services/auth.dart';
import 'package:toys/widgets/appbar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOYS',
      theme: ThemeData(
          fontFamily: 'Josefin',
          primarySwatch: Colors.blue,
          primaryColor: Color(0xff28AB87),
          textTheme: TextTheme(
            headline: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff28AB87)),
            title: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            subtitle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff222222)),
            body1: TextStyle(fontSize: 16, color: Color(0xff333333)),
            body2: TextStyle(fontSize: 14, color: Color(0xff333333)),
            caption: TextStyle(fontSize: 12, color: Color(0xff222222)),
          )),
      home: MyHomePage(title: 'TOYS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  User currentUser;
  MyHomePage({Key key, this.title, this.currentUser}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User currentUser;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _cartCount = '0';
  int _currentIndex = 0;
  getCartCount() async {
    QuerySnapshot doc = await Firestore.instance
        .collection('carts')
        .where('userId', isEqualTo: currentUser.uid)
        .getDocuments();
    setState(() {
      _cartCount = doc.documents.length.toString();
    });
  }

  void loginCallback() {
    Auth().getCurrentUser().then((user) {
      setState(() {
        user = user;
      });
    });
    // setState(() {
    //   _authStatus = AuthStatus.LOGGED_IN;
    // });
  }

  void logoutCallback() {
    setState(() {
      // _authStatus = AuthStatus.NOT_LOGGED_IN;
      // _userId = '';
      _currentIndex = 3;
      widget.currentUser = null;
    });
  }

  void handleTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  getCurrentUserInfo() async {
    if (widget.currentUser != null) {
      DocumentSnapshot doc = await Firestore.instance
          .collection('users')
          .document(widget.currentUser.uid)
          .get();
      User details = User.fromFirestore(doc);
      setState(() {
        currentUser = details;
        _currentIndex = 0;
      });
      QuerySnapshot docs = await Firestore.instance
          .collection('carts')
          .where('userId', isEqualTo: currentUser.uid)
          .getDocuments();
      setState(() {
        _cartCount = docs.documents.length.toString();
      });
    } else {
      _currentIndex = 3;
    }
  }

  @override
  void initState() {
    super.initState();
    getCartCount();
    getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      HomePage(
        details: currentUser,
      ),
      ProductPage(
        currentUser: currentUser,
      ),
      AddToCartPage(
        currentUser: currentUser,
      ),
      LoginPage(
        details: currentUser,
        logoutCallback: logoutCallback,
      )
    ];

    return Scaffold(
        key: _scaffoldKey,
        appBar: MyAppBar(
          text: "Toys",
          back: false,
        ),
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: handleTap,
          items: [
            buildBottomNavigationBarItem(
                context, _currentIndex, 0, Icons.home, "Home"),
            buildBottomNavigationBarItem(
                context, _currentIndex, 1, FontAwesome.list, "Products"),
            BottomNavigationBarItem(
              icon: Stack(
                children: <Widget>[
                  Icon(
                    FontAwesome.cart_arrow_down,
                    color: _currentIndex == 2
                        ? Theme.of(context).primaryColor
                        : Colors.black54,
                  ),
                  _cartCount == '0'
                      ? Text('')
                      : Padding(
                          padding: const EdgeInsets.only(left: 17),
                          child: Container(
                            width: 15,
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _cartCount,
                              style:
                                  TextStyle(fontSize: 10, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ],
              ),
              title: new Text("Cart",
                  style: TextStyle(
                    color: _currentIndex == 2
                        ? Theme.of(context).primaryColor
                        : Colors.black54,
                  )),
            ),
            buildBottomNavigationBarItem(
                context, _currentIndex, 3, Ionicons.ios_person, "Profile"),
          ],
        ));
  }

  BottomNavigationBarItem buildBottomNavigationBarItem(BuildContext context,
      int _currentIndex, int number, IconData icon, String text) {
    return BottomNavigationBarItem(
      icon: text == "Cart"
          ? Stack(
              children: <Widget>[
                Icon(
                  icon,
                  color: _currentIndex == number
                      ? Theme.of(context).primaryColor
                      : Colors.black54,
                )
              ],
            )
          : new Icon(
              icon,
              color: _currentIndex == number
                  ? Theme.of(context).primaryColor
                  : Colors.black54,
            ),
      title: new Text(text,
          style: TextStyle(
            color: _currentIndex == number
                ? Theme.of(context).primaryColor
                : Colors.black54,
          )),
    );
  }
}