import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toys_shop/models/user.dart';
import 'package:toys_shop/models/wishlist.dart';
import 'package:toys_shop/pages/edit_profile_page.dart';
import 'package:toys_shop/pages/wishlist_page.dart';
import 'package:toys_shop/services/auth.dart';
import 'package:toys_shop/services/datastore.dart';
import 'package:toys_shop/styles/custom.dart';
import 'package:toys_shop/widgets/SectionTitle.dart';
import 'package:toys_shop/widgets/in_section_spacing.dart';
import 'package:toys_shop/widgets/section_spacing.dart';

class ProfilePage extends StatefulWidget {
  final Auth auth;
  final Datastore datastore;
  final VoidCallback logoutCallback;
  ProfilePage({this.auth, this.datastore, this.logoutCallback});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Custom custom = Custom();
  Map<String, dynamic> userData;
  String uid;
  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  getProfileData() async {
    FirebaseUser user = await widget.auth.getCurrentUser();
    log(user.email);
    if (user != null) userData = await widget.datastore.getUserData(user.uid);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      child: userData != null
          ? Column(children: [
              Container(
                padding: EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InSectionSpacing(),
                      Row(
                        children: <Widget>[
                          Container(
                              width: 64,
                              height: 64,
                              child: Center(
                                  child: Text(
                                userData["name"].toString().substring(0, 1),
                                style: Custom().titleTextStyle,
                              )),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(64),
                                //border: Border.all(color: Colors.black, width: 4),
                                color: Colors.grey[100],
                              )),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                userData["name"],
                                style: custom.cardTitleTextStyle,
                              ),
                              SizedBox(height: 4),
                              Text(
                                userData["email"],
                                style: custom.bodyTextStyle,
                              )
                            ],
                          )
                        ],
                      ),
                      SectionSpacing(),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ActionCard(Icons.list, "Orders", () {}),
                          ActionCard(Icons.edit, "Edit", () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (BuildContext ctx) {
                              return EditProfilePage(
                                  auth: widget.auth,
                                  datastore: widget.datastore);
                            }));
                          }),
                          ActionCard(CupertinoIcons.heart_solid, "Wishlist",
                              () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (BuildContext ctx) {
                              return WishlistPage();
                            }));
                          }),
                          ActionCard(Icons.exit_to_app, "Logout", () {
                            widget.auth.signOut();
                            widget.logoutCallback();
                          }),
                        ],
                      ),
                      SectionSpacing(),
                      SectionTitle('Shopping Information'),
                      InSectionSpacing(),
                      Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            ActionCardWithValue(
                                Icons.credit_card, "Pending Payment", 5, () {}),
                            ActionCardWithValue(
                                Icons.warning, "To be shipped", 5, () {}),
                          ]),
                      InSectionSpacing(),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ActionCardWithValue(Icons.airport_shuttle,
                              "To be Delivered", 5, () {}),
                          ActionCardWithValue(
                              Icons.replay, "Replace/Return", 0, () {}),
                        ],
                      ),
                    ]),
              )
            ])
          : Center(child: CircularProgressIndicator()),
    ));
  }
}

class ActionCardWithValue extends StatelessWidget {
  final IconData icon;
  final String title;
  final int val;
  final GestureTapCallback onPressed;

  ActionCardWithValue(this.icon, this.title, this.val, this.onPressed);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5 - 24,
        height: 125,
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon),
              SizedBox(height: 8),
              Text(
                title,
                style: Custom().bodyTextStyle,
              ),
              SizedBox(height: 8),
              Text(
                val.toString(),
                style: Custom().cardTitleTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final GestureTapCallback onPressed;

  ActionCard(this.icon, this.title, this.onPressed);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 48,
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
        child: Center(
          child: Icon(icon),
        ),
      ),
    );
  }
}
