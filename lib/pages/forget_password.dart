import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:toys/widgets/widget.dart';

class ForgetPassword extends StatefulWidget {
  ForgetPassword({Key key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  bool isMailEntered = true;
  TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: isMailEntered ? Center(child: Text("Check Your mail")) : buildTextField(),
    );
  }

  Widget _buildEmail() {
    return Form(
      key: _formKey,
      child: TextFormField(
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
      ),
    );
  }

  _handleForgetPassword() async {
    // FirebaseAuth
    if (_formKey.currentState.validate())  {
      _formKey.currentState.save();
      print(_email);
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email).then((value){
        buildSuccessDialog("Email Sent Successful!", context);
        setState(() {
          isMailEntered = true;
        });
      }).catchError((onError){
        buildErrorDialog("Somthing Went wrong! try again", context);

      });
    }
  }

  buildTextField() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Forgot Password  ?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Container(
              child: _buildEmail(),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                buildRaisedButton("<- Back to LOGIN", Colors.white,
                    Theme.of(context).primaryColor, () {
                  Navigator.pop(context);
                }),
                buildRaisedButton("Proceed ->", Theme.of(context).primaryColor,
                    Colors.white, _handleForgetPassword)
              ],
            )
          ],
        ),
      ),
    );
  }
}
