import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/userModel.dart';
import 'package:toys/pages/add_to_cart_page.dart';
import 'package:toys/pages/product_detail_page.dart';
import 'package:toys/styles/custom.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:toys/widgets/in_section_spacing.dart';
import 'package:toys/widgets/widget.dart';

class BuyPage extends StatefulWidget {
  User currentUser;
  BuyPage({this.currentUser});

  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  List<CartProductList> _cartProductList = List<CartProductList>();
  getCartProduct() async {
    QuerySnapshot snapshots = await Firestore.instance
        .collection('carts')
        .where('userId', isEqualTo: widget.currentUser.uid)
        .getDocuments();
    List<CartProductList> cartProductList = snapshots.documents
        .map((val) => CartProductList.fromDocument((val)))
        .toList();
    print(cartProductList.map((f) => print(f.cartId)));
    setState(() {
      _cartProductList = cartProductList;
    });
  }

  User _currentUser;

  getCurrentUserInfo() async {
    DocumentSnapshot doc = await Firestore.instance
        .collection('users')
        .document(widget.currentUser.uid)
        .get();
    // print(doc.data);
    User details = new User(
        doc.data['uid'],
        doc.data['displayName'],
        doc.data['email'],
        doc.data['address'],
        doc.data['city'],
        doc.data['state'],
        doc.data['photoUrl'],
        doc.data['logintype'],
        doc.data['role']);
    // print(details.username);
    setState(() {
      _currentUser = details;
    });
  }

  String radioItem = '';

  @override
  void initState() {
    super.initState();
    getCartProduct();
    getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController userNameController =
        TextEditingController(text: _currentUser.username);
    TextEditingController addressController =
        TextEditingController(text: _currentUser.address);
    TextEditingController cityController =
        TextEditingController(text: _currentUser.city);
    TextEditingController stateController =
        TextEditingController(text: _currentUser.state);

    Widget _buildAddress() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          decoration: InputDecoration(labelText: "Enter your Address"),
          controller: addressController,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Address is Required';
            }
            return null;
          },
        ),
      );
    }

    Widget _buildUsername() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: userNameController,
          decoration: InputDecoration(labelText: "Receiver"),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Username is Required';
            }
            return null;
          },
          onSaved: (String value) {},
        ),
      );
    }

    Widget _buildCity() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: cityController,
          decoration: InputDecoration(labelText: "Enter your City"),
          validator: (String value) {
            if (value.isEmpty) {
              return 'City is Required';
            }
            return null;
          },
          onSaved: (String value) {},
        ),
      );
    }

    Widget _buildState() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: stateController,
          decoration: InputDecoration(labelText: "Enter your State"),
          validator: (String value) {
            if (value.isEmpty) {
              return 'State is Required';
            }
            return null;
          },
          onSaved: (String value) {},
        ),
      );
    }

    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
          child: Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Wrap(
                      children: _cartProductList.map((p) {
                    return CartProduct(p, widget.currentUser);
                  }).toList()),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Address",
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          SizedBox(height: 10),
                          _buildAddress(),
                          SizedBox(height: 20),
                          Text(
                            "City",
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          SizedBox(height: 10),
                          _buildCity(),
                          SizedBox(height: 20),
                          Text(
                            "State",
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          SizedBox(height: 10),
                          _buildState(),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Select Payment",
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          Column(
                            children: <Widget>[
                              RadioListTile(
                                activeColor: Theme.of(context).primaryColor,
                                groupValue: radioItem,
                                title: Text('Cash on Delivery(COD)'),
                                value: 'COD',
                                onChanged: (val) {
                                  setState(() {
                                    radioItem = val;
                                  });
                                },
                              ),
                              RadioListTile(
                                activeColor: Theme.of(context).primaryColor,
                                groupValue: radioItem,
                                title: Text('Online'),
                                value: 'Online',
                                onChanged: (val) {
                                  setState(() {
                                    radioItem = val;
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Enter the name of the receiver",
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          _buildUsername(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      buildRaisedButton(
                          "Back", Colors.white, Theme.of(context).primaryColor,
                          () {
                        Navigator.pop(context);
                      }),
                      buildRaisedButton("Proceed",
                          Theme.of(context).primaryColor, Colors.white, () {
                        print("procees");
                      }),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ))),
    );
  }

  Wrap CartProduct(CartProductList product, User currentUser) {
    return Wrap(
      children: <Widget>[
        Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
            child: Material(
                borderRadius: BorderRadius.circular(5.0),
                elevation: 3.0,
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: 170.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 10.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            product.thumbnailImage))),
                              ),
                            ),
                            SizedBox(height: 7.0),
                            Text(
                              product.productName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Colors.grey),
                            ),
                            SizedBox(height: 7.0),
                            Row(
                              children: <Widget>[
                                Text(
                                  '₹ ' + product.price.toString(),
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 30),
                                Text(
                                  "Quantity:" + product.quantity.toString(),
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    )))),
      ],
    );
  }
}
