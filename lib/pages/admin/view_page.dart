import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toys/models/product.dart';
import 'package:toys/models/user.dart';
import 'package:toys/pages/admin/update_page.dart';
import 'package:toys/pages/product_detail_page.dart';
import 'package:toys/styles/custom.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:toys/widgets/customLoading.dart';
import 'package:toys/widgets/in_section_spacing.dart';
import 'package:toys/widgets/product_card.dart';
import 'package:toys/widgets/widget.dart';

class ViewPage extends StatefulWidget {
  User currentUser;
  String isUpdate;
  ViewPage({this.currentUser, this.isUpdate});

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  Custom custom = Custom();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        text: 'Toys',
        back: true,
      ),
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
                ProductList product = ProductList.fromDocument(snapshot.data.documents[index]);
                print(product.previewImages);
                return snapshot.data.documents.length == 0
                    ? Center(child: Text("U have Not Yet Uploaded"))
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        ProductCard(product, "admin", false),
                        widget.isUpdate == 'true' ? Padding(
                          padding: const EdgeInsets.only(right: 28.0),
                          child: buildRaisedButton("Update Now", Theme.of(context).primaryColor, Colors.white, (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePage(currentUser: widget.currentUser, product: product,)));
                          }),
                        ):Container()
                      ],
                    );
              },
            );
          }),
    );
  }
}
