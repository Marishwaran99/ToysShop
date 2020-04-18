import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/user.dart';
import 'package:toys/pages/user_order_page.dart';
import 'package:toys/services/datastore.dart';
import 'package:toys/styles/custom.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:path/path.dart';
import 'package:toys/widgets/widget.dart';

class UpdatePage extends StatefulWidget {
  final User currentUser;
  final ProductList product;
  UpdatePage({this.currentUser, this.product});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  List<ProductList> _products = List();
  File _image;
  List<File> _images = List<File>();

  handleImageSelection() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = file;
    });
    print(basename(_image.path));
  }

  getProducts() async {
    print(widget.currentUser.uid);
    QuerySnapshot snapshots = await Firestore.instance
        .collection('products')
        .where("admin", isEqualTo: widget.currentUser.uid)
        .getDocuments();
    print("Snapshot:${snapshots.documents.length}");

    List<ProductList> products = snapshots.documents
        .map((order) => ProductList.fromDocument(order))
        .toList();
    setState(() {
      _products = products;
    });
    print(_products);
  }

  handleDeletethumbnailImage(String imgPath, int productId) {
    var fileUrl = Uri.decodeFull(basename(imgPath))
        .replaceAll(new RegExp(r'(\?alt).*'), '');
    try {
      FirebaseStorage.instance
          .ref()
          .child(fileUrl)
          .delete()
          .then((value) {})
          .catchError((onError) {
        print(onError.message);
      });
    } catch (e) {
      print('error caught: $e');
    }
    Firestore.instance
        .collection('products')
        .document(productId.toString())
        .updateData({'thumbnailImage': ''});
  }

  handleDeletePreviewImage(String imgPath, int productId) {
    var val = [];
    val.add(imgPath);
    var fileUrl = Uri.decodeFull(basename(imgPath))
        .replaceAll(new RegExp(r'(\?alt).*'), '');
    try {
      FirebaseStorage.instance
          .ref()
          .child(fileUrl)
          .delete()
          .then((value) {})
          .catchError((onError) {
        print(onError.message);
      });
    } catch (e) {
      print('error caught: $e');
    }
    Firestore.instance
        .collection('products')
        .document(productId.toString())
        .updateData({'previewImages': FieldValue.arrayRemove(val)});
  }

  Future<void> loadAssets() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _images.add(file);
    });
    print(_images);
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController productTitleController =
        TextEditingController(text: widget.product.title);
    TextEditingController productDescriptionController =
        TextEditingController(text: widget.product.description);
    TextEditingController productDiscountController =
        TextEditingController(text: widget.product.discount.toString());
    TextEditingController productPriceController =
        TextEditingController(text: widget.product.price.toString());
    TextEditingController productQuantityController =
        TextEditingController(text: widget.product.quantity.toString());
    handleSaveChanges(String productId) async {
      List<String> previewImage = List<String>();
      print(productId.toString());
      var discount = int.parse(productDiscountController.text);
      assert(discount is int);
      var price = int.parse(productPriceController.text);
      assert(price is int);
      var quantity = int.parse(productQuantityController.text);
      assert(quantity is int);
      if (_images != null) {
        for (var img in _images) {
          print(img);
          String previewImageUrl =
              await Datastore().uploadImage(basename(img.path), img);
          previewImage.add(previewImageUrl);
        }
      }
      String img;
      if (_image != null) {
        String thumbnailImage =
            await Datastore().uploadImage(basename(_image.path), _image);
        img = thumbnailImage;
      }
      Firestore.instance.collection('products').document(productId).updateData({
        'thumbnailImage': img,
        'previewImages': FieldValue.arrayUnion(_images),
        'discount': discount,
        'quantity': quantity,
        'price': price,
        'title': productTitleController.text,
        'description': productDescriptionController.text,
      });
      buildSuccessDialog('Updated successfully', context);
    }

    Widget _buildProductTitle() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Title",
            style: Custom().inputLabelTextStyle,
          ),
          SizedBox(height: 4),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              maxLines: 1,
              style: Custom().inputTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'yourname'),
              controller: productTitleController,
              validator: (value) =>
                  value.isEmpty ? 'Username can\'t be empty' : null,
            ),
          )
        ],
      );
    }

    Widget _buildProductDescription() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Description",
            style: Custom().inputLabelTextStyle,
          ),
          SizedBox(height: 4),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              maxLines: 1,
              style: Custom().inputTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'yourname'),
              controller: productDescriptionController,
              validator: (value) =>
                  value.isEmpty ? 'Username can\'t be empty' : null,
            ),
          )
        ],
      );
    }

    Widget _buildProductDiscount() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Discount",
            style: Custom().inputLabelTextStyle,
          ),
          SizedBox(height: 4),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              maxLines: 1,
              style: Custom().inputTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Discount'),
              controller: productDiscountController,
              validator: (value) =>
                  value.isEmpty ? 'Discount can\'t be empty' : null,
            ),
          )
        ],
      );
    }

    Widget _buildProductPrice() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Price",
            style: Custom().inputLabelTextStyle,
          ),
          SizedBox(height: 4),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              maxLines: 1,
              style: Custom().inputTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Discount'),
              controller: productPriceController,
              validator: (value) =>
                  value.isEmpty ? 'Discount can\'t be empty' : null,
            ),
          )
        ],
      );
    }

    Widget _buildProductQuantity() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Quantity",
            style: Custom().inputLabelTextStyle,
          ),
          SizedBox(height: 4),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              maxLines: 1,
              style: Custom().inputTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Discount'),
              controller: productQuantityController,
              validator: (value) =>
                  value.isEmpty ? 'Discount can\'t be empty' : null,
            ),
          )
        ],
      );
    }

    return Scaffold(
      appBar: MyAppBar(
        text: "Toys",
        back: true,
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width * 0.9,
                      color: Color(0xffECECEC),
                      child: Text(
                        "Update Products",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      )),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(height: 20),
                  SizedBox(height: 10),
                  _image != null
                      ? Row(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Container(
                                  width: 100,
                                  height: 100,
                                  child: Image.file(_image),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                        width: 25,
                                        height: 25,
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    30),
                                            color: Colors.red[500]),
                                        child: Center(
                                            child: Text(
                                          "X",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ))),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : widget.product.thumbnailImage == ""
                          ? Container(
                              child: Text(
                                  "All Thumbnail Images Deleted"),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Stack(
                                        children: <Widget>[
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: new BoxDecoration(
                                                image: new DecorationImage(
                                                    image: NetworkImage(
                                                        widget.product
                                                            .thumbnailImage),
                                                    fit: BoxFit
                                                        .cover)),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              handleDeletethumbnailImage(
                                                  widget.product
                                                      .thumbnailImage,
                                                  widget.product.id);
                                            },
                                            child: Align(
                                              alignment:
                                                  Alignment.topRight,
                                              child: Container(
                                                  width: 25,
                                                  height: 25,
                                                  padding:
                                                      EdgeInsets.all(
                                                          8),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                                  30),
                                                      color: Colors
                                                          .red[500]),
                                                  child: Center(
                                                      child: Text(
                                                    "X",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white,
                                                        fontSize: 12),
                                                  ))),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                  widget.product.thumbnailImage == ""
                      ? Row(
                          children: <Widget>[
                            buildRaisedButton(
                                "ThumbnailImage",
                                Colors.white,
                                Theme.of(context).primaryColor, () {
                              handleImageSelection();
                            }),
                          ],
                        )
                      : Text("Thumbnail Image"),
                  SizedBox(height: 20),
                  widget.product.previewImages == []
                      ? Container(
                          child: Text("All Images Deleted"),
                        )
                      : SizedBox(
                          height: 100.0,
                          child: ListView.builder(
                              itemCount:
                                  widget.product.previewImages.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder:
                                  (BuildContext context, int idx) {
                                return Row(
                                  children: <Widget>[
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: new BoxDecoration(
                                              image: new DecorationImage(
                                                  image: NetworkImage(
                                                      widget.product
                                                              .previewImages[
                                                          idx]),
                                                  fit: BoxFit.cover)),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            handleDeletePreviewImage(
                                                widget.product
                                                        .previewImages[
                                                    idx],
                                                widget.product.id);
                                          },
                                          child: Align(
                                            alignment:
                                                Alignment.topRight,
                                            child: Container(
                                                width: 25,
                                                height: 25,
                                                padding:
                                                    EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                                30),
                                                    color: Colors
                                                        .red[500]),
                                                child: Center(
                                                    child: Text(
                                                  "X",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .white,
                                                      fontSize: 12),
                                                ))),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                    _images == null
                                        ? Container()
                                        : Row(
                                            children:
                                                _images.map((img) {
                                              return Stack(
                                                children: <Widget>[
                                                  Container(
                                                    width: 100,
                                                    height: 100,
                                                    child: Image.file(
                                                        img),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {},
                                                    child: Align(
                                                      alignment:
                                                          Alignment
                                                              .topRight,
                                                      child: Container(
                                                          width: 25,
                                                          height: 25,
                                                          padding: EdgeInsets.all(8),
                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.red[500]),
                                                          child: Center(
                                                              child: Text(
                                                            "X",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    12),
                                                          ))),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                  ],
                                );
                              }),
                        ),
                  Row(
                    children: <Widget>[
                      buildRaisedButton("previewImage", Colors.white,
                          Theme.of(context).primaryColor, () {
                        loadAssets();
                      }),
                    ],
                  ),
                  _buildProductTitle(),
                  SizedBox(height: 10),
                  _buildProductDescription(),
                  SizedBox(height: 10),
                  _buildProductDiscount(),
                  SizedBox(height: 10),
                  _buildProductPrice(),
                  SizedBox(height: 10),
                  _buildProductQuantity(),
                  SizedBox(height: 10),
                  buildRaisedButton(
                      'Save Changes',
                      Theme.of(context).primaryColor,
                      Colors.white, () {
                    handleSaveChanges(widget.product.id.toString());
                  })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BuildUpdateCard extends StatelessWidget {
  ProductList product;
  User currentUser;
  BuildUpdateCard({ProductList product, User currentUser});

  @override
  Widget build(BuildContext context) {
    TextEditingController productTitleController =
        TextEditingController(text: product.title);
    Widget _buildProductTitle() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Title",
            style: Custom().inputLabelTextStyle,
          ),
          SizedBox(height: 4),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              maxLines: 1,
              style: Custom().inputTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'yourname'),
              controller: productTitleController,
              validator: (value) =>
                  value.isEmpty ? 'Username can\'t be empty' : null,
            ),
          )
        ],
      );
    }

    return Container(
      child: Column(
        children: <Widget>[
          // _buildProductTitle(),
          Text(product.description)
        ],
      ),
    );
  }
}
// Column(
//                       children: _products.map((products) {
//                         TextEditingController productTitleController =
//                             TextEditingController(text: products.title);
//                         TextEditingController productDescriptionController =
//                             TextEditingController(text: products.description);
//                         TextEditingController productDiscountController =
//                             TextEditingController(
//                                 text: products.discount.toString());
//                         TextEditingController productPriceController =
//                             TextEditingController(
//                                 text: products.price.toString());
//                         TextEditingController productQuantityController =
//                             TextEditingController(
//                                 text: products.quantity.toString());

