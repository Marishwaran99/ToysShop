import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/user.dart';
import 'package:toys/pages/buy_page.dart';
import 'package:toys/pages/product_detail_page.dart';
import 'package:toys/pages/user_order_page.dart';
import 'package:toys/services/datastore.dart';
import 'package:toys/widgets/appbar.dart';

class OrderTransaction extends StatefulWidget {
  User currentUser;
  OrderTransaction({this.currentUser});

  @override
  _OrderTransactionState createState() => _OrderTransactionState();
}

class _OrderTransactionState extends State<OrderTransaction> {
  List<onlinePayment> _products = List<onlinePayment>();
  getProducts() async {
    QuerySnapshot snapshots = await Datastore().getOnlineTransactionProducts();
    print(snapshots.documents.length);
    List<onlinePayment> products = snapshots.documents
        .map((product) => onlinePayment.fromDocument(product))
        .toList();
    setState(() {
      _products = products;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        text: 'Toys',
        back: true,
      ),
      body: SingleChildScrollView(
          child: Center(
        child: _products.length == 0
            ? Text("No Online payments!")
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
                          "Online Payments",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ),
                    ),
                    Column(
                      children: _products.map((order) {
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

  BuildOrderCard(User currentUser, onlinePayment order) {
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
            Container(
              child: Row(
                children: <Widget>[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: order.productName.map((f) {
                        return Text(f.toString(),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12));
                      }).toList()),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: order.quantity.map((f) {
                        return Text(
                          "(" + f.toString() + ")",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        );
                      }).toList()),
                ],
              ),
            ),
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
              "Dispatch",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // order.status == "pending" ? buildRaisedButton("Confirm", Theme.of(context).primaryColor, Colors.white, (){handleDispatch(order.orderId.toString());}) : Text("Confirmed")
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
