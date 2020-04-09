import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toys/main.dart';
import 'package:toys/models/userDetails.dart';

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
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(details: details,)));
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
    return Column(
      children: <Widget>[
        Text(widget.details.userName),
      ],
    );
  }

  Widget login() {
    return Container(
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
                                  color: Theme.of(context).primaryColor),
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
    );
  }

  Widget signUp() {
    return Container(
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
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: widget.details != null ? buildAuthScreen() : isNew ? signUp() : login());
  }
}
