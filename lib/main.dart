import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:toys/models/user.dart';
import 'package:toys/pages/add_to_cart_page.dart';
import 'package:toys/pages/home_page.dart';
import 'package:toys/pages/product_page.dart';
import 'package:toys/pages/profile.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
  User details;
  MyHomePage({Key key, this.title, this.details}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _cartCount = '0';
  int _currentIndex = 0;
  getCartCount() async {
    QuerySnapshot doc = await Firestore.instance
        .collection('carts')
        .where('userId', isEqualTo: widget.details.uid)
        .getDocuments();
    setState(() {
      _cartCount = doc.documents.length.toString();
    });
  }

  void handleTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  setCurrentIndex() {
    if (widget.details == null) {
      setState(() {
        _currentIndex = 3;
      });
    } else {
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCartCount();
    setCurrentIndex();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      HomePage(
        details: widget.details,
      ),
      ProductPage(
        currentUser: widget.details,
      ),
      AddToCartPage(
        currentUser: widget.details,
      ),
      LoginPage(
        details: widget.details,
      )
    ];

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "TOYS",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                letterSpacing: 2,
                fontSize: 24),
          ),
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          actions: <Widget>[
            GestureDetector(
              child: Icon(
                Ionicons.ios_search,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () {
                print(widget.details.uid);
                getCartCount();
                print('search');
              },
            )
          ],
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

// leading: widget.details != null
//     ? GestureDetector(
//         child: Padding(
//           padding:
//               const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Container(
//                   width: 26,
//                   decoration: new BoxDecoration(
//                     border: Border(
//                       top: BorderSide(
//                           width: 1.2,
//                           color: Theme.of(context).primaryColor),
//                       left: BorderSide(
//                           width: 1.2,
//                           color: Theme.of(context).primaryColor),
//                       right: BorderSide(
//                           width: 1.2,
//                           color: Theme.of(context).primaryColor),
//                       bottom: BorderSide(
//                           width: 1.2,
//                           color: Theme.of(context).primaryColor),
//                     ),
//                   )),
//               SizedBox(height: 4),
//               Container(
//                   alignment: Alignment.topLeft,
//                   width: 20,
//                   decoration: new BoxDecoration(
//                     border: Border(
//                       top: BorderSide(
//                           width: 1.2,
//                           color: Theme.of(context).primaryColor),
//                       left: BorderSide(
//                           width: 1.2,
//                           color: Theme.of(context).primaryColor),
//                       right: BorderSide(
//                           width: 1.2,
//                           color: Theme.of(context).primaryColor),
//                       bottom: BorderSide(
//                           width: 1.2,
//                           color: Theme.of(context).primaryColor),
//                     ),
//                   )),
//               SizedBox(height: 4),
//               Container(
//                   width: 26,
//                   decoration: new BoxDecoration(
//                     border: Border(
//                       top: BorderSide(
//                           width: 1.2,
//                           color: Theme.of(context).primaryColor),
//                       left: BorderSide(
//                           width: 1.2,
//                           color: Theme.of(context).primaryColor),
//                       right: BorderSide(
//                           width: 1.2,
//                           color: Theme.of(context).primaryColor),
//                       bottom: BorderSide(
//                           width: 1.2,
//                           color: Theme.of(context).primaryColor),
//                     ),
//                   )),
//               SizedBox(height: 4),
//             ],
//           ),
//         ),
//         onTap: () {
//           _scaffoldKey.currentState.openDrawer();
//         },
//       )
//     : null,

// drawer: widget.details != null
//     ? SizedBox(
//         width: MediaQuery.of(context).size.width * 0.75,
//         child: Drawer(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               UserAccountsDrawerHeader(
//                   decoration: BoxDecoration(color: Color(0xffECECEC)),
//                   accountName: Text(
//                     widget.details.userName,
//                     style: TextStyle(
//                         color: Theme.of(context).primaryColor,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   accountEmail: Text(
//                     widget.details.userEmail,
//                     style: TextStyle(
//                         color: Theme.of(context).primaryColor,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   currentAccountPicture: CircleAvatar(
//                     backgroundImage: CachedNetworkImageProvider(
//                         widget.details.photoUrl),
//                   )),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 10, vertical: 5),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     GestureDetector(
//                         child: Container(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           children: <Widget>[
//                             Icon(
//                               FontAwesome.list_alt,
//                               size: 18,
//                             ),
//                             SizedBox(width: 10),
//                             Text(
//                               "My Orders",
//                               style: Theme.of(context).textTheme.title,
//                             ),
//                           ],
//                         ),
//                       ),
//                     )),
//                     Divider(
//                       height: 15,
//                     ),
//                     GestureDetector(
//                         child: Container(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           children: <Widget>[
//                             Icon(
//                               FontAwesome.edit,
//                               size: 18,
//                             ),
//                             SizedBox(width: 10),
//                             Text(
//                               "Edit Account",
//                               style: Theme.of(context).textTheme.title,
//                             ),
//                           ],
//                         ),
//                       ),
//                     )),
//                     Divider(
//                       height: 15,
//                     ),
//                     GestureDetector(
//                         child: Container(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           children: <Widget>[
//                             Icon(
//                               Ionicons.ios_lock,
//                               size: 18,
//                             ),
//                             SizedBox(width: 10),
//                             Text(
//                               "Change Password",
//                               style: Theme.of(context).textTheme.title,
//                             ),
//                           ],
//                         ),
//                       ),
//                     )),
//                     Divider(
//                       height: 15,
//                     ),
//                     GestureDetector(
//                         child: Container(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           children: <Widget>[
//                             Icon(
//                               Ionicons.md_remove_circle,
//                               size: 18,
//                             ),
//                             SizedBox(width: 10),
//                             Text(
//                               "Delete Account",
//                               style: Theme.of(context).textTheme.title,
//                             ),
//                           ],
//                         ),
//                       ),
//                     )),
//                     Divider(
//                       height: 15,
//                     ),
//                     GestureDetector(
//                         child: Container(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           children: <Widget>[
//                             Icon(
//                               FontAwesome.sign_out,
//                               size: 18,
//                             ),
//                             SizedBox(width: 10),
//                             Text(
//                               "Logout",
//                               style: Theme.of(context).textTheme.title,
//                             ),
//                           ],
//                         ),
//                       ),
//                     )),
//                     Divider(
//                       height: 15,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       )
//     : null,
