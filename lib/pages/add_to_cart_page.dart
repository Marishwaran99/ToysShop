import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:toys/main.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/user.dart';
import 'package:toys/pages/buy_page.dart';
import 'package:toys/pages/product_detail_page.dart';
import 'package:toys/pages/product_page.dart';
import 'package:toys/styles/custom.dart';
import 'package:toys/widgets/in_section_spacing.dart';
import 'package:toys/widgets/widget.dart';
import 'dart:async';
import 'dart:io';

class AddToCartPage extends StatefulWidget {
  User currentUser;
  AddToCartPage({this.currentUser});
  @override
  _AddToCartPageState createState() => _AddToCartPageState();
}

class CartProductList {
  String userId, productName, thumbnailImage;
  int productId, cartId;
  int discount, price, quantity;
  Timestamp timestamp;
  CartProductList(
      {this.cartId,
      this.userId,
      this.productId,
      this.discount,
      this.quantity,
      this.price,
      this.productName,
      this.thumbnailImage,
      this.timestamp});
  factory CartProductList.fromDocument(DocumentSnapshot doc) {
    return CartProductList(
      cartId: doc.data['cartId'],
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
  int _CartCount;
  int _total = 0;

  getCartProducts() async {
    QuerySnapshot docs = await Firestore.instance
        .collection('carts')
        .where('userId', isEqualTo: widget.currentUser.uid)
        .getDocuments();
    // print(docs.documents.length);
    setState(() {
      _CartCount = docs.documents.length;
    });
    List<CartProductList> CartList =
        docs.documents.map((val) => CartProductList.fromDocument(val)).toList();
    setState(() {
      _cartList = CartList;
    });
    for (var cart in CartList) {
      _total =
          _total + (cart.price - (cart.price * cart.discount / 100)).toInt();
    }
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
                          MyHomePage(currentUser: widget.currentUser)));
            },
          )
        : _CartCount != 0
            ? Stack(
                children: <Widget>[
                  SingleChildScrollView(
                      child: Column(
                    children: <Widget>[
                      Container(
                          child: Column(
                              children: _cartList.map((p) {
                        return CartProduct(p, widget.currentUser);
                      }).toList())),
                      SizedBox(height: 50)
                    ],
                  )),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: FloatingActionButton(
                          backgroundColor: Theme.of(context).primaryColor,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BuyPage(
                                          currentUser: widget.currentUser,
                                        )));
                          },
                          child: Icon(Icons.navigate_next)),
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.bottomLeft,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(18.0),
                  //     child: FloatingActionButton.extended(
                  //       backgroundColor: Theme.of(context).primaryColor,
                  //       label: Text("Total: " + _total.toString()),
                  //       onPressed: (){print("Total");},
                  //     ),
                  //   ),
                  // ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "No Items in Cart",
                      style: Theme.of(context).textTheme.headline,
                    ),
                    buildRaisedButton("Shop Now", Colors.white,
                        Theme.of(context).primaryColor, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage(
                                    currentUser: widget.currentUser,
                                  )));
                    })
                  ],
                ),
              );
  }
}

class CartProduct extends StatefulWidget {
  User currentUser;
  final CartProductList cartProduct;
  CartProduct(this.cartProduct, this.currentUser);
  @override
  _CartProductState createState() => _CartProductState();
}

class _CartProductState extends State<CartProduct> {
  Custom custom = Custom();

  Future<void> _handleDeleteFromCart() async {
    print(widget.cartProduct.productId);
    await Firestore.instance
        .collection('carts')
        .where('productId', isEqualTo: widget.cartProduct.productId)
        .where('userId', isEqualTo: widget.currentUser.uid)
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
    buildSuccessDialog("Product Deleted From Cart!", context);
    // Navigator.push(context, MaterialPageRoute(builder: (context) => AddToCartPage(currentUser: widget.currentUser,)));
  }

  int _counter;

  void _incrementCounter() {
    getProductQuantity();
    if (_counter == _quantity) {
      setState(() {
        _counter = _counter;
      });
      buildErrorDialog("Only $_quantity products in stock!", context);
    } else {
      setState(() {
        _counter++;
      });
    }
    updateCartQuantity();
  }

  updateCartQuantity() async {
    await Firestore.instance
        .collection('carts')
        .document(widget.cartProduct.cartId.toString())
        .updateData({"quantity": _counter});
  }

  void _decrementCounter() {
    if (_counter == 1) {
      setState(() {
        _counter = _counter;
      });
    } else {
      setState(() {
        _counter--;
      });
    }
  }

  int _quantity;

  getProductQuantity() async {
    // print(widget.cartProduct.productId);
    DocumentSnapshot doc = await Firestore.instance
        .collection('products')
        .document(widget.cartProduct.productId.toString())
        .get();
    print(doc.data['quatity'].toString());
    ProductList product = ProductList(
      quantity: doc.data['quatity'],
      previewImages: doc.data['previewImages'],
      description: doc.data['description'],
      discount: doc.data['discount'],
    );
    setState(() {
      _quantity = product.quantity;
    });
  }

  getCartQuantity() async {
    DocumentSnapshot doc = await Firestore.instance
        .collection('carts')
        .document(widget.cartProduct.cartId.toString())
        .get();
    setState(() {
      _counter = doc.data['quantity'];
    });
  }

  @override
  void initState() {
    super.initState();
    getCartQuantity();
    print(widget.currentUser.username);
  }

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
                  return ProductPageDetailPage(
                      widget.cartProduct.productId, "user");
                }));
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 150,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image:
                            NetworkImage(widget.cartProduct.thumbnailImage))),
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
                      child: Text(widget.cartProduct.productName,
                          style: custom.bodyTextStyle)),
                  InSectionSpacing(),
                  Column(
                    children: <Widget>[
                      Text(
                          '₹ ' +
                              (widget.cartProduct.price -
                                      (widget.cartProduct.price *
                                          widget.cartProduct.discount /
                                          100))
                                  .toString(),
                          style: custom.cardTitleTextStyle),
                      widget.cartProduct.discount > 0
                          ? Text('₹ ' + widget.cartProduct.price.toString(),
                              style: TextStyle(
                                  fontSize: 14,
                                  decoration: TextDecoration.lineThrough))
                          : Text(""),
                    ],
                  ),
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
                          onTap: () {
                            _decrementCounter();
                          }),
                      Container(
                          color: Colors.grey[200],
                          width: 36,
                          height: 36,
                          child: Center(
                              child: Text(
                            _counter.toString(),
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
                          onTap: () {
                            _incrementCounter();
                          }),
                      SizedBox(width: 16),
                      IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.black26,
                          ),
                          onPressed: () {
                            _handleDeleteFromCart();
                          })
                    ],
                  )
                ])
          ],
        ));
  }
}
