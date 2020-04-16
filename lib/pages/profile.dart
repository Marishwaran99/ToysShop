import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toys/main.dart';
import 'package:toys/models/user.dart';
import 'package:toys/pages/admin/admin_page.dart';
import 'package:toys/pages/edit_page.dart';
import 'package:toys/pages/forget_password.dart';
import 'package:toys/pages/order.dart';
import 'package:toys/pages/view_image.dart';
import 'package:toys/widgets/customLoading.dart';
import 'package:toys/widgets/widget.dart';

final DateTime timestamp = DateTime.now();
final GoogleSignIn _googleSignIn = new GoogleSignIn();
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  User details;
  LoginPage({Key key, this.details}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthResult authResult;
  bool _loading = true;
  bool isNew = false;
  bool isAuth = false;
  String _username;
  String _password;
  String _email;
  String errorMessage;
  User currentUser;

  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> getCurrentUserInfo() async {
    if (widget.details != null) {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      print(user.uid);
      DocumentSnapshot doc =
          await Firestore.instance.collection('users').document(user.uid).get();
      // print(doc.data);
      User details = User.fromFirestore(doc);
      setState(() {
        currentUser = details;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
    print(currentUser.role);
    QuerySnapshot snapshots = await Firestore.instance
        .collection('orders')
        .where('userId', isEqualTo: currentUser.uid)
        .getDocuments();
    setState(() {
      _orderCount = snapshots.documents.length;
    });
    print(_orderCount);
  }

  int _orderCount = 0;

  @override
  void initState() {
    super.initState();
    getCurrentUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? circularProgress(context)
        : currentUser != null ? buildAuthScreen() : isNew ? signUp() : login();
  }

  //Username TextField
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

  //Email TextField
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

  //Password TextField
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

  //After Login Screen
  Widget buildAuthScreen() {
    return ListView(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          // color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(70)),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewImage(
                                            image: currentUser.photoUrl,
                                          )));
                            },
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              backgroundImage: currentUser.photoUrl == ""
                                  ? AssetImage('assets/images/unknown-user.png')
                                  : CachedNetworkImageProvider(
                                      currentUser.photoUrl),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              currentUser.username,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2),
                            ),
                            Text(currentUser.userEmail),
                          ],
                        ),
                      ],
                    ),
                    currentUser.role != 'admin'
                        ? Text("")
                        : GestureDetector(
                            child: Icon(
                              Ionicons.ios_person,
                              color: Theme.of(context).primaryColor,
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AdminPage(
                                            currentUser: currentUser,
                                          )));
                            },
                          )
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        ActionCard(Icons.list, "Orders", () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Order(
                                        currentUser: currentUser,
                                      )));
                        }),
                        _orderCount == 0
                            ? Text('')
                            : Padding(
                                padding: const EdgeInsets.only(left: 50),
                                child: Container(
                                  width: 15,
                                  height: 15,
                                  alignment: Alignment.center,
                                  // padding: EdgeInsets.symmetric(
                                  //     horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    _orderCount.toString(),
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                      ],
                    ),
                    Stack(
                      children: <Widget>[
                        ActionCard(Icons.edit, "Edit", () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditPage(
                                        details: widget.details,
                                      )));
                        }),
                        currentUser.address != ""
                            ? Text('')
                            : Padding(
                                padding: const EdgeInsets.only(left: 50),
                                child: Container(
                                  width: 15,
                                  height: 15,
                                  alignment: Alignment.center,
                                  // padding: EdgeInsets.symmetric(
                                  //     horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    '!',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                      ],
                    ),
                    ActionCard(CupertinoIcons.heart_solid, "Wishlist", () {}),
                    ActionCard(Icons.exit_to_app, "Logout", () {
                      showAlert(context);
                    }),
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
      ],
    );
  }

  //Login Screen
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgetPassword()));
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
                          onPressed: () => _googleLogin(context),
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

  //SignUp Screen
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyHomePage(
                              details: widget.details,
                            )));
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

  //Logout Function
  _logout() {
    print(currentUser.loginType);
    currentUser.loginType == "google"
        ? _googleSignIn
            .signOut()
            .then((onValue) => print("Successfull"))
            .catchError((onError) => print(onError.message))
        : FirebaseAuth.instance.signOut().then((result) {
            // Sign-out successful.
            print('Signout succesfull!');
          }).catchError((error) {
            // An error happened
            print(error.message);
          });
    // _googleSignIn.signOut();
    setState(() {
      isAuth = false;
      widget.details = null;
      currentUser = null;
    });
  }

  //Logging in
  Future<void> signIn() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        AuthResult userDetails = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        print("Email:${userDetails.user.email}");

        DocumentSnapshot doc = await Firestore.instance
            .collection('users')
            .document(userDetails.user.uid)
            .get();

        User details = User.fromFirestore(doc);

        print("Username:" + details.username);

        setState(() {
          isAuth = true;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyHomePage(
                      details: details,
                    )));
      } catch (error) {
        switch (error.code) {
          case "ERROR_INVALID_EMAIL":
            errorMessage = "Your email address appears to be malformed.";
            buildErrorDialog(errorMessage, context);
            break;
          case "ERROR_WRONG_PASSWORD":
            errorMessage = "Your password is wrong.";
            buildErrorDialog(errorMessage, context);
            break;
          case "ERROR_USER_NOT_FOUND":
            errorMessage = "User with this email doesn't exist.";
            buildErrorDialog(errorMessage, context);
            break;
          case "ERROR_USER_DISABLED":
            errorMessage = "User with this email has been disabled.";
            buildErrorDialog(errorMessage, context);
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            errorMessage = "Too many requests. Try again later.";
            buildErrorDialog(errorMessage, context);
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
            errorMessage = "Signing in with Email and Password is not enabled.";
            buildErrorDialog(errorMessage, context);
            break;
          default:
            errorMessage = "An undefined Error happened.";
            buildErrorDialog(errorMessage, context);
        }
      }
    }
  }

  //Creating User in Firebase
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
                  "displayName": userNameController.text,
                  "email": emailController.text,
                  "photoUrl": "",
                  "address": "",
                  "city": "",
                  "state": "",
                  "pincode": "",
                  "logintype": "signup",
                  "role": "user"
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

  //Google Login
  Future<void> _googleLogin(BuildContext context) async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    AuthResult userDetails =
        await _firebaseAuth.signInWithCredential(credential);

    DocumentSnapshot doc = await Firestore.instance
        .collection("users")
        .document(userDetails.user.uid)
        .get();

    if (!doc.exists) {
      Firestore.instance
          .collection("users")
          .document(userDetails.user.uid)
          .setData({
        "uid": userDetails.user.uid,
        "displayName": userDetails.user.displayName,
        "email": userDetails.user.email,
        "photoUrl": userDetails.user.photoUrl,
        "address": "",
        "city": "",
        "state": "",
        "loginType": "google",
        "role": "user"
      }).catchError((onError) => print(onError));
      DocumentSnapshot doc = await Firestore.instance
          .collection("users")
          .document(userDetails.user.uid)
          .get();
      User details = User.fromFirestore(doc);

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
    } else {
      DocumentSnapshot doc = await Firestore.instance
          .collection("users")
          .document(userDetails.user.uid)
          .get();

      User details = User.fromFirestore(doc);

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
