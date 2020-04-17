import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toys/models/user.dart';
import 'package:toys/pages/user_order_page.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:toys/widgets/widget.dart';

class DeliveredPage extends StatefulWidget {
  User currentUser;
  DeliveredPage({this.currentUser});

  @override
  _DeliveredPageState createState() => _DeliveredPageState();
}

class _DeliveredPageState extends State<DeliveredPage> {
  List<orderModel> _orderList = List<orderModel>();
  getOrderDetails() async {
    QuerySnapshot snapshots = await Firestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'dispatched')
        .getDocuments();

    List<orderModel> order = snapshots.documents
        .map((order) => orderModel.fromDocument(order))
        .toList();

    setState(() {
      _orderList = order;
    });
    print(_orderList.length);
  }

  @override
  void initState() {
    super.initState();

    getOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(text: 'Toys', back: true,),
      body: SingleChildScrollView(
          child: Center(
        child: _orderList.length == 0
            ? Text("No Delivered Request!")
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
                          "Delivered Request",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ),
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

  handleDelivered(String orderId) {
    print(orderId);
    Firestore.instance.collection('orders').document(orderId).delete();
    getOrderDetails();
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
            Text(
              "Receivers name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(order.receiverName),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Product Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: order.productName.map((f) {
                  return Row(
                    children: <Widget>[
                      Text(f.toString()),
                    ],
                  );
                }).toList()),
            Column(
                children: order.quantity.map((f) {
              return Row(
                children: <Widget>[
                  Text(
                    "(" + f.toString() + ")",
                    style: TextStyle(color: Colors.grey),
                  ),
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
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Delivered",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            order.status == "dispatched"
                ? buildRaisedButton(
                    "Confirm", Theme.of(context).primaryColor, Colors.white,
                    () {
                    handleDelivered(order.orderId.toString());
                  })
                : Text("Confirmed")
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
