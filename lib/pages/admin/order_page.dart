import 'package:flutter/material.dart';
import 'package:toys/models/userModel.dart';
import 'admin_page.dart';

class OrderPage extends StatefulWidget {
  User currentUser;
  OrderPage({this.currentUser});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        leading: widget.currentUser != null ? DrawerIcon() : null,
        backgroundColor: Colors.white,
      ),
       body: Text("Order"),
    );
  }
}