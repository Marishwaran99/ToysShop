import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toys/models/user.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:toys/widgets/customLoading.dart';
import 'package:toys/widgets/widget.dart';
import 'package:path/path.dart';

class UploadPage extends StatefulWidget {
  User currentUser;
  UploadPage({this.currentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  String _title, _description, _discount, _price, _quantity;
  File _image;
  bool isLoading = false;
  List<File> _images = List<File>();
  String dropdownValue = 'Yes';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextFormField buildTextEntryField(
    TextEditingController controller,
    String text,
    IconData icon,
    String variable,
  ) {
    return TextFormField(
      keyboardType: TextInputType.text,
      controller: controller,
      decoration: InputDecoration(
          labelText: text,
          icon: Icon(
            icon,
            size: 18,
          )),
      validator: (String value) {
        if (value.isEmpty) {
          return '$text is Required';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          variable = value;
        });
      },
    );
  }

  TextFormField buildNumberEntryField(
    TextEditingController controller,
    String text,
    IconData icon,
    String variable,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: text,
          icon: Icon(
            icon,
            size: 18,
          )),
      validator: (String value) {
        if (value.isEmpty) {
          return '$text is Required';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          variable = value;
        });
      },
    );
  }

  handleImageSelection() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = file;
    });
    print(basename(_image.path));
  }

  _handleUpload(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
      List<String> previewImage = List<String>();
      int stock;
      for (var img in _images) {
        print(img);
        String previewImageUrl = await uploadImage(basename(img.path), img);
        previewImage.add(previewImageUrl);
      }
      String thumbnailImage = await uploadImage(basename(_image.path), _image);
      var discount = int.parse(discountController.text);
      assert(discount is int);
      var price = int.parse(priceController.text);
      assert(price is int);
      var quantity = int.parse(quantityController.text);
      assert(quantity is int);

      if (dropdownValue == "No") {
        setState(() {
          stock = 0;
        });
      } else {
        setState(() {
          stock = 1;
        });
      }
      var id = new DateTime.now().millisecondsSinceEpoch;
      try {
        Firestore.instance
            .collection('products')
            .document(id.toString())
            .setData({
          "id": id,
          "discount": discount,
          "price": price,
          "quatity": quantity,
          "title": titleController.text,
          "description": descriptionController.text,
          "thumbnailImage": thumbnailImage,
          "previewImages": previewImage,
          "stock": stock,
          "admin": widget.currentUser.uid
        }).then((onValue) {
          discountController.clear();
          priceController.clear();
          quantityController.clear();
          titleController.clear();
          descriptionController.clear();
        }).catchError((onError) => print(onError.message));
      } catch (e) {
        print(e.message);
      }
      setState(() {
        isLoading = false;
        _images = [];
        _image = null;
      });
      buildSuccessDialog("Upload Sucessfull", context);
    }
  }

  Future<String> uploadImage(String fileName, File image) async {
    // String fileName = basename(img.path);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    fileName = '';
    return downloadUrl;
  }

  Future<void> loadAssets() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _images.add(file);
    });
    print(_images);
  }

  @override
  void dispose() {
    super.dispose();
  }

  handleDeletePreviewImage(File img) {
    _images.remove(img);
    print(_images);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        text: 'Toys',
        back: true,
      ),
      body: isLoading
          ? circularProgress(context)
          : Center(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                children: <Widget>[
                  Text(
                    "UPLOAD",
                    style: Theme.of(context).textTheme.headline,
                  ),
                  SizedBox(height: 20),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: buildTextEntryField(titleController,
                                "Product Title", Icons.title, _title),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: buildTextEntryField(
                                descriptionController,
                                "Product Description",
                                Icons.description,
                                _description),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: buildNumberEntryField(discountController,
                                "Discount in %", Icons.low_priority, _discount),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: buildNumberEntryField(priceController,
                                "Price", Ionicons.ios_pricetag, _price),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: buildNumberEntryField(quantityController,
                                "Quantity", Ionicons.ios_add, _quantity),
                          ),
                        ],
                      )),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Text("Stock:"),
                      SizedBox(width: 20),
                      Container(
                        width: 70,
                        child: DropdownButton<String>(
                          value: dropdownValue,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          underline: Container(
                            height: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          items: <String>['Yes', 'No']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _image == null
                      ? Container()
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
                                        child: Image.file(_image),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // handleDeletethumbnailImage(
                                          //     products.thumbnailImage, products.id);
                                        },
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                              width: 25,
                                              height: 25,
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
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
                              ),
                            ],
                          ),
                        ),
                  Row(
                    children: <Widget>[
                      buildRaisedButton("ThumbnailImage", Colors.white,
                          Theme.of(context).primaryColor, () {
                        handleImageSelection();
                      }),
                    ],
                  ),
                  SizedBox(height: 20),
                  _images == null
                      ? Container()
                      : SizedBox(
                          height: 100.0,
                          child: ListView.builder(
                              itemCount: _images.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return Row(
                                  children: <Widget>[
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          width: 100,
                                          height: 100,
                                          child: Image.file(_images[index]),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            handleDeletePreviewImage(
                                                _images[index]);
                                          },
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
                                    SizedBox(width: 10)
                                  ],
                                );
                              }),
                        )
                  ,
                  Row(
                    children: <Widget>[
                      buildRaisedButton("previewImage", Colors.white,
                          Theme.of(context).primaryColor, () {
                        loadAssets();
                      }),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      buildRaisedButton("Upload",
                          Theme.of(context).primaryColor, Colors.white, () {
                        _handleUpload(context);
                      }),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
