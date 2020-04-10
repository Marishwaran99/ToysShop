import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toys_shop/models/user_details.dart';
import 'package:toys_shop/styles/custom.dart';
import 'package:toys_shop/widgets/SectionTitle.dart';
import 'package:toys_shop/widgets/in_section_spacing.dart';
import 'package:toys_shop/widgets/section_spacing.dart';

import 'home_page.dart';

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
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("LOGOUT",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              )),
          content: Text("Are you sure want to logout?"),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "YES",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                _logout();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("NO", style: TextStyle(color: Colors.black)),
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
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  Widget _buildUsername() {
    return TextFormField(
      controller: userNameController,
      decoration: InputDecoration(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email Address',
          style: Custom().inputLabelTextStyle,
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
          child: TextFormField(
            controller: emailController,
            decoration: InputDecoration(
                hintText: 'you@gmail.com', border: InputBorder.none),
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
          ),
        ),
      ],
    );
  }

  Widget _buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: Custom().inputLabelTextStyle,
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
          child: TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
                hintText: 'Your Password', border: InputBorder.none),
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
          ),
        ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Login",
              style: Custom().headlineTextStyle,
            ),
            SectionSpacing(),
            Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildEmail(),
                    InSectionSpacing(),
                    _buildPassword(),
                    SectionSpacing(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlatButton(
                          color: Colors.black87,
                          textColor: Colors.white,
                          onPressed: signIn,
                          child: Text(
                            "Login",
                            style: Custom().buttonTextStyle,
                          ),
                        ),
                        FlatButton(
                            textColor: Colors.grey,
                            onPressed: () {
                              print("Forget Password");
                            },
                            child: Text("Forget Password ?",
                                style: Custom().buttonTextStyle)),
                      ],
                    ),
                    InSectionSpacing(),
                    Text(
                      "OR",
                      style: Custom().bodyTextStyle,
                    ),
                    InSectionSpacing(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: FlatButton(
                          color: Colors.grey[200],
                          onPressed: () => _signIn(context)
                              .then((user) => print(user))
                              .catchError((onError) => print("Error:$onError")),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Login using Google",
                                  style: Custom().buttonTextStyle),
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
                  style: Custom().bodyTextStyle,
                ),
                SizedBox(width: 8),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        isNew = true;
                      });
                    },
                    child: Text("Sign Up", style: Custom().buttonTextStyle))
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
    return isNew ? signUp() : login();
  }
}
