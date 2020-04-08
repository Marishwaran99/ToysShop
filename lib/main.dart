import 'package:flutter/material.dart';
import 'package:toys_shop/widgets/SectionTitle.dart';
import 'package:toys_shop/widgets/appbar.dart';
import 'package:toys_shop/widgets/home_page_carousel.dart';
import 'package:toys_shop/widgets/in_section_spacing.dart';
import 'package:toys_shop/widgets/product_carousel.dart';
import 'package:toys_shop/widgets/section_spacing.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toys Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Josefin'
      ),
      home: ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  ProductPage({Key key}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child:Container(
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
        )
    ));
  }
}
