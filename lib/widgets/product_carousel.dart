import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:toys/main.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/userModel.dart';
import 'package:toys/pages/product_detail_page.dart';
import 'package:toys/styles/custom.dart';
import 'package:toys/widgets/in_section_spacing.dart';
import 'package:toys/widgets/widget.dart';

class ProductCarousel extends StatefulWidget {
  User currentUser;
  ProductCarousel({this.currentUser});
  @override
  _ProductCarouselState createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {

  List<ProductList> _products = List<ProductList>();
  getProducts() async {
    QuerySnapshot snapshots =
        await Firestore.instance.collection('products').getDocuments();
    List<ProductList> products = snapshots.documents
        .map((product) => ProductList.fromDocument(product))
        .toList();
    setState(() {
      _products = products..shuffle();
    });
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        height: 300,
        child: _products != null
            ? _products.length > 0
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _products.length,
                    itemBuilder: (BuildContext ctx, int i) {
                      return ProductCard(_products[i], widget.currentUser);

                    })
                : Container()
            : Center(child: CircularProgressIndicator()));
  }
}

class ProductCard extends StatefulWidget {
  final ProductList product;
  final User currentUser;

  ProductCard(this.product, this.currentUser);
  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Custom custom = Custom();

  handleCart(ProductList product, BuildContext context) async {
    try {
      QuerySnapshot doc =
          await Firestore.instance.collection('carts').getDocuments();
      // print(doc.documents.length);
      bool isInCart = false;
      // print(widget.currentUser.uid);
      print(doc.documents.map((f) {
        if (f.data['productId'] == product.id && f.data['userId'] == widget.currentUser.uid) {
          isInCart = true;
        } else {
          isInCart = false;
        }
      }));
      if (!isInCart) {
        var id = new DateTime.now().millisecondsSinceEpoch;
        await Firestore.instance
            .collection('carts')
            .document(id.toString())
            .setData({
          "cartId": id,
          "productId": product.id,
          "quantity": 1,
          "productName": product.title,
          "thumbnailImage": product.thumbnailImage,
          "discount": product.discount,
          "price": product.price,
          "userId": widget.currentUser.uid,
          "timestamp": DateTime.now(),
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success",
                  style: TextStyle(
                    color: Colors.green,
                  )),
              content: Text("Product Added to cart"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ok", style: TextStyle(color: Colors.black)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyHomePage(
                                  details: widget.currentUser,
                                )));
                  },
                ),
              ],
            );
          },
        );
      } else {
        buildErrorDialog("Product Already in Cart!", context);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.of(context)
        //     .push(MaterialPageRoute(builder: (BuildContext ctx) {
        //   return ProductPageDetailPage(, "user");
        // }));
      },
      child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          margin: EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                      height: 150,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                              fit: BoxFit.contain,
                              image: NetworkImage(
                                  widget.product.thumbnailImage)))),
                  widget.product.discount > 0
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              width: 56,
                              height: 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(32)),
                              child: Center(
                                child: Text(
                                  widget.product.discount.toString() + "% OFF",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              )))
                      : Container(),
                  Align(
                      alignment: Alignment.topRight,
                      child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                FontAwesome.heart_o,
                                size: 14,
                                color: Colors.red,
                              ),
                            ),
                          )))
                ],
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8))),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InSectionSpacing(),
                      Text(
                        widget.product.title,
                        style: custom.cardTitleTextStyle,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "₹ " + widget.product.price.toString(),
                        style: custom.bodyTextStyle,
                      ),
                      SizedBox(height: 8),
                      IconButton(
                        icon: Icon(FontAwesome.cart_arrow_down),
                        onPressed: () {
                          handleCart(widget.product, context);
                        },
                      )
                    ],
                  ))
            ],
          )),
    );
  }
}
