import 'package:flutter/material.dart';
import 'package:toys/models/userModel.dart';
import 'package:toys/widgets/SectionTitle.dart';
import 'package:toys/widgets/home_page_carousel.dart';
import 'package:toys/widgets/in_section_spacing.dart';
import 'package:toys/widgets/product_carousel.dart';
import 'package:toys/widgets/section_spacing.dart';

class HomePage extends StatefulWidget {
  User details;
  HomePage({this.details});
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
          SectionTitle("Best Sellers"),
          InSectionSpacing(),
          HomePageCarousel(),
          SectionSpacing(),
          SectionTitle("Top Products"),
          InSectionSpacing(),
          ProductCarousel()
        ],
      ),
    ));
  }
}
