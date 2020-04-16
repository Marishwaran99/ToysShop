import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/user.dart';
import 'package:toys/pages/product_detail_page.dart';
import 'package:toys/styles/custom.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:toys/widgets/customLoading.dart';
import 'package:toys/widgets/in_section_spacing.dart';
import 'package:toys/widgets/product_card.dart';

class ViewPage extends StatefulWidget {
  User currentUser;
  ViewPage({this.currentUser});

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  Custom custom = Custom();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('products')
              .where("admin", isEqualTo: widget.currentUser.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            print(snapshot.data.documents.length);
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            if (!snapshot.hasData) {
              return Center(
                child: circularProgress(context),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                // print(snapshot.data.documents[index].data);
                Product product = Product(
                  snapshot.data.documents[index].data['id'],
                  snapshot.data.documents[index].data['title'],
                  snapshot.data.documents[index].data['description'],
                  snapshot.data.documents[index].data['discount'],
                  snapshot.data.documents[index].data['quantity'],
                  snapshot.data.documents[index].data['thumbnailImage'],
                  snapshot.data.documents[index].data['price'],
                  snapshot.data.documents[index].data['adminId'],
                  previewImages: snapshot.data.documents[index].data['previewImages'],
                  stock: snapshot.data.documents[index].data['stock'],
                );
                print(product.previewImages);
                return snapshot.data.documents.length == 0
                    ? Center(child: Text("U have Not Yet Uploaded"))
                    : ProductCard(product, "admin", false);
              },
            );
          }),
    );
  }
}
