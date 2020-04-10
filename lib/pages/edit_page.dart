import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:toys/models/userDetails.dart';
import 'package:toys/widgets/appbar.dart';

class EditPage extends StatefulWidget {
  UserDetails details;
  EditPage({this.details});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String _username;

  @override
  Widget build(BuildContext context) {
    TextEditingController userNameController =
        TextEditingController(text: widget.details.userName == null ? "Your name" : widget.details.userName );

    Widget _buildUsername() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: userNameController,
          // decoration: InputDecoration(
          // //     icon: Icon(
          // //   FontAwesome.user,
          // //   size: 18,
          // // )
          // ),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Username is Required';
            }
            return null;
          },
          onSaved: (String value) {
            _username = value;
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "TOYS",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              letterSpacing: 2,
              fontSize: 24),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Ionicons.ios_arrow_back,
            color: Theme.of(context).primaryColor,
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Container(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          children: <Widget>[
            buildText("Edit Profile",  Colors.black54),
            SizedBox(height:10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildText("Profile Picture", Colors.black),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 35,
                        backgroundImage:
                            CachedNetworkImageProvider(widget.details.photoUrl),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      buildRaisedButton(
                          "Upload New Picture", Colors.black, Colors.white, () {
                        print("New Picture");
                      }),
                      SizedBox(
                        width: 10,
                      ),
                      buildRaisedButton("Delete", Colors.white, Colors.black,
                          () {
                        print("Delete Picture");
                      }),
                    ],
                  ),
                  SizedBox(height: 20),
                  buildText("Username", Colors.black87),
                  SizedBox(height: 10),
                  _buildUsername(),
                  SizedBox(height: 20),
                ],
              ),
            ),

            SizedBox(height:20),
            buildText("Address",  Colors.black54),
            SizedBox(height:10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildText("Location", Colors.black),
                  SizedBox(height: 10),
                  _buildUsername(),
                  SizedBox(height: 20),
                  buildText("State", Colors.black),
                  SizedBox(height: 10),
                  _buildUsername(),
                  SizedBox(height: 20),
                ],
              ),
            ),
            
            
            SizedBox(height:20),
            buildText("Change Password",  Colors.black54),
            SizedBox(height:10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildText("Current Password", Colors.black),
                  SizedBox(height: 10),
                  _buildUsername(),
                  SizedBox(height: 20),
                  buildText("New Password", Colors.black),
                  SizedBox(height: 10),
                  _buildUsername(),
                  SizedBox(height: 10),
                  buildText("Confirm Password", Colors.black),
                  SizedBox(height: 10),
                  _buildUsername(),
                  SizedBox(height: 20),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Text buildText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
          letterSpacing: 1, fontSize: 20,color: color, fontWeight: FontWeight.bold),
    );
  }

  RaisedButton buildRaisedButton(String text, Color buttonColor, Color color,
      GestureTapCallback onPressed) {
    return RaisedButton(
      onPressed: onPressed,
      color: buttonColor,
      child: Text(
        text,
        style: TextStyle(color: color),
      ),
    );
  }
}
