import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:toys/widgets/customLoading.dart';

class ViewImage extends StatefulWidget {
  String image;
  ViewImage({this.image});

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: PhotoView(imageProvider: NetworkImage(widget.image), enableRotation: true,backgroundDecoration: BoxDecoration(
        color: Colors.white
      ),
      loadingChild: Center(
        child: circularProgress(context),
      ),
      
      ),
    );
  }
}