//                         Widget _buildProductTitle() {
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 "Title",
//                                 style: Custom().inputLabelTextStyle,
//                               ),
//                               SizedBox(height: 4),
//                               Container(
//                                 height: 48,
//                                 padding: EdgeInsets.symmetric(horizontal: 8),
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[200],
//                                     borderRadius: BorderRadius.circular(8)),
//                                 child: TextFormField(
//                                   maxLines: 1,
//                                   style: Custom().inputTextStyle,
//                                   keyboardType: TextInputType.emailAddress,
//                                   decoration: InputDecoration(
//                                       border: InputBorder.none,
//                                       hintText: 'yourname'),
//                                   controller: productTitleController,
//                                   validator: (value) => value.isEmpty
//                                       ? 'Username can\'t be empty'
//                                       : null,
//                                 ),
//                               )
//                             ],
//                           );
//                         }

//                         Widget _buildProductDescription() {
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 "Description",
//                                 style: Custom().inputLabelTextStyle,
//                               ),
//                               SizedBox(height: 4),
//                               Container(
//                                 height: 48,
//                                 padding: EdgeInsets.symmetric(horizontal: 8),
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[200],
//                                     borderRadius: BorderRadius.circular(8)),
//                                 child: TextFormField(
//                                   maxLines: 1,
//                                   style: Custom().inputTextStyle,
//                                   keyboardType: TextInputType.emailAddress,
//                                   decoration: InputDecoration(
//                                       border: InputBorder.none,
//                                       hintText: 'yourname'),
//                                   controller: productDescriptionController,
//                                   validator: (value) => value.isEmpty
//                                       ? 'Username can\'t be empty'
//                                       : null,
//                                 ),
//                               )
//                             ],
//                           );
//                         }

