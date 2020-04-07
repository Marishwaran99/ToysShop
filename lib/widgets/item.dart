import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Item extends StatelessWidget {
  const Item({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      color: Color(0xffF6F6F6),
      child: Column(
        children: <Widget>[
          Image.asset('assets/images/toys.jpg'),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 10.0, vertical: 8),
            child: Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Lego",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Text(
                        "₹100",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      )
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Kids love lego lorem ispum...",
                          style: TextStyle(
                              color: Color(0xff595959),
                              fontSize: 16),
                        )),
                  ),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(
                        FontAwesome.cart_arrow_down,
                        size: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                      GestureDetector(
                        onTap: () {
                          print("Buy Now");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(4))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8),
                            child: Text(
                              "Buy Now",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
