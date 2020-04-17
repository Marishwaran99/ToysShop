import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:toys/main.dart';
import 'package:toys/models/user.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:toys/widgets/widget.dart';

class UserOrderPage extends StatefulWidget {
  User currentUser;
  String orderId;
  UserOrderPage({this.orderId, this.currentUser});

  @override
  User_OrderPageState createState() => User_OrderPageState();
}

class orderModel{
  int orderId, total, subTotal, tax, shipping ;
  String userId, address, state, city, receiverName, paymentType, status;
  List productIds, quantity, productName;
  Timestamp timestamp;
  orderModel({this.address, this.city, this.orderId, this.paymentType, this.productIds, this.quantity, this.receiverName, this.shipping, this.state, this.subTotal, this.tax, this.total, this.userId, this.timestamp, this.productName, this.status});
  factory orderModel.fromDocument(DocumentSnapshot doc) {
    return orderModel(
      productName: doc.data['productName'],
      address: doc.data['address'],
      city: doc.data['city'],
      orderId: doc.data['orderId'],
      paymentType: doc.data['paymentType'],
      productIds: doc.data['productIds'],
      quantity: doc.data['quantity'],
      receiverName: doc.data['receiverName'],
      shipping: doc.data['shipping'],
      state: doc.data['state'],
      subTotal: doc.data['sub-total'],
      timestamp: doc.data['timestamp'],
      tax: doc.data['tax'],
      total: doc.data['total'],
      userId: doc.data['userId'],
      status: doc.data['status']
    );
  }
}

class User_OrderPageState extends State<UserOrderPage> {

  orderModel _order;

  getOrderDetails() async {

    DocumentSnapshot doc = await Firestore.instance.collection('orders').document(widget.orderId).get();
    orderModel order = orderModel.fromDocument(doc);
    print(order.receiverName);
    setState(() {
      _order = order;
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrderDetails();
  }

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
      leading: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(currentUser: widget.currentUser,)));
        },
        child: Icon(
          Ionicons.ios_arrow_back,
          color: Theme.of(context).primaryColor,
        ),
      ),
      backgroundColor: Colors.white
    ),
      body: SingleChildScrollView(
              child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25),
                child: Center(
                  child: Container(
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
                              "Thanks for your order",
                              style: Theme.of(context).textTheme.title,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Order number",
                              ),
                              Text(widget.orderId),
                            ],
                          ),
                        ),
                        Center(
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Divider(
                                  height: 10,
                                ))),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Order Date",
                              ),
                              Text(DateFormat('E ,dd/MM/yyyy').format(DateTime.now())),
                            ],
                          ),
                        ),
                        Center(
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Divider(
                                  height: 10,
                                ))),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Receiver's Name",
                              ),
                              Text(_order.receiverName),
                            ],
                          ),
                        ),
                        Center(
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Divider(
                                  height: 10,
                                ))),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Total Price",
                              ),
                              Text(_order.total.toString()),
                            ],
                          ),
                        ),
                        Center(
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Divider(
                                  height: 10,
                                ))),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Payment Method",
                              ),
                              Text(_order.paymentType),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                          child: Text(
                            "Please keep the above number for your refernces. We'll also send a confirmation to the email address you used for this order.",style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Shipping Address", style: Theme.of(context).textTheme.subtitle,),
                            SizedBox(height:10),
                            Text(_order.address+" , "+_order.city+" , "+_order.state)
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              buildRaisedButton("Ok", Theme.of(context).primaryColor, Colors.white, (){Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(currentUser: widget.currentUser,)));})
            ],
          ),
        ),
      ),
    );
  }
}
