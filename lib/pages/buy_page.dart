import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/user.dart';
import 'package:toys/pages/add_to_cart_page.dart';
import 'package:toys/pages/product_detail_page.dart';
import 'package:toys/pages/user_order_page.dart';
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
  int _subTotal = 0;
  int _shipping = 0;
  int _tax = 0, _total = 0;
  Razorpay _razor;
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
    for (var cart in cartProductList) {
      _subTotal =
          _subTotal + (cart.price - (cart.price * cart.discount / 100)).toInt();
    }
    if (_subTotal < 500) {
      _shipping = 50;
    }
    setState(() {
      _tax = ((_subTotal + _shipping) * (6 / 100)).toInt();
      _total = _subTotal + _shipping + _tax;
    });
  }

  User _currentUser;

  getCurrentUserInfo() async {
    DocumentSnapshot doc = await Firestore.instance
        .collection('users')
        .document(widget.currentUser.uid)
        .get();
    // print(doc.data);
    User details = User.fromFirestore(doc);
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
    _razor = Razorpay();
    _razor.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razor.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razor.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }
  int _id;

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserOrderPage(
                  orderId: _id.toString(),
                  currentUser: widget.currentUser,
                )));
                // print(_id);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    print(response.message);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    print(response.walletName);
  }

  @override
  void dispose() {
    super.dispose();
    _razor.clear();
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

    handlePlaceOrder() async {
      List ProductIds = List();
      List ProductQuantity = List();
      List ProductName = List();
      print(ProductIds);
      if (addressController.text != null &&
          userNameController.text != null &&
          cityController.text != null &&
          stateController.text != null &&
          radioItem != '') {
        for (var product in _cartProductList) {
          ProductIds.add(product.productId);
          ProductQuantity.add(product.quantity);
          ProductName.add((product.productName));
        }
        int id = DateTime.now().millisecondsSinceEpoch;
        setState(() {
          _id = id;
        });
        // print(id);
        if (radioItem == "Online") {
          print(radioItem);
          var options = {
            'key': 'rzp_test_9SXPJw8jBRSDfa',
            'amount': _total,
            'name': widget.currentUser.username,
            'description': 'Text Payment',
            'prefill': {'contact': '', 'email': widget.currentUser.userEmail},
            'external': {
              'wallets': ['paytm']
            }
          };
          try {
            _razor.open(options);
          } catch (e) {
            print(e);
          }
          Firestore.instance
              .collection("orders")
              .document(id.toString())
              .setData({
            'productName': ProductName,
            'orderId': id,
            'producIds': ProductIds,
            'quantity': ProductQuantity,
            'total': _total,
            'userId': _currentUser.uid,
            'timestamp': DateTime.now(),
            'sub-total': _subTotal,
            'tax': _tax,
            'shipping': _shipping,
            'address': addressController.text,
            'state': stateController.text,
            'city': cityController.text,
            'receiverName': userNameController.text,
            'paymentType': radioItem,
            'status': 'pending'
          }).catchError((onError) {
            print(onError);
          });
          buildSuccessDialog("Order Placed Sucessfully", context);
          for (var product in _cartProductList) {
            DocumentSnapshot doc = await Firestore.instance
                .collection('products')
                .document(product.productId.toString())
                .get();
            var quantity = doc.data['quatity'];
            // print(quantity);
            await Firestore.instance
                .collection('products')
                .document(product.productId.toString())
                .updateData({'quatity': quantity - product.quantity});
            // print("CartId:${product.cartId}");
            await Firestore.instance
                .collection("carts")
                .document(product.cartId.toString())
                .delete();
          }
        } else if (radioItem == "COD") {
          Firestore.instance
              .collection("orders")
              .document(id.toString())
              .setData({
            'productName': ProductName,
            'orderId': id,
            'producIds': ProductIds,
            'quantity': ProductQuantity,
            'total': _total,
            'userId': _currentUser.uid,
            'timestamp': DateTime.now(),
            'sub-total': _subTotal,
            'tax': _tax,
            'shipping': _shipping,
            'address': addressController.text,
            'state': stateController.text,
            'city': cityController.text,
            'receiverName': userNameController.text,
            'paymentType': radioItem,
            'status': 'pending'
          }).catchError((onError) {
            print(onError);
          });
          buildSuccessDialog("Order Placed Sucessfully", context);
          for (var product in _cartProductList) {
            DocumentSnapshot doc = await Firestore.instance
                .collection('products')
                .document(product.productId.toString())
                .get();
            var quantity = doc.data['quatity'];
            // print(quantity);
            await Firestore.instance
                .collection('products')
                .document(product.productId.toString())
                .updateData({'quatity': quantity - product.quantity});
            // print("CartId:${product.cartId}");
            await Firestore.instance
                .collection("carts")
                .document(product.cartId.toString())
                .delete();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserOrderPage(
                          orderId: id.toString(),
                          currentUser: widget.currentUser,
                        )));
          }
        }
      } else {
        buildErrorDialog("Fill in all details!", context);
      }
    }

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
                  buildOrderSummary(context),
                  SizedBox(
                    height: 20,
                  ),
                  buildLocation(
                      context, _buildAddress, _buildCity, _buildState),
                  SizedBox(
                    height: 20,
                  ),
                  buildPayment(context),
                  SizedBox(
                    height: 20,
                  ),
                  buildReceiverDetails(context, _buildUsername),
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
                        handlePlaceOrder();
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

  Container buildReceiverDetails(
      BuildContext context, Widget _buildUsername()) {
    return Container(
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
    );
  }

  Container buildPayment(BuildContext context) {
    return Container(
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
    );
  }

  Container buildLocation(BuildContext context, Widget _buildAddress(),
      Widget _buildCity(), Widget _buildState()) {
    return Container(
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
    );
  }

  Container buildOrderSummary(BuildContext context) {
    return Container(
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
                "Order Summary",
                style: Theme.of(context).textTheme.subtitle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
                child: Text(
              "Shipping and additional costs are calculated based on value you have entered",
              style: TextStyle(color: Colors.grey),
            )),
          ),
          // SizedBox(height: 10),
          Center(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Divider(
                    height: 10,
                  ))),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Sub-Total",
                ),
                Text(
                  "₹" + _subTotal.toString(),
                ),
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Shipping",
                ),
                Text(
                  "₹" + _shipping.toString(),
                ),
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Tax",
                ),
                Text(
                  "₹" + _tax.toString(),
                ),
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Total",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹" + _total.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
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
                        Expanded(
                          flex: 1,
                          child: Column(
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
                                overflow: TextOverflow.fade,
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
                          ),
                        )
                      ],
                    )))),
      ],
    );
  }
}
