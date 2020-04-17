import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:toys/main.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/user.dart';
import 'package:toys/services/auth.dart';
import 'package:toys/services/datastore.dart';
import 'package:toys/styles/custom.dart';
import 'package:toys/widgets/SectionTitle.dart';
import 'package:toys/widgets/in_section_spacing.dart';
import 'package:toys/widgets/widget.dart';

class ProductPage extends StatefulWidget {
  User currentUser;
  ProductPage({this.currentUser});
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  var _mySelection;
  List<ProductList> _productsList = List<ProductList>();
  List<ProductList> _filterList = List<ProductList>();

  getAllProducts() async {
    print(_mySelection);
    if (_mySelection == 'High to Low') {
      QuerySnapshot doc = await Firestore.instance
          .collection('products')
          .orderBy('price', descending: true)
          .getDocuments();
      List<ProductList> productList = doc.documents
          .map((product) => ProductList.fromDocument(product))
          .toList();
      setState(() {
        _filterList = productList;
      });
    } else if (_mySelection == 'Low to High') {
      QuerySnapshot doc = await Firestore.instance
          .collection('products')
          .orderBy('price', descending: false)
          .getDocuments();
      List<ProductList> productList = doc.documents
          .map((product) => ProductList.fromDocument(product))
          .toList();
      setState(() {
        _filterList = productList;
      });
    } else {
      QuerySnapshot doc =
          await Firestore.instance.collection('products').getDocuments();
      List<ProductList> productList = doc.documents
          .map((product) => ProductList.fromDocument(product))
          .toList();
      setState(() {
        _productsList = productList;
      });
    }
  }

