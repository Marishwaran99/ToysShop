import 'package:flutter/material.dart';
import 'package:toys_shop/services/auth.dart';
import 'package:toys_shop/services/datastore.dart';
import 'package:toys_shop/widgets/SectionTitle.dart';
import 'package:toys_shop/widgets/home_page_carousel.dart';
import 'package:toys_shop/widgets/in_section_spacing.dart';
import 'package:toys_shop/widgets/product_carousel.dart';
import 'package:toys_shop/widgets/section_spacing.dart';

class HomePage extends StatefulWidget {

  final Auth auth;
  final Datastore datastore;

  HomePage({this.auth, this.datastore});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionSpacing(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SectionTitle("Best Sellers"),
          ),
          InSectionSpacing(),
          HomePageCarousel(),
          SectionSpacing(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SectionTitle("Top Products"),
          ),
          InSectionSpacing(),
          ProductCarousel(),
          SectionSpacing()
        ],
      ),
    ));
  }
}
