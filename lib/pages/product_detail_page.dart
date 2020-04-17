import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toys/models/product.dart';
import 'package:toys/pages/view_image.dart';
import 'package:toys/styles/custom.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:toys/widgets/in_section_spacing.dart';
import 'package:toys/widgets/section_spacing.dart';

class ProductPageDetailPage extends StatefulWidget {
  String role;
  int productId;
  ProductPageDetailPage(this.productId, this.role);
  @override
  _ProductPageDetailPageState createState() => _ProductPageDetailPageState();
}

class _ProductPageDetailPageState extends State<ProductPageDetailPage> {
  Product _product;
  getProductInfo() async {
    DocumentSnapshot doc = await Firestore.instance
        .collection('products')
        .document(widget.productId.toString())
        .get();
    Product product = Product(
        doc.data['id'],
        doc.data['title'],
        doc.data['description'],
        doc.data['discount'],
        doc.data['quantity'],
        doc.data['thumbnailImage'],
        doc.data['price'],
        doc.data['adminId']);
    setState(() {
      _product = product;
    });
  }

  @override
  void initState() {
    super.initState();
    getProductInfo();
  }

  _ProductPageDetailPageState();
  Custom custom = Custom();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        back: true,
        text: "Toys",
      ),
      body: SingleChildScrollView(
          child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _product.title,
              style: custom.bodyTextStyle,
            ),
            InSectionSpacing(),
            Stack(children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewImage(image: _product.thumbnailImage,)));
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                            image: NetworkImage(_product.thumbnailImage)))),
              ),
              _product.discount > 0
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
                              _product.discount.toString() + "% OFF",
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          )))
                  : Container()
            ]),
            InSectionSpacing(),
            Text(
              '₹ ' + _product.price.toString(),
              style: custom.titleTextStyle,
            ),
            InSectionSpacing(),
            widget.role == 'admin'
                ? Text("")
                : Row(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          print(widget.role);
                        },
                        child: Text('Buy Now'),
                        color: custom.bodyTextColor,
                        textColor: Colors.white,
                      ),
                      SizedBox(width: 16),
                      FlatButton(
                          onPressed: () {},
                          color: Colors.grey[200],
                          child: Text(
                            'Add to Cart',
                          )),
                    ],
                  ),
            SectionSpacing(),
            Text("About", style: custom.cardTitleTextStyle),
            InSectionSpacing(),
            Text(
              _product.description,
              style: custom.bodyTextStyle,
            )
          ],
        ),
      )),
    );
  }
}
