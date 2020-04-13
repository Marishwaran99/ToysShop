import 'package:flutter/material.dart';
import 'package:toys/models/product.dart';
import 'package:toys/pages/product_detail_page.dart';

// class Product{
//   String img, discount, url;
//   Product(this.img, this.discount);
// }
class HomePageCarousel extends StatefulWidget {
  @override
  _HomePageCarouselState createState() => _HomePageCarouselState();
}

class _HomePageCarouselState extends State<HomePageCarousel> {
  var _activeSlideIndex = 0;
  List<Product> productsList;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    productsList = [
      Product(
        1,
        'Octopus Shootout',
        "This game is a BLAST times EIGHT! High energy, frenetic gameplay lets you and your opponent take control of your Octopus and spin them frantically back and forth as you try to score more balls into your opponents goal. Don't let your guard down and let octopus spin out of control! Highest score WINS!",
        0,
        20,
        'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products26530-640x640-1897818831.jpg',
        5000,
        "",
      ),
      Product(
        2,
        'Osmo Little Genius Starter Kit for iPad',
        "Osmo learning games makes it fun for children to learn, using Toys as Teaching Tools. Osmo is Magic! In 2013, Osmo created a fun-filled & award winning learning games that interact with actual hand held pieces & an iPad Tablet, bringing a child's game pieces & actions to life (No WiFi necessary for game play). Osmo merges tactile exploration with innovative technology, actively engaging children in the learning process. Osmo games develop a wide range of skills, varying skills based on each game, including creativity, problem-solving, confidence gaining, child-led, hands-on, gender-neutral, curriculum inclusion, social/emotional skills, STEM/STEAM (Science, Technology, Engineering Math & Art) and many more educational capabilities. Games are designed for children between the ages of 3-5+ and include beginner to expert levels. OSMO enables the continuation of learning. Parents can track game progress, using child game profiles, on a parent app. Little Genius Starter Kit focuses on the following game play: Preschool letter formation (ABCs), create pictures with sticks/rings (Squiggle Magic), dress/feed a character (Costume Party) & bring animals to life enabling problem solving, learning of letters & creativity (Stories).",
        20,
        20,
        'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products27129-640x640-179261172.jpg',
        2200,
        "",
      ),
      Product(
        3,
        'Globber Elite Deluxe Light Up Wheels',
        "The Elite Deluxe is a 3-wheel scooter with a 4-height adjustable T-bar, ergonomic bi-injection TPR handlebar grips and a strong aluminium column for maximum comfort and durability. Patented & safe elliptic folding system to easily store. Effortlessly drag the scooter behind you when not in use thanks to trolley mode. Easily place both feet on our extra-wide reinforced deck for more comfort, which supports up to 50kg. 125mm & 30mm extra-wide PU casted battery-free LED wheels flash in white thanks to dynamo lighting integrated in the wheels' core. The battery-powered deck flashes in red, blue & green for more fun!",
        0,
        20,
        'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products24313-640x640-81332367.jpg',
        1000,
        "",
      ),
      Product(
        4,
        'Razor A Scooter',
        "he one, the only, the classic! The folding frame and cool colour options make this the entry-level scooter of choice (for an amazing price!)",
        40,
        20,
        'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products9241-640x640-1056815336.jpg',
        2700,
        "",
      ),
      Product(
        5,
        '4M Race Car Kit',
        'Be a young mechanical engineer! Learn how the motor works by exploring important mechanisms like pivots, linkages and levers. Connect the circuit to build this amazing Race Car with a sturdy, lightweight and colourful body. Make it your very first project in mechanical science!.Includes a set of pre-cut colourful foam boards, a set of plastic cases, gears and wheels, a motor, a screw, stickers and detailed instructions.',
        0,
        20,
        'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products4794-640x640-279278361.jpg',
        1200,
        "",
      ),
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        height: 250,
        child: productsList != null
            ? Stack(
                children: <Widget>[
                  PageView.builder(
                      itemCount: productsList.length,
                      onPageChanged: (i) {
                        setState(() {
                          _activeSlideIndex = i;
                        });
                      },
                      itemBuilder: (BuildContext ctx, int i) {
                        return ProductCard(productsList[i]);
                      }),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: productsList.map((m) {
                            var i = productsList.indexOf(m);
                            return Container(
                                alignment: Alignment.center,
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: _activeSlideIndex == i
                                      ? Colors.black87
                                      : Colors.black45,
                                ));
                          }).toList(),
                        ),
                      ))
                ],
              )
            : Center(child: CircularProgressIndicator()));
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  ProductCard(this.product);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext ctx) {
          return ProductPageDetailPage(product, "user");
        }));
      },
      child: Stack(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                      image: NetworkImage(product.thumbnailImage)))),
          product.discount > 0
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(32)),
                      child: Center(
                        child: Text(
                          product.discount.toString() + "% OFF",
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )))
              : Container()
        ],
      ),
    );
  }
}