//                         Widget _buildProductDiscount() {
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 "Discount",
//                                 style: Custom().inputLabelTextStyle,
//                               ),
//                               SizedBox(height: 4),
//                               Container(
//                                 height: 48,
//                                 padding: EdgeInsets.symmetric(horizontal: 8),
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[200],
//                                     borderRadius: BorderRadius.circular(8)),
//                                 child: TextFormField(
//                                   maxLines: 1,
//                                   style: Custom().inputTextStyle,
//                                   keyboardType: TextInputType.emailAddress,
//                                   decoration: InputDecoration(
//                                       border: InputBorder.none,
//                                       hintText: 'Discount'),
//                                   controller: productDiscountController,
//                                   validator: (value) => value.isEmpty
//                                       ? 'Discount can\'t be empty'
//                                       : null,
//                                 ),
//                               )
//                             ],
//                           );
//                         }

//                         Widget _buildProductPrice() {
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 "Price",
//                                 style: Custom().inputLabelTextStyle,
//                               ),
//                               SizedBox(height: 4),
//                               Container(
//                                 height: 48,
//                                 padding: EdgeInsets.symmetric(horizontal: 8),
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[200],
//                                     borderRadius: BorderRadius.circular(8)),
//                                 child: TextFormField(
//                                   maxLines: 1,
//                                   style: Custom().inputTextStyle,
//                                   keyboardType: TextInputType.emailAddress,
//                                   decoration: InputDecoration(
//                                       border: InputBorder.none,
//                                       hintText: 'Discount'),
//                                   controller: productPriceController,
//                                   validator: (value) => value.isEmpty
//                                       ? 'Discount can\'t be empty'
//                                       : null,
//                                 ),
//                               )
//                             ],
//                           );
//                         }

