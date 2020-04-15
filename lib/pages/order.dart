import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/userModel.dart';
import 'package:toys/pages/user_order_page.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:toys/widgets/widget.dart';

class Order extends StatefulWidget {
  User currentUser;
  Order({this.currentUser});

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  List<orderModel> _orderList = List<orderModel>();

  getOrderDetails() async {
    QuerySnapshot snapshots = await Firestore.instance
        .collection('orders')
        .where('userId', isEqualTo: widget.currentUser.uid)
        .getDocuments();

    List<orderModel> order = snapshots.documents
        .map((order) => orderModel.fromDocument(order))
        .toList();

    setState(() {
      _orderList = order;
    });
  }

  handleDelete(String orderId, BuildContext context) {
    Firestore.instance.collection('orders').document(orderId).delete();
    buildSuccessDialog("Successfully cancelled your order", context);
    getOrderDetails();
  }

  @override
  void initState() {
    super.initState();
    getOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
          child: Center(
        child: _orderList.length == 0
            ? Text("No Orders Yet!")
            : Container(
                width: MediaQuery.of(context).size.width * 0.9,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(20),
                      color: Color(0xffECECEC),
                      child: Center(
                        child: Text(
                          "My Orders",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                          child: Text(
                        "If u have any question, feel free to Contact us. Our Customer service work 24 ✖ 7",
                        style: TextStyle(color: Colors.grey),
                      )),
                    ),
                    Column(
                      children: _orderList.map((order) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: BuildOrderCard(widget.currentUser, order),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
      )),
    );
  }

  BuildOrderCard(User currentUser, orderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Order ID",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(order.orderId.toString()),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: new EdgeInsets.only(right: 13.0),
              child: Text(
                "Product Name",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Column(
                children: order.productName.map((f) {
              return Row(
                children: <Widget>[
                  Text(f.toString()),
                ],
              );
            }).toList()),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Price",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(order.total.toString())
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Order Date",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(DateFormat('dd/MM/yyyy').format(order.timestamp.toDate()))
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Payment Method",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(order.paymentType)
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Status",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(order.status)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Cancel Order",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  handleDelete(order.orderId.toString(), context);
                })
          ],
        ),
        Center(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Divider(
                  height: 20,
                ))),
      ],
    );
  }
}
