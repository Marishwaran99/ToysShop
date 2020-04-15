import 'package:cloud_firestore/cloud_firestore.dart';
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
  User _currentUser;
  getCurrentUserInfo() async {
    DocumentSnapshot doc = await Firestore.instance
        .collection('users')
        .document(widget.details.uid)
        .get();
    // print(doc.data);
    User details = new User(
        doc.data['uid'],
        doc.data['displayName'],
        doc.data['email'],
        doc.data['address'],
        doc.data['city'],
        doc.data['state'],
        doc.data['photoUrl'],
        doc.data['logintype'],
        doc.data['role']);
    // print(details.username);
    setState(() {
      _currentUser = details;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserInfo();
  }
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
          HomePageCarousel(currentUser:_currentUser,),
          SectionSpacing(),
          SectionTitle("Top Products"),
          InSectionSpacing(),
          ProductCarousel(currentUser: _currentUser,)
        ],
      ),
    ));
  }
}