//                         Widget _buildProductQuantity() {
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 "Quantity",
//                                 style: Custom().inputLabelTextStyle,
//                               ),
//                               SizedBox(height: 4),
//                               Container(
//                                 height: 48,
//                                 padding: EdgeInsets.symmetric(horizontal: 8),
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[200],
//                                     borderRadius: BorderRadius.circular(8)),
//                                 child: TextFormField(
//                                   maxLines: 1,
//                                   style: Custom().inputTextStyle,
//                                   keyboardType: TextInputType.emailAddress,
//                                   decoration: InputDecoration(
//                                       border: InputBorder.none,
//                                       hintText: 'Discount'),
//                                   controller: productQuantityController,
//                                   validator: (value) => value.isEmpty
//                                       ? 'Discount can\'t be empty'
//                                       : null,
//                                 ),
//                               )
//                             ],
//                           );
//                         }

//                         return Column(
//                           children: <Widget>[
//                             products.thumbnailImage == ""
//                                 ? Container()
//                                 : SingleChildScrollView(
//                                     scrollDirection: Axis.horizontal,
//                                     child: Column(
//                                       children: <Widget>[
//                                         Row(
//                                           children: <Widget>[
//                                             Stack(
//                                               children: <Widget>[
//                                                 Container(
//                                                   width: 100,
//                                                   height: 100,
//                                                   decoration: new BoxDecoration(
//                                                       image: new DecorationImage(
//                                                           image: NetworkImage(
//                                                               products
//                                                                   .thumbnailImage),
//                                                           fit: BoxFit.cover)),
//                                                 ),
//                                                 GestureDetector(
//                                                   onTap: () {
//                                                     // handleDeletethumbnailImage(
//                                                     //     products.thumbnailImage, products.id);
//                                                   },
//                                                   child: Align(
//                                                     alignment:
//                                                         Alignment.topRight,
//                                                     child: Container(
//                                                         width: 25,
//                                                         height: 25,
//                                                         padding:
//                                                             EdgeInsets.all(8),
//                                                         decoration: BoxDecoration(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         30),
//                                                             color: Colors
//                                                                 .red[500]),
//                                                         child: Center(
//                                                             child: Text(
//                                                           "X",
//                                                           style: TextStyle(
//                                                               color:
//                                                                   Colors.white,
//                                                               fontSize: 12),
//                                                         ))),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                             Row(
//                               children: <Widget>[
//                                 buildRaisedButton(
//                                     "ThumbnailImage",
//                                     Colors.white,
//                                     Theme.of(context).primaryColor, () {
//                                   // handleImageSelection();
//                                 }),
//                               ],
//                             ),
//                             SizedBox(height: 20),
//                             products.previewImages == null
//                                 ? Container()
//                                 : SizedBox(
//                                     height: 100.0,
//                                     child: ListView.builder(
//                                         itemCount:
//                                             products.previewImages.length,
//                                         scrollDirection: Axis.horizontal,
//                                         itemBuilder:
//                                             (BuildContext context, int index) {
//                                           return Row(
//                                             children: <Widget>[
//                                               Stack(
//                                                 children: <Widget>[
//                                                   Container(
//                                                     width: 100,
//                                                     height: 100,
//                                                     decoration: new BoxDecoration(
//                                                         image: new DecorationImage(
//                                                             image: NetworkImage(
//                                                                 products.previewImages[
//                                                                     index]),
//                                                             fit: BoxFit.cover)),
//                                                   ),
//                                                   GestureDetector(
//                                                     onTap: () {
//                                                       handleDeletePreviewImage(
//                                                           products.previewImages[
//                                                               index],
//                                                           products.id);
//                                                     },
//                                                     child: Align(
//                                                       alignment:
//                                                           Alignment.topRight,
//                                                       child: Container(
//                                                           width: 25,
//                                                           height: 25,
//                                                           padding:
//                                                               EdgeInsets.all(8),
//                                                           decoration: BoxDecoration(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           30),
//                                                               color: Colors
//                                                                   .red[500]),
//                                                           child: Center(
//                                                               child: Text(
//                                                             "X",
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 fontSize: 12),
//                                                           ))),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               SizedBox(width: 10)
//                                             ],
//                                           );
//                                         }),
//                                   ),

//                             Row(
//                               children: <Widget>[
//                                 buildRaisedButton("previewImage", Colors.white,
//                                     Theme.of(context).primaryColor, () {
//                                   // loadAssets();
//                                 }),
//                               ],
//                             ),
//                             _buildProductTitle(),
//                             SizedBox(height: 10),
//                             _buildProductDescription(),
//                             SizedBox(height: 10),
//                             _buildProductDiscount(),
//                             SizedBox(height: 10),
//                             _buildProductPrice(),
//                             SizedBox(height: 10),
//                             _buildProductQuantity(),
//                           ],
//                         );
//                       }).toList(),
//                     )
