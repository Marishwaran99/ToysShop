import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toys_shop/pages/root_page.dart';
import 'package:toys_shop/services/auth.dart';
import 'package:toys_shop/services/datastore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Toys Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Josefin', primaryColor: Colors.grey[100]),
        home: RootPage(auth: Auth(), datastore: Datastore()));
  }
}
