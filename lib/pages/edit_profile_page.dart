import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toys_shop/services/auth.dart';
import 'package:toys_shop/services/datastore.dart';
import 'package:toys_shop/styles/custom.dart';
import 'package:toys_shop/widgets/appbar.dart';
import 'package:toys_shop/widgets/primary_button.dart';

class EditProfilePage extends StatefulWidget {
  final Datastore datastore;
  final Auth auth;
  EditProfilePage({this.datastore, this.auth});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _usernameTextController = TextEditingController();
  var userData;
  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  getProfileData() async {
    FirebaseUser user = await widget.auth.getCurrentUser();
    log(user.email);
    if (user != null) {
      userData = await widget.datastore.getUserData(user.uid);
      _usernameTextController.text = userData["name"];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(),
        body: Column(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                  child: Column(
                children: <Widget>[
                  _buildUsernameField(),
                  PrimaryButton('Update', () {
                    var name = _usernameTextController.text.trim();
                    if (name.length > 0) {
                      widget.datastore.updateUserData(userData["uid"], name);
                    }
                  })
                ],
              )),
            )
          ],
        ));
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Username",
          style: Custom().bodyTextStyle,
        ),
        SizedBox(height: 4),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextField(
            maxLines: 1,
            maxLength: 30,
            style: Custom().inputTextStyle,
            keyboardType: TextInputType.emailAddress,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: 'yourname'),
            controller: _usernameTextController,
          ),
        )
      ],
    );
  }
}
