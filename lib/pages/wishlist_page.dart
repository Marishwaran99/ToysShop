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

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Product> productsList = [
    Product(
      101,
      'Octopus Shootout',
      "This game is a BLAST times EIGHT! High energy, frenetic gameplay lets you and your opponent take control of your Octopus and spin them frantically back and forth as you try to score more balls into your opponents goal. Don't let your guard down and let octopus spin out of control! Highest score WINS!",
      0,
      'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products26530-640x640-1897818831.jpg',
      5000,
    ),
    Product(
      102,
      'Osmo Little Genius Starter Kit for iPad',
      "Osmo learning games makes it fun for children to learn, using Toys as Teaching Tools. Osmo is Magic! In 2013, Osmo created a fun-filled & award winning learning games that interact with actual hand held pieces & an iPad Tablet, bringing a child's game pieces & actions to life (No WiFi necessary for game play). Osmo merges tactile exploration with innovative technology, actively engaging children in the learning process. Osmo games develop a wide range of skills, varying skills based on each game, including creativity, problem-solving, confidence gaining, child-led, hands-on, gender-neutral, curriculum inclusion, social/emotional skills, STEM/STEAM (Science, Technology, Engineering Math & Art) and many more educational capabilities. Games are designed for children between the ages of 3-5+ and include beginner to expert levels. OSMO enables the continuation of learning. Parents can track game progress, using child game profiles, on a parent app. Little Genius Starter Kit focuses on the following game play: Preschool letter formation (ABCs), create pictures with sticks/rings (Squiggle Magic), dress/feed a character (Costume Party) & bring animals to life enabling problem solving, learning of letters & creativity (Stories).",
      20,
      'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products27129-640x640-179261172.jpg',
      2200,
    ),
    Product(
      103,
      'Globber Elite Deluxe Light Up Wheels',
      "The Elite Deluxe is a 3-wheel scooter with a 4-height adjustable T-bar, ergonomic bi-injection TPR handlebar grips and a strong aluminium column for maximum comfort and durability. Patented & safe elliptic folding system to easily store. Effortlessly drag the scooter behind you when not in use thanks to trolley mode. Easily place both feet on our extra-wide reinforced deck for more comfort, which supports up to 50kg. 125mm & 30mm extra-wide PU casted battery-free LED wheels flash in white thanks to dynamo lighting integrated in the wheels' core. The battery-powered deck flashes in red, blue & green for more fun!",
      0,
      'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products24313-640x640-81332367.jpg',
      1000,
    ),
    Product(
      104,
      'Razor A Scooter',
      "he one, the only, the classic! The folding frame and cool colour options make this the entry-level scooter of choice (for an amazing price!)",
      40,
      'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products9241-640x640-1056815336.jpg',
      2700,
    ),
    Product(
      105,
      '4M Race Car Kit',
      'Be a young mechanical engineer! Learn how the motor works by exploring important mechanisms like pivots, linkages and levers. Connect the circuit to build this amazing Race Car with a sturdy, lightweight and colourful body. Make it your very first project in mechanical science!.Includes a set of pre-cut colourful foam boards, a set of plastic cases, gears and wheels, a motor, a screw, stickers and detailed instructions.',
      0,
      'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products4794-640x640-279278361.jpg',
      1200,
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
    return Scaffold(
        appBar: MyAppBar(
          back: true,
        ),
        body: SingleChildScrollView(
            child: Container(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SectionTitle('Wishlist'),
                ),
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
                if (wish.productId == p.id) {
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
                            .removeWhere((w) => w.productId == p.id);
                        setState(() {});
                      }
                    })
                  : Container();
            }).toList()),
          ],
        ))));
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
                      image: NetworkImage(_product.thumbnailImage))),
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