  searchByFilter(var filter) async {
    print(filter);
    if (filter == 'High to Low') {
      QuerySnapshot doc = await Firestore.instance
          .collection('products')
          .orderBy('price', descending: true)
          .getDocuments();
      List<ProductList> productList = doc.documents
          .map((product) => ProductList.fromDocument(product))
          .toList();
      setState(() {
        _productsList = productList;
      });
    }
    if (filter == 'Low to High') {
      QuerySnapshot doc = await Firestore.instance
          .collection('products')
          .orderBy('price', descending: false)
          .getDocuments();
      List<ProductList> productList = doc.documents
          .map((product) => ProductList.fromDocument(product))
          .toList();
      setState(() {
        _productsList = productList;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllProducts();
  }

  TextEditingController _searchController = TextEditingController();
  var filters = ['Price: Low to High', 'Price: High to Low'];
  Custom custom = Custom();
  handleCart(ProductList product, BuildContext context) async {
    try {
      QuerySnapshot doc =
          await Firestore.instance.collection('carts').getDocuments();
      print(doc.documents.length);
      bool isInCart = false;
      print(doc.documents.map((f) {
        if (f.data['productId'] == product.id &&
            f.data['userId'] == widget.currentUser.uid) {
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
                                  currentUser: widget.currentUser,
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

  handleAddToWishlist(String productId, bool fav) async {
    List productIds = List();
    productIds.add(productId);
    if (fav) {
      await Firestore.instance
          .collection('wishlists')
          .document(widget.currentUser.uid)
          .updateData({'productIds': FieldValue.arrayUnion(productIds)});
    } else if (!fav) {
      await Firestore.instance
          .collection('wishlists')
          .document(widget.currentUser.uid)
          .updateData({'productIds': FieldValue.arrayRemove(productIds)});
    }
  }

  Future<bool> isInWishlist(ProductList p) async {
    List _wishListProductIds = List();
    bool fav;

    DocumentSnapshot snapshot = await Firestore.instance
        .collection('wishlists')
        .document(widget.currentUser.uid)
        .get();

    for (var name in snapshot.data['productIds']) {
      _wishListProductIds.add(name);
    }
    print(_wishListProductIds);
    for (var productId in _wishListProductIds) {
      if (productId.toString() == p.id.toString()) {
        fav = true;
        // print(fav);
      } else {
        fav = false;
        // print(fav);
      }
    }

    return fav;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => getAllProducts(),
      child: SingleChildScrollView(
        child: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  margin: EdgeInsets.only(left: 16, top: 16, bottom: 16),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadiusDirectional.circular(8)),
                  child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                          hintText: 'Search', border: InputBorder.none)),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadiusDirectional.circular(8)),
                  width: MediaQuery.of(context).size.width * 0.5 - 50,
                  child: GestureDetector(
                    onTap: () {
                      print(_mySelection);
                    },
                    child: DropdownButton(
                      onChanged: (val) {
                        _mySelection = val;
                        getAllProducts();
                      },
                      hint: _mySelection == null
                          ? Icon(
                              Icons.filter_1,
                              size: 14,
                            )
                          : Text(_mySelection),
                      value: _mySelection,
                      underline: SizedBox(),
                      items: filters.map((f) {
                        return DropdownMenuItem(
                          value: f,
                          child: Text(
                            f,
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              ],
            ),
            SectionTitle('Products'),
            InSectionSpacing(),
            Column(
                children: _productsList.map((p) {
              // var fav = isInWishlist(p);
              bool _fav = true;
              Datastore().getWishList(widget.currentUser, p).then((onValue){
                print(onValue);
                _fav = onValue;
                // setState(() {
                //   _fav = onValue;
                // });
              });
              return BuildProductCard(p, custom, widget.currentUser, _fav);
            }).toList()),
          ],
        )),
      ),
    );
  }

  Widget BuildProductCard(
      ProductList p, Custom custom, User currentUser, bool fav) {
        // bool fav = false;
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Container(
          color: Color(0xffECECEC),
          child: Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 150,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image:
                                CachedNetworkImageProvider(p.thumbnailImage))),
                  ),
                  p.discount > 0
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(32)),
                              child: Center(
                                child: Text(
                                  p.discount.toString() + "%",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 8, fontWeight: FontWeight.bold),
                                ),
                              )))
                      : Container()
                ],
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4),
                        child: Text(
                          '${p.title}',
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ),
                      Text(
                        '${p.description}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey),
                      ),
                      InSectionSpacing(),
                      Column(
                        children: <Widget>[
                          Text(
                              '₹ ' +
                                  (p.price - (p.price * p.discount / 100))
                                      .toString(),
                              style: custom.cardTitleTextStyle),
                          p.discount > 0
                              ? Text('₹ ' + p.price.toString(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      decoration: TextDecoration.lineThrough))
                              : Text(""),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          buildRaisedButton("Add to Cart", Colors.white,
                              Theme.of(context).primaryColor, () {
                            handleCart(p, context);
                          }),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: IconButton(
                                      icon: fav
                                          ? Icon(
                                              FontAwesome.heart,
                                              size: 15,
                                              color: Colors.red,
                                            )
                                          : Icon(
                                              FontAwesome.heart_o,
                                              size: 15,
                                              color: Colors.red,
                                            ),
                                      onPressed: () {
                                        fav = !fav;
                                        handleAddToWishlist(
                                            p.id.toString(), fav);
                                        print(fav);
                                      }),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BuildProductCard extends StatefulWidget {
  ProductList p;
  Custom custom;
  User currentUser;
  BuildProductCard({this.currentUser, this.custom, this.p});

  @override
  _BuildProductCardState createState() => _BuildProductCardState();
}

class _BuildProductCardState extends State<BuildProductCard> {
  handleCart(ProductList product, BuildContext context) async {
    try {
      QuerySnapshot doc =
          await Firestore.instance.collection('carts').getDocuments();
      print(doc.documents.length);
      bool isInCart = false;
      print(doc.documents.map((f) {
        if (f.data['productId'] == product.id &&
            f.data['userId'] == widget.currentUser.uid) {
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
                                  currentUser: widget.currentUser,
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

  handleAddToWishlist(String productId, bool fav) async {
    List productIds = List();
    productIds.add(productId);
    if (fav) {
      await Firestore.instance
          .collection('wishlists')
          .document(widget.currentUser.uid)
          .updateData({'productIds': FieldValue.arrayUnion(productIds)});
    } else if (!fav) {
      await Firestore.instance
          .collection('wishlists')
          .document(widget.currentUser.uid)
          .updateData({'productIds': FieldValue.arrayRemove(productIds)});
    }
  }

  bool fav;
  getWishProduct() async {
    bool _fav = await Datastore().getWishList(widget.currentUser, widget.p);
    setState(() {
      fav = _fav;
    });
  }

  @override
  void initState() {
    super.initState();
    getWishProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Container(
            color: Color(0xffECECEC),
            child: Row(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 150,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  widget.p.thumbnailImage))),
                    ),
                    widget.p.discount > 0
                        ? Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(32)),
                                child: Center(
                                  child: Text(
                                    widget.p.discount.toString() + "%",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )))
                        : Container()
                  ],
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4),
                          child: Text(
                            '${widget.p.title}',
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                        ),
                        Text(
                          '${widget.p.description}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey),
                        ),
                        InSectionSpacing(),
                        Column(
                          children: <Widget>[
                            Text(
                                '₹ ' +
                                    (widget.p.price -
                                            (widget.p.price *
                                                widget.p.discount /
                                                100))
                                        .toString(),
                                style: widget.custom.cardTitleTextStyle),
                            widget.p.discount > 0
                                ? Text('₹ ' + widget.p.price.toString(),
                                    style: TextStyle(
                                        fontSize: 14,
                                        decoration: TextDecoration.lineThrough))
                                : Text(""),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            buildRaisedButton("Add to Cart", Colors.white,
                                Theme.of(context).primaryColor, () {
                              handleCart(widget.p, context);
                            }),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: IconButton(
                                        icon: fav
                                            ? Icon(
                                                FontAwesome.heart,
                                                size: 15,
                                                color: Colors.red,
                                              )
                                            : Icon(
                                                FontAwesome.heart_o,
                                                size: 15,
                                                color: Colors.red,
                                              ),
                                        onPressed: () {
                                          fav = !fav;
                                          handleAddToWishlist(
                                              widget.p.id.toString(), fav);
                                          print(fav);
                                        }),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
