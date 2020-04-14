import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toys/main.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/userModel.dart';
import 'package:toys/pages/product_detail_page.dart';
import 'package:toys/styles/custom.dart';
import 'package:toys/widgets/in_section_spacing.dart';

class AddToCartPage extends StatefulWidget {
  User currentUser;
  AddToCartPage({this.currentUser});
  @override
  _AddToCartPageState createState() => _AddToCartPageState();
}

class CartProductList {
  String userId, productName, thumbnailImage;
  int productId;
  int discount, price, quantity;
  Timestamp timestamp;
  CartProductList(
      {this.userId,
      this.productId,
      this.discount,
      this.quantity,
      this.price,
      this.productName,
      this.thumbnailImage,
      this.timestamp});
  factory CartProductList.fromDocument(DocumentSnapshot doc) {
    return CartProductList(
      userId: doc.data['userId'],
      productId: doc.data['productId'],
      productName: doc.data['productName'],
      thumbnailImage: doc.data['thumbnailImage'],
      discount: doc.data['discount'],
      price: doc.data['price'],
      timestamp: doc.data['timestamp'],
      quantity: doc.data['quantity'],
    );
  }
}

class _AddToCartPageState extends State<AddToCartPage> {

  List<CartProductList> _cartList = List<CartProductList>();

  getCartProducts() async {
    QuerySnapshot docs = await Firestore.instance
        .collection('carts')
        .where('userId', isEqualTo: widget.currentUser.uid)
        .getDocuments();
    // print(docs.documents.length);
    List<CartProductList> CartList = docs.documents.map((val) => CartProductList.fromDocument(val)).toList();
    print(CartList.length);
    setState(() {
      _cartList = CartList;
    });
  }

  @override
  void initState() {
    super.initState();
    getCartProducts();
  }

  Custom custom = Custom();
  @override
  Widget build(BuildContext context) {
    return widget.currentUser == null
        ? GestureDetector(
            child: Text("Sign In First"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MyHomePage(details: widget.currentUser)));
            },
          )
        : SingleChildScrollView(
                  child: Container(
                      child: Column(
                          children: _cartList.map((p) {
                return CartProduct(p);
              }).toList())));
  }
}

class CartProduct extends StatefulWidget {
  final CartProductList product;
  CartProduct(this.product);
  @override
  _CartProductState createState() => _CartProductState();
}

class _CartProductState extends State<CartProduct> {
  Custom custom = Custom();
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey[100],
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext ctx) {
                  return ProductPageDetailPage(widget.product.productId, "user");
                }));
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 150,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(widget.product.thumbnailImage))),
              ),
            ),
            SizedBox(width: 8),
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width -
                          MediaQuery.of(context).size.width * 0.4 -
                          40,
                      child: Text(widget.product.productName, style: custom.bodyTextStyle)),
                  InSectionSpacing(),
                  Text('₹ ' + widget.product.price.toString(),
                      style: custom.cardTitleTextStyle),
                  InSectionSpacing(),
                  Row(
                    children: <Widget>[
                      GestureDetector(
                          child: Container(
                              color: Colors.grey[200],
                              width: 36,
                              height: 36,
                              child: Center(
                                  child: Text(
                                '-',
                                style: TextStyle(fontSize: 36),
                              ))),
                          onTap: () {}),
                      Container(
                          color: Colors.grey[200],
                          width: 36,
                          height: 36,
                          child: Center(
                              child: Text(
                            '1',
                            style: TextStyle(fontSize: 14),
                          ))),
                      GestureDetector(
                          child: Container(
                              color: Colors.grey[200],
                              width: 36,
                              height: 36,
                              child: Center(
                                  child: Text(
                                '+',
                                style: TextStyle(fontSize: 36),
                              ))),
                          onTap: () {}),
                      SizedBox(width: 16),
                      IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.black26,
                          ),
                          onPressed: () {})
                    ],
                  )
                ])
          ],
        ));
  }
}
