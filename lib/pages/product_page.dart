import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toys/main.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/userModel.dart';
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
              return BuildProductCard(
                custom: custom,
                p: p,
                currentUser: widget.currentUser,
              );
            }).toList()),
          ],
        )),
      ),
    );
  }
}

class BuildProductCard extends StatelessWidget {
  ProductList p;
  User currentUser;
  BuildProductCard({Key key, @required this.custom, this.p, this.currentUser})
      : super(key: key);

  final Custom custom;
  handleCart(ProductList product, BuildContext context) async {
    print(product.id);
    print(currentUser.uid);
    try {
      QuerySnapshot doc =
          await Firestore.instance.collection('carts').getDocuments();
      print(doc.documents.length);
      bool isInCart = false;
      print(doc.documents.map((f) {
        if (f.data['productId'] == product.id) {
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
          "productId": p.id,
          "quantity": 1,
          "productName": p.title,
          "thumbnailImage": p.thumbnailImage,
          "discount": p.discount,
          "price": p.price,
          "userId": currentUser.uid,
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(details: currentUser,)));
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
      onTap: () {},
      child: Padding(
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
                        image: CachedNetworkImageProvider(p.thumbnailImage))),
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
                          '${p.title}',
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.headline,
                        ),
                      ),
                      Text(
                        '${p.description}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey),
                      ),
                      InSectionSpacing(),
                      Text('₹ ' + p.price.toString(),
                          style: custom.cardTitleTextStyle),
                      buildRaisedButton("Add to Cart", Colors.white,
                          Theme.of(context).primaryColor, () {
                        handleCart(p, context);
                      }),
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
