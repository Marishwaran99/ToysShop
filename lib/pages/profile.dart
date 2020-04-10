import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toys/main.dart';
import 'package:toys/models/userDetails.dart';
import 'package:toys/pages/home_page.dart';

final DateTime timestamp = DateTime.now();
final GoogleSignIn _googleSignIn = new GoogleSignIn();
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  UserDetails details;
  LoginPage({Key key, this.details}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthResult authResult;
  bool isNew = false;
  bool isAuth = false;
  String _username;
  String _password;
  String _email;

  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _logout() {
    _googleSignIn.signOut();
    setState(() {
      isAuth = true;
      widget.details = null;
    });
  }

  showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
        title: Text("LOGOUT",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            )),
        content: Text("Are you sure want to logout?"),
        actions: <Widget>[
          FlatButton(
            child: Text("YES", style: TextStyle(color: Colors.black),),
            onPressed: () {
              _logout();
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(details: widget.details,)));
            },
          ),
          FlatButton(
            child: Text("NO", style: TextStyle(color:Colors.black)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
      },
    );
  }

  Future<FirebaseUser> _signIn(BuildContext context) async {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text('Sign in'),
    ));

    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    AuthResult userDetails =
        await _firebaseAuth.signInWithCredential(credential);
    ProviderDetails providerInfo =
        new ProviderDetails(userDetails.additionalUserInfo.providerId);

    List<ProviderDetails> providerData = new List<ProviderDetails>();
    providerData.add(providerInfo);

    UserDetails details = new UserDetails(
      userDetails.additionalUserInfo.providerId,
      userDetails.user.displayName,
      userDetails.user.photoUrl,
      userDetails.user.email,
      providerData,
    );

    Firestore.instance
        .collection("users")
        .document(userDetails.user.uid)
        .setData({
      "username": userDetails.user.displayName,
      "email": userDetails.user.email,
      "photoUrl": userDetails.user.photoUrl,
    }).catchError((onError) => print(onError));
    setState(() {
      isAuth = true;
      authResult = userDetails;
    });
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(
                  details: details,
                )));
  }

  Widget _buildUsername() {
    return TextFormField(
      controller: userNameController,
      decoration: InputDecoration(
          labelText: 'Username',
          icon: Icon(
            FontAwesome.user,
            size: 18,
          )),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Username is Required';
        }
        return null;
      },
      onSaved: (String value) {
        _username = value;
      },
    );
  }

  Widget _buildEmail() {
    return TextFormField(
      controller: emailController,
      decoration: InputDecoration(
          labelText: 'Email Address',
          icon: Icon(
            Icons.email,
            size: 18,
          )),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Email is Required';
        }

        if (!RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
          return 'Please enter a valid email Address';
        }

        return null;
      },
      onSaved: (String value) {
        _email = value;
      },
    );
  }

  Widget _buildPassword() {
    return TextFormField(
      controller: passwordController,
      decoration: InputDecoration(
          labelText: 'Password',
          icon: Icon(
            Ionicons.ios_lock,
            size: 18,
          )),
      keyboardType: TextInputType.visiblePassword,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password is Required';
        }
        if (value.length < 6) {
          return 'Your password needs to be atleast 6 character';
        }

        return null;
      },
      onSaved: (String value) {
        _password = value;
      },
      obscureText: true,
    );
  }

  Widget buildAuthScreen() {
    return ListView(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(70)),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage:
                            CachedNetworkImageProvider(widget.details.photoUrl),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.details.userName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        Text(widget.details.userEmail),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Icon(
                          FontAwesome.list_alt,
                          size: 28,
                          color: Colors.white,
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Orders",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Icon(
                          FontAwesome.edit,
                          size: 28,
                          color: Colors.white,
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Edit",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Icon(
                          Ionicons.ios_lock,
                          size: 28,
                          color: Colors.white,
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Change",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Icon(
                          Icons.delete,
                          size: 28,
                          color: Colors.white,
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Delete",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        print("Logout");
                        showAlert(context);
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(
                            FontAwesome.sign_out,
                            size: 28,
                            color: Colors.white,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            itemCard("Pending Payment", 5, Icons.payment),
            itemCard("To be shipped", 3, Ionicons.ios_warning),
            itemCard("To be Received", 8, FontAwesome.truck),
            itemCard("Return / Replace", 0, Icons.assignment_return)
          ],
        ),
        buildListTile("Gift Card", Icons.card_giftcard, Color(0xFFfcd221),
            Color(0xfffff7d6)),
        buildListTile(
            "Favourites", Icons.favorite, Color(0xffFF0000), Color(0xfff5a2a2)),
        buildListTile(
            "Coupon", Icons.card_giftcard, Color(0xff2427ff), Color(0xffadafff))
      ],
    );
  }

  ListTile buildListTile(
      String text, IconData icon, Color color, Color bgColor) {
    return ListTile(
      leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50), color: bgColor),
          child: Icon(
            icon,
            color: color,
          )),
      title: Text(text),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 12,
      ),
    );
  }

  Widget login() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                alignment: Alignment.topLeft,
                child: Text(
                  "LOGIN",
                  style: Theme.of(context).textTheme.headline,
                )),
            SizedBox(height: 20),
            Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildEmail(),
                    _buildPassword(),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        RaisedButton(
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: signIn,
                          child: Text(
                            "LOGIN",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: GestureDetector(
                              onTap: () {
                                print("Forget Password");
                              },
                              child: Text(
                                "Forget Password ?",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 18),
                              )),
                        )
                      ],
                    ),
                    SizedBox(height: 5),
                    Text("OR"),
                    SizedBox(height: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: RaisedButton(
                          color: Color(0xffE3E3E3),
                          elevation: 0,
                          onPressed: () => _signIn(context)
                              .then((user) => print(user))
                              .catchError((onError) => print("Error:$onError")),
                          child: Stack(
                            children: <Widget>[
                              Text(
                                "LOGIN USING ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 90),
                                child: Image.asset(
                                  'assets/images/G.png',
                                  width: 13,
                                ),
                              )
                            ],
                          )),
                    )
                  ],
                )),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Not have an account ? ",
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                SizedBox(width: 10),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        isNew = true;
                      });
                    },
                    child: Text("Sign Up",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget signUp() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                alignment: Alignment.topLeft,
                child: Text(
                  "SIGN UP",
                  style: Theme.of(context).textTheme.headline,
                )),
            SizedBox(height: 20),
            Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildUsername(),
                    _buildEmail(),
                    _buildPassword(),
                    SizedBox(height: 20),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      onPressed: createUser,
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                )),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Already have an account ? ",
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                SizedBox(width: 10),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        isNew = false;
                      });
                    },
                    child: Text("LOGIN",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)))
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> signIn() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        AuthResult authresult = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        print("Token:${authresult.user.email}");
        setState(() {
          isAuth = true;
          authResult = authresult;
        });
      } catch (e) {
        print(e.message);
      }
    }
  }

  Future<void> createUser() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password)
            .then((currentUser) => Firestore.instance
                    .collection("users")
                    .document(currentUser.user.uid)
                    .setData({
                  "uid": currentUser.user.uid,
                  "username": userNameController.text,
                  "email": emailController.text,
                  "photoUrl": "",
                }))
            .then((result) => {
                  emailController.clear(),
                  passwordController.clear(),
                  userNameController.clear(),
                })
            .catchError((onError) => print(onError))
            .catchError((onError) => print(onError));

        setState(() {
          isNew = false;
        });
      } catch (e) {
        print("Error:$e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.details != null
        ? buildAuthScreen()
        : isNew ? signUp() : login();
  }

  Widget itemCard(String text, int number, IconData icon) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
        child: Material(
            borderRadius: BorderRadius.circular(5.0),
            elevation: 3.0,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.45,
                height: 150.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          icon,
                          size: 30,
                        ),
                        SizedBox(height: 7.0),
                        Text(
                          text,
                          style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.grey),
                        ),
                        SizedBox(height: 7.0),
                        Text(
                          number.toString(),
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.red),
                        )
                      ],
                    )
                  ],
                ))));
  }
}
