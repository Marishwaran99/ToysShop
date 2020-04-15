import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toys_shop/dbhelpers/wishlist_dbhelper.dart';
import 'package:toys_shop/models/product.dart';
import 'package:toys_shop/models/wishlist.dart';
import 'package:toys_shop/styles/custom.dart';
import 'package:toys_shop/widgets/SectionTitle.dart';
import 'package:toys_shop/widgets/appbar.dart';
import 'package:toys_shop/widgets/in_section_spacing.dart';

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  List<Product> productsList = [
    Product(
      productId: '101',
      title: 'Octopus Shootout',
      description:
          "This game is a BLAST times EIGHT! High energy, frenetic gameplay lets you and your opponent take control of your Octopus and spin them frantically back and forth as you try to score more balls into your opponents goal. Don't let your guard down and let octopus spin out of control! Highest score WINS!",
      thumbnailImage: {
        'image':
            'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products26530-640x640-1897818831.jpg',
        'id': '1234'
      },
      price: 5000,
    ),
    Product(
      productId: '102',
      title: 'Octopus Shootout',
      description:
          "This game is a BLAST times EIGHT! High energy, frenetic gameplay lets you and your opponent take control of your Octopus and spin them frantically back and forth as you try to score more balls into your opponents goal. Don't let your guard down and let octopus spin out of control! Highest score WINS!",
      discount: 20,
      thumbnailImage: {
        'image':
            'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products26530-640x640-1897818831.jpg',
        'id': '1234'
      },
      price: 2200,
    ),
    Product(
      productId: '103',
      title: 'Octopus Shootout',
      description:
          "This game is a BLAST times EIGHT! High energy, frenetic gameplay lets you and your opponent take control of your Octopus and spin them frantically back and forth as you try to score more balls into your opponents goal. Don't let your guard down and let octopus spin out of control! Highest score WINS!",
      thumbnailImage: {
        'image':
            'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products26530-640x640-1897818831.jpg',
        'id': '1234'
      },
      price: 1000,
    ),
  ];

  List<Wishlist> inwishlistProductIds;
  var _dbhelper = WishlistDBHelper();
  Custom custom = Custom();
  @override
  Widget build(BuildContext context) {
    if (inwishlistProductIds == null) {
      inwishlistProductIds = List<Wishlist>();
      updateWishlist();
    }
    return SingleChildScrollView(
        child: Container(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SectionTitle('Wishlist'),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FlatButton(
                  onPressed: () {
                    for (var p in inwishlistProductIds) {
                      _dbhelper.deleteWishlist(p.id);
                      inwishlistProductIds = [];
                      setState(() {});
                    }
                  },
                  child: Text('Clear All')),
            )
          ],
        ),
        Column(
            children: productsList.map((p) {
          var w = false;
          var id;
          for (var wish in inwishlistProductIds) {
            log(wish.productId.toString());
            if (wish.productId == p.productId) {
              w = true;
              id = wish.id;
              setState(() {});
            }
          }
          return w
              ? WishlistProduct(p, () {
                  if (id != null) {
                    _dbhelper.deleteWishlist(id);
                    inwishlistProductIds
                        .removeWhere((w) => w.productId == p.productId);
                    setState(() {});
                  }
                })
              : Container();
        }).toList()),
      ],
    )));
  }

  void updateWishlist() {
    Future<Database> dbFuture = _dbhelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Wishlist>> wishlistFuture = _dbhelper.getWishlist();
      wishlistFuture.then((wishlists) {
        setState(() {
          inwishlistProductIds.addAll(wishlists);
          log(inwishlistProductIds.toString());
        });
      });
    });
  }
}

class WishlistProduct extends StatefulWidget {
  final Product product;
  final GestureTapCallback onPressed;
  WishlistProduct(this.product, this.onPressed);
  @override
  _WishlistProductState createState() =>
      _WishlistProductState(this.product, this.onPressed);
}

class _WishlistProductState extends State<WishlistProduct> {
  Product _product;
  GestureTapCallback _onPressed;
  _WishlistProductState(this._product, this._onPressed);
  Custom custom = Custom();
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey[100],
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 150,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(_product.thumbnailImage['image']))),
            ),
            SizedBox(width: 8),
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width -
                          MediaQuery.of(context).size.width * 0.4 -
                          40,
                      child: Text(_product.title, style: custom.bodyTextStyle)),
                  InSectionSpacing(),
                  Text('₹ ' + _product.price.toString(),
                      style: custom.cardTitleTextStyle),
                  SizedBox(height: 8),
                  IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.black26,
                      ),
                      onPressed: _onPressed)
                ])
          ],
        ));
  }
}
