import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:toys/models/users.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final userRef = Firestore.instance.collection("users");
final DateTime timestamp = DateTime.now();

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

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
  User currentUser;

  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print("Error signing in: $err");
    });
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
      // onChanged: (value) {
      //   // print("Email:" + value)
      // },
    );
  }

  Widget _buildPassword() {
    return TextFormField(
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
        Text(authResult.user.email),
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
                        onPressed: () {
                          print("G");
                        },
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
                    onPressed: () {
                      print(emailController.text);

                      // setState(() {
                      //   isNew = false;
                      // });
                    },
                    child: Text(
                      "SIGN UP",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text("OR"),
                  SizedBox(height: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: RaisedButton(
                        color: Color(0xffE3E3E3),
                        elevation: 0,
                        onPressed: signIn,
                        child: Stack(
                          children: <Widget>[
                            Text(
                              "SIGN UP USING ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 100),
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

  // Future<void> signIn() async {
  //   final formState = _formKey.currentState;
  //   if(formState.validate()){
  //     formState.save();
  //     try{
  //       AuthResult authresult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
  //       print("Token:${authresult.user.email}");
  //       setState(() {
  //         isAuth = true;
  //         authResult = authresult;
  //       });
  //     }catch(e){
  //       print(e.message);
  //     }
  //   }
  // }

  handleSignIn(GoogleSignInAccount account) async {
    await createUserInFirestore();
  }

  createUserInFirestore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.document(user.id).get();

    if (!doc.exists) {
      // final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));

      userRef.document(user.id).setData({
        "id": user.id,
        "username": user.displayName,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });

      doc = await userRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.displayName);
  }

  signIn() async {
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print("Error signing in: $err");
    });
    // await googleSignIn.signIn();

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: isAuth ? buildAuthScreen() : isNew ? signUp() : login());
  }
}
