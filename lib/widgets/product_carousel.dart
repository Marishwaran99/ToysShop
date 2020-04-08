import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:toys_shop/styles/custom.dart';
import 'package:toys_shop/widgets/in_section_spacing.dart';


class Product{
  String img, name,price, incart;

  Product(this.img, this.name, this.price, this.incart);
}
class ProductCarousel extends StatefulWidget {
  @override
  _ProductCarouselState createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  List<Product> productsList;

  

  getData() async{
    var client = Client();
    Response res = await client.get('https://www.mastermindtoys.com/');
    var document = parse(res.body);
    log(document.toString());
    var bestSellerProducts = document.querySelectorAll('.gray-section .product-item');

    for (var bsp in bestSellerProducts){
      var img = bsp.querySelector('.visual-block .product-visual img').attributes["data-lazy"];
      log(img.toString());
      var name = bsp.querySelector('.product-text .product-title').text;
      var price = bsp.querySelector('.price').text.replaceAll('/n', '');
      price = price.replaceAll('\$', '');
      if (productsList == null){
        productsList = [];
      }
      productsList.add(Product(img.toString(), name.trim(), '\$ '+ price.trim(), 'false'));
    }
    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
          margin: EdgeInsets.symmetric(horizontal:16),
          height: 300,
          child: productsList != null ? productsList.length > 0 ? ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: productsList.length,
            itemBuilder: (BuildContext ctx, int i){
            return ProductCard(productsList[i]);
          }):Container() : Center(child: CircularProgressIndicator())
    );
  }
}

class ProductCard extends StatefulWidget {

  final Product product;

  ProductCard(this.product);
  @override
  _ProductCardState createState() => _ProductCardState(this.product);
}

class _ProductCardState extends State<ProductCard> {
  
  Product _product;
  _ProductCardState(this._product);
  Custom custom = Custom();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      margin: EdgeInsets.only(right:16),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height:150,
            decoration:BoxDecoration(
              image: DecorationImage(fit: BoxFit.cover, image: NetworkImage('https:' + _product.img))
            )
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            decoration: BoxDecoration(
              color:Colors.grey[100],
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8),  bottomRight: Radius.circular(8))
            ),
            padding: EdgeInsets.symmetric(horizontal:8),
            child:Column(
              
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InSectionSpacing(),
          Text(_product.name, style: custom.cardTitleTextStyle,),
          SizedBox(height:16),
          Text(_product.price, style: custom.bodyTextStyle,),
          SizedBox(height:8),
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: (){},)
            ],)
          )
          
        ],
      )
    );
  }
}