import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';


class Product{
  String img, discount;
  Product(this.img, this.discount);
}
class HomePageCarousel extends StatefulWidget {
  @override
  _HomePageCarouselState createState() => _HomePageCarouselState();
}
class _HomePageCarouselState extends State<HomePageCarousel> {
  var _activeSlideIndex = 0;
  var pageList=[];
  List<Product> productsList;
  @override
  void initState() {
    super.initState();
    getData();
  }
  getData() async{
    
    var client = Client();
    Response res = await client.get('https://www.mastermindtoys.com/');
    var document = parse(res.body);
    var bestSellerProducts = document.querySelectorAll('.red-section .product-item');

    for (var bsp in bestSellerProducts){
      var img = bsp.querySelector('.visual-block .product-visual img').attributes["data-lazy"];
      var ds = bsp.querySelector('.visual-block .new-label');
      var discount = ds != null ? ds.text : "";
      log(discount);
      if (productsList == null) productsList = [];
      productsList.add(Product(img.toString(), discount.trim()));
    }
    setState(() {
      
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
          margin: EdgeInsets.symmetric(horizontal:16),
          height: 250,
          child: 
          productsList != null ? Stack(children: <Widget>[
            PageView.builder(
            itemCount: productsList.length,
            onPageChanged: (i){
              setState(() {
                _activeSlideIndex = i;
              });
            },
            itemBuilder:(BuildContext ctx, int i){
            return ProductCard(productsList[i]);
          }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(vertical:8),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: pageList.map((m){
              var i = pageList.indexOf(m);
              return Container(alignment: Alignment.center, width: 8, height: 8, margin: EdgeInsets.symmetric(horizontal:4), decoration: BoxDecoration(borderRadius:BorderRadius.circular(12), color: _activeSlideIndex == i ? Colors.black87:Colors.black45,));
          }).toList(),),
            ))
          ],) : Center(child:CircularProgressIndicator())
      
    );
  }
}


class ProductCard extends StatelessWidget {

  final Product product;
  ProductCard(this.product);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width:MediaQuery.of(context).size.width,
          decoration:BoxDecoration(color: Colors.white,image: DecorationImage(image: NetworkImage("https:" + product.img)))
        ),
        product.discount != '' ?
        Align(
          alignment:Alignment.topLeft,
          child:Container(width: 56, height: 56, 
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius:BorderRadius.circular(28)
            
          ), child: Center(child:Text(product.discount,style: TextStyle(fontSize:12, fontWeight:FontWeight.w500), ),))
        ):Container()
      ],
    );
  }
}