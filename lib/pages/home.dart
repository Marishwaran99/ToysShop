import 'package:flutter/material.dart';
import 'package:toys/widgets/item.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: ClampingScrollPhysics(),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Text("Today's  Pick", style: Theme.of(context).textTheme.headline),
                ),
              ),
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: PageView(
                  controller: PageController(viewportFraction: 0.9),
                  scrollDirection: Axis.horizontal,
                  pageSnapping: true,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        child: Image.asset('assets/images/toys.jpg'),
                      )
                          
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        child: Image.asset('assets/images/toys.jpg'),
                      )
                          
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        child: Image.asset('assets/images/toys.jpg'),
                      )
                          
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Text("Products", style: Theme.of(context).textTheme.headline ),
                ),
              ),
              Container(
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 8.0, // gap between adjacent chips
                  runSpacing: 8.0, // gap between lines
                  children: <Widget>[
                    Item(),
                    Item(),
                    Item(),
                    Item(),
                    Item(),
                    Item()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
