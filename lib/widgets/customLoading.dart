import 'package:flutter/material.dart';

circularProgress(BuildContext context){
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10),
    child: Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
      ),
    ),
  );
}

linearProgress(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(bottom: 10),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation( Theme.of(context).primaryColor),
    ),
  );
}