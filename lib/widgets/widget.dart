import 'package:flutter/material.dart';

Future<void> buildErrorDialog(String message, BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Error",
            style: TextStyle(
              color: Colors.red,
            )),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text("Ok", style: TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
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

Future<void> buildSuccessDialog(String message, BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Success",
            style: TextStyle(
              color: Colors.green,
            )),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text("Ok", style: TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

GestureDetector _buildGestureDetector(BuildContext context, String text,
      GestureTapCallback onPressed, IconData icon) {
    return GestureDetector(
        onTap: onPressed,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 18,
                ),
                SizedBox(width: 10),
                Text(
                  text,
                  style: Theme.of(context).textTheme.title,
                ),
              ],
            ),
          ),
        ));
  }
