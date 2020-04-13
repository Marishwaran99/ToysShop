import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:toys/models/product.dart';
import 'package:toys/pages/product_detail_page.dart';
import 'package:toys/styles/custom.dart';
import 'package:toys/widgets/customLoading.dart';
import 'package:toys/widgets/in_section_spacing.dart';
import 'package:toys/widgets/widget.dart';
import 'package:path/path.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  bool isDeletePage;
  String role;
  ProductCard(this.product, this.role, this.isDeletePage);
  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Custom custom = Custom();
  bool isLoading = false;
  _handleDeleteProduct(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    print(widget.product.id);
    DocumentSnapshot doc = await Firestore.instance
        .collection('products')
        .document(widget.product.id.toString())
        .get();
    deleteProductImage(doc);
    Firestore.instance
        .collection('products')
        .document(widget.product.id.toString())
        .delete();
    setState(() {
      isLoading = false;
    });
  }

  showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Product",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              )),
          content: Text("Are you sure want to delete?"),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "YES",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () async {
                await _handleDeleteProduct(context);
                Navigator.of(context).pop();
                buildSuccessDialog("Product Deleted Successfully!", context);
              },
            ),
            FlatButton(
              child: Text("NO", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProductImage(DocumentSnapshot doc) {
    print(doc.data['previewImages']);
    if (doc.data['previewImages'] != null ) {
      for (var img in doc.data['previewImages']) {
        var fileUrl = Uri.decodeFull(basename(img))
            .replaceAll(new RegExp(r'(\?alt).*'), '');
        FirebaseStorage.instance.ref().child(fileUrl).delete().then((value) {}).catchError((onError){print(onError.message);});
      }
    }
    var fileUrl = Uri.decodeFull(basename(doc.data['thumbnailImage']))
        .replaceAll(new RegExp(r'(\?alt).*'), '');
    FirebaseStorage.instance
        .ref()
        .child(fileUrl)
        .delete()
        .then((value) {})
        .catchError((onError) {
      print(onError.message);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext ctx) {
          return ProductPageDetailPage(widget.product, 'admin');

        }));
      },
      child: isLoading
          ? Center(
              child: circularProgress(context),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Container(
                color: Color(0xffECECEC),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 150,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  widget.product.thumbnailImage))),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      child: Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                '${widget.product.title}',
                                overflow: TextOverflow.fade,
                                style: Theme.of(context).textTheme.headline,
                              ),
                            ),
                            Text(
                              '${widget.product.description}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey),
                            ),
                            InSectionSpacing(),
                            Text('₹ ' + widget.product.price.toString(),
                                style: custom.cardTitleTextStyle),
                            widget.role == 'admin'
                                ? widget.isDeletePage
                                    ? Container(
                                        alignment: Alignment.topRight,
                                        padding: EdgeInsets.only(right: 10),
                                        child: GestureDetector(
                                          onTap: () {
                                            showAlert(context);
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ))
                                    : Text("")
                                : buildRaisedButton("Add to Cart", Colors.white,
                                    Theme.of(context).primaryColor, () {}),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
