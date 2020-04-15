import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toys/main.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/userModel.dart';
import 'package:toys/pages/product_detail_page.dart';

// class Product{
//   String img, discount, url;
//   Product(this.img, this.discount);
// }
class HomePageCarousel extends StatefulWidget {
  User currentUser;
  HomePageCarousel({this.currentUser});
  @override
  _HomePageCarouselState createState() => _HomePageCarouselState();
}

class _HomePageCarouselState extends State<HomePageCarousel> {
  var _activeSlideIndex = 0;
  @override
  void initState() {
    super.initState();
    getProducts();
  }

  List<ProductList> _products = List<ProductList>();
  getProducts() async {
    QuerySnapshot snapshot =
        await Firestore.instance.collection('products').getDocuments();
    List<ProductList> products =
        snapshot.documents.map((product) => ProductList.fromDocument(product)).toList();

    setState(() {
      _products = products..shuffle();
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        height: 250,
        child: _products != null
            ? Stack(
                children: <Widget>[
                  PageView.builder(
                      itemCount: _products.length,
                      onPageChanged: (i) {
                        setState(() {
                          _activeSlideIndex = i;
                        });
                      },
                      itemBuilder: (BuildContext ctx, int i) {
                        return ProductCard(_products[i]);
                      }),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _products.map((m) {
                            var i = _products.indexOf(m);
                            return Container(
                                alignment: Alignment.center,
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: _activeSlideIndex == i
                                      ? Colors.black87
                                      : Colors.black45,
                                ));
                          }).toList(),
                        ),
                      ))
                ],
              )
            : Center(child: CircularProgressIndicator()));
  }
}

class ProductCard extends StatelessWidget {
  final ProductList product;
  ProductCard(this.product);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext ctx) {
          return ProductPageDetailPage(product.id, "user");
        }));
      },
      child: Stack(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                      image: NetworkImage(product.thumbnailImage)))),
          product.discount > 0
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(32)),
                      child: Center(
                        child: Text(
                          product.discount.toString() + "% OFF",
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )))
              : Container()
        ],
      ),
    );
  }
}
