import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:toys_shop/models/product.dart';
import 'package:toys_shop/pages/product_detail_page.dart';
import 'package:toys_shop/styles/custom.dart';
import 'package:toys_shop/widgets/in_section_spacing.dart';



class ProductCarousel extends StatefulWidget {
  @override
  _ProductCarouselState createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  List<Product> productsList;

  getData() async{
    productsList = [
      Product(1, 
      'Octopus Shootout',
      "This game is a BLAST times EIGHT! High energy, frenetic gameplay lets you and your opponent take control of your Octopus and spin them frantically back and forth as you try to score more balls into your opponents goal. Don't let your guard down and let octopus spin out of control! Highest score WINS!",
      0,
            'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products26530-640x640-1897818831.jpg'
,
      5000,),
      
      Product(2, 
      'Osmo Little Genius Starter Kit for iPad',
      "Osmo learning games makes it fun for children to learn, using Toys as Teaching Tools. Osmo is Magic! In 2013, Osmo created a fun-filled & award winning learning games that interact with actual hand held pieces & an iPad Tablet, bringing a child's game pieces & actions to life (No WiFi necessary for game play). Osmo merges tactile exploration with innovative technology, actively engaging children in the learning process. Osmo games develop a wide range of skills, varying skills based on each game, including creativity, problem-solving, confidence gaining, child-led, hands-on, gender-neutral, curriculum inclusion, social/emotional skills, STEM/STEAM (Science, Technology, Engineering Math & Art) and many more educational capabilities. Games are designed for children between the ages of 3-5+ and include beginner to expert levels. OSMO enables the continuation of learning. Parents can track game progress, using child game profiles, on a parent app. Little Genius Starter Kit focuses on the following game play: Preschool letter formation (ABCs), create pictures with sticks/rings (Squiggle Magic), dress/feed a character (Costume Party) & bring animals to life enabling problem solving, learning of letters & creativity (Stories)."
      ,20,
    'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products27129-640x640-179261172.jpg', 

      2200,),Product(3, 
      'Globber Elite Deluxe Light Up Wheels',
      "The Elite Deluxe is a 3-wheel scooter with a 4-height adjustable T-bar, ergonomic bi-injection TPR handlebar grips and a strong aluminium column for maximum comfort and durability. Patented & safe elliptic folding system to easily store. Effortlessly drag the scooter behind you when not in use thanks to trolley mode. Easily place both feet on our extra-wide reinforced deck for more comfort, which supports up to 50kg. 125mm & 30mm extra-wide PU casted battery-free LED wheels flash in white thanks to dynamo lighting integrated in the wheels' core. The battery-powered deck flashes in red, blue & green for more fun!",
      0,
      'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products24313-640x640-81332367.jpg',
      1000,),
      Product(4, 
      'Razor A Scooter',
      "he one, the only, the classic! The folding frame and cool colour options make this the entry-level scooter of choice (for an amazing price!)",
      40,
      'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products9241-640x640-1056815336.jpg',
      2700,),
      Product(5, 
      '4M Race Car Kit',
      'Be a young mechanical engineer! Learn how the motor works by exploring important mechanisms like pivots, linkages and levers. Connect the circuit to build this amazing Race Car with a sturdy, lightweight and colourful body. Make it your very first project in mechanical science!.Includes a set of pre-cut colourful foam boards, a set of plastic cases, gears and wheels, a motor, a screw, stickers and detailed instructions.',
      0,
      'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products4794-640x640-279278361.jpg', 
      1200,),
      
      ];
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
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext ctx){
          return ProductPageDetailPage(_product)
        
      ;}));
      },
          child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        margin: EdgeInsets.only(right:16),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(children: <Widget>[
              Container(
              height:150,
              decoration:BoxDecoration(
                color: Colors.white,
                image: DecorationImage(fit: BoxFit.contain, image: NetworkImage(_product.thumbnailImage))
              )
            ), _product.discount > 0 ?
          Align(
            alignment:Alignment.topLeft,
            child:Container(width: 56, height: 56, 
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius:BorderRadius.circular(32)
              
            ), child: Center(child:Text(_product.discount.toString() + "% OFF",style: TextStyle(fontSize:10, fontWeight:FontWeight.bold), ),))
          ):Container()],)
            ,
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
            Text(_product.title, style: custom.cardTitleTextStyle,),
            SizedBox(height:16),
            Text("₹ " + _product.price.toString(), style: custom.bodyTextStyle,),
            SizedBox(height:8),
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: (){},)
              ],)
            )
            
          ],
        )
      ),
    );
  }
}