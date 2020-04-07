import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:toys/cart.dart';
import 'package:toys/home.dart';
import 'package:toys/login.dart';
import 'package:toys/product.dart';

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
          primaryColor: Colors.purple[500],
          textTheme: TextTheme(
            headline: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple[500]),
            title: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  final List<Widget> _children = [
    Home(),
    ProductPage(),
    CartPage(),
    LoginPage()
  ];

  static final List<String> _listViewData = [
    "Login",
  ];

  void handleTap(int index){
    setState(() {
        _currentIndex = index;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            widget.title,
            style:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 24),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          leading: GestureDetector(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: 26,
                      decoration: new BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              width: 1.2,
                              color: Theme.of(context).primaryColor),
                          left: BorderSide(
                              width: 1.2,
                              color: Theme.of(context).primaryColor),
                          right: BorderSide(
                              width: 1.2,
                              color: Theme.of(context).primaryColor),
                          bottom: BorderSide(
                              width: 1.2,
                              color: Theme.of(context).primaryColor),
                        ),
                      )),
                  SizedBox(height: 4),
                  Container(
                      alignment: Alignment.topLeft,
                      width: 20,
                      decoration: new BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              width: 1.2,
                              color: Theme.of(context).primaryColor),
                          left: BorderSide(
                              width: 1.2,
                              color: Theme.of(context).primaryColor),
                          right: BorderSide(
                              width: 1.2,
                              color: Theme.of(context).primaryColor),
                          bottom: BorderSide(
                              width: 1.2,
                              color: Theme.of(context).primaryColor),
                        ),
                      )),
                  SizedBox(height: 4),
                  Container(
                      width: 26,
                      decoration: new BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              width: 1.2,
                              color: Theme.of(context).primaryColor),
                          left: BorderSide(
                              width: 1.2,
                              color: Theme.of(context).primaryColor),
                          right: BorderSide(
                              width: 1.2,
                              color: Theme.of(context).primaryColor),
                          bottom: BorderSide(
                              width: 1.2,
                              color: Theme.of(context).primaryColor),
                        ),
                      )),
                  SizedBox(height: 4),
                ],
              ),
            ),
            onTap: () {
              _scaffoldKey.currentState.openDrawer();
            },
          ),
          actions: <Widget>[
            GestureDetector(
              child: Icon(
                Ionicons.ios_search,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () {
                print('search');
              },
            )
          ],
        ),
        drawer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.all(10.0),
              children: _listViewData
                  .map((data) => ListTile(
                        title: Text(data),
                      ))
                  .toList(),
            ),
          ),
        ),
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: handleTap,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(
                Icons.home,
                color: _currentIndex == 0
                    ? Theme.of(context).primaryColor
                    : Colors.black54,
              ),
              title: new Text('Home',
                  style: TextStyle(
                    color: _currentIndex == 0
                        ? Theme.of(context).primaryColor
                        : Colors.black54,
                  )),
            ),
            BottomNavigationBarItem(
              icon: new Icon(FontAwesome.list,
                  color: _currentIndex == 1
                      ? Theme.of(context).primaryColor
                      : Colors.black54),
              title: new Text(
                'Product',
                style: TextStyle(
                    color: _currentIndex == 1
                        ? Theme.of(context).primaryColor
                        : Colors.black54),
              ),
            ),
            BottomNavigationBarItem(
                icon: Icon(FontAwesome.cart_arrow_down,
                    color: _currentIndex == 2
                        ? Theme.of(context).primaryColor
                        : Colors.black54),
                title: Text(
                  'Cart',
                  style: TextStyle(
                      color: _currentIndex == 2
                          ? Theme.of(context).primaryColor
                          : Colors.black54),
                )),
            BottomNavigationBarItem(
                icon: Icon(Ionicons.ios_person,
                    color: _currentIndex == 3
                        ? Theme.of(context).primaryColor
                        : Colors.black54),
                title: Text(
                  'Profile',
                  style: TextStyle(
                      color: _currentIndex == 3
                          ? Theme.of(context).primaryColor
                          : Colors.black54),
                )),
          ],
        ));
  }
}
