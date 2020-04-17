import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:toys/models/user.dart';
import 'package:toys/pages/admin/delete_page.dart';
import 'package:toys/pages/admin/delivered_page.dart';
import 'package:toys/pages/admin/online_transaction.dart';
import 'package:toys/pages/admin/order_page.dart';
import 'package:toys/pages/admin/upload_page.dart';
import 'package:toys/pages/admin/view_page.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:toys/widgets/customLoading.dart';
import 'package:toys/widgets/widget.dart';

class AdminPage extends StatefulWidget {
  User currentUser;
  AdminPage({Key key, this.currentUser}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  TextEditingController emailController = TextEditingController();
  int _orderCount;
  getOrderCount() async {
    QuerySnapshot snapshots =
        await Firestore.instance.collection('orders').getDocuments();

    setState(() {
      _orderCount = snapshots.documents.length;
    });
    print(_orderCount);
  }

  @override
  void initState() {
    super.initState();
    getOrderCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "TOYS",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              letterSpacing: 2,
              fontSize: 24),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.currentUser != null ? DrawerIcon() : null,
        backgroundColor: Colors.white,
        actions: <Widget>[
          _orderCount == 0
              ? Text('')
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderPage(
                                      currentUser: widget.currentUser,
                                    )));
                      },
                      child: Stack(
                        children: <Widget>[
                          Icon(
                            Icons.notifications,
                            color: Colors.grey,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
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
                    ),
                  ),
                )
        ],
      ),
      drawer: widget.currentUser != null
          ? AdminDrawer(
              currentUser: widget.currentUser,
              orderCount: _orderCount,
            )
          : null,
      body: Center(
        child: UserList(),
      ),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _mySelection;
    makeAdmin() async {
      print(_mySelection);
      Firestore.instance
          .collection('users')
          .document(_mySelection)
          .updateData({"role": "admin"}).then((onValue) {
        buildSuccessDialog("Updated Successfull", context);
      }).catchError((onError) {
        print(onError.message);
      });
    }

    return Container(
      width: 500,
      padding: EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Make Admin",
            style: Theme.of(context).textTheme.headline,
          ),
          SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("users")
                .where('role', isEqualTo: 'user')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: circularProgress(context),
                );
              return new DropdownButton<String>(
                isDense: true,
                hint:
                    _mySelection == null ? Text("Select") : Text(_mySelection),
                value: _mySelection,
                onChanged: (String newValue) {
                  _mySelection = newValue;
                  print(_mySelection);
                },
                items: snapshot.data.documents.map((DocumentSnapshot document) {
                  return new DropdownMenuItem<String>(
                    value: document.data["uid"].toString(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(
                          document.data['email'],
                        ),
                        new Text(
                          "(${document.data['displayName']})",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              buildRaisedButton(
                  "Back", Colors.white, Theme.of(context).primaryColor, () {
                Navigator.pop(context);
              }),
              buildRaisedButton(
                  "Make Admin", Theme.of(context).primaryColor, Colors.white,
                  () {
                makeAdmin();
              }),
            ],
          )
        ],
      ),
    );
  }
}

class DrawerIcon extends StatelessWidget {
  const DrawerIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              width: 26,
              decoration: new BoxDecoration(
                border: Border(
                  top: BorderSide(
                      width: 1.2, color: Theme.of(context).primaryColor),
                  left: BorderSide(
                      width: 1.2, color: Theme.of(context).primaryColor),
                  right: BorderSide(
                      width: 1.2, color: Theme.of(context).primaryColor),
                  bottom: BorderSide(
                      width: 1.2, color: Theme.of(context).primaryColor),
                ),
              )),
          SizedBox(height: 4),
          Container(
              alignment: Alignment.topLeft,
              width: 20,
              decoration: new BoxDecoration(
                border: Border(
                  top: BorderSide(
                      width: 1.2, color: Theme.of(context).primaryColor),
                  left: BorderSide(
                      width: 1.2, color: Theme.of(context).primaryColor),
                  right: BorderSide(
                      width: 1.2, color: Theme.of(context).primaryColor),
                  bottom: BorderSide(
                      width: 1.2, color: Theme.of(context).primaryColor),
                ),
              )),
          SizedBox(height: 4),
          Container(
              width: 26,
              decoration: new BoxDecoration(
                border: Border(
                  top: BorderSide(
                      width: 1.2, color: Theme.of(context).primaryColor),
                  left: BorderSide(
                      width: 1.2, color: Theme.of(context).primaryColor),
                  right: BorderSide(
                      width: 1.2, color: Theme.of(context).primaryColor),
                  bottom: BorderSide(
                      width: 1.2, color: Theme.of(context).primaryColor),
                ),
              )),
          SizedBox(height: 4),
        ],
      ),
    ));
  }
}

class AdminDrawer extends StatelessWidget {
  User currentUser;
  int orderCount;
  AdminDrawer({this.currentUser, this.orderCount});

  @override
  Widget build(BuildContext context) {
    List<String> data = [
      "Dashboard",
      "Order Request",
      "Delivered Product",
      "Upload Product",
      "Delete Product",
      "Update Product",
      "View Product",
      "Online Transaction"
    ];
    List<IconData> icon = [
      FontAwesome.list_alt,
      FontAwesome.cart_arrow_down,
      FontAwesome.truck,
      FontAwesome.upload,
      Icons.delete,
      Icons.update,
      Icons.view_array,
      Icons.payment
    ];
    List<GestureTapCallback> onPressed = [
      () {
        Navigator.pop(context);
      },
      () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderPage(
                      currentUser: currentUser,
                    )));
      },
      () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DeliveredPage(
                      currentUser: currentUser,
                    )));
      },
      () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UploadPage(
                      currentUser: currentUser,
                    )));
      },
      () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DeletePage(
                      currentUser: currentUser,
                    )));
      },
      () {
        print("Update");
      },
      () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewPage(
                      currentUser: currentUser,
                    )));
      },
      () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderTransaction(
                      currentUser: currentUser,
                    )));
      }
    ];
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xffECECEC)),
              accountName: Text(
                currentUser.username,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                currentUser.userEmail,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(currentUser.photoUrl),
              )),
          Container(
            height: double.maxFinite,
            child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, i) {
                  return new ListTile(
                    title: new Text(data[i]),
                    leading: orderCount != 0 && data[i] == 'Order Request'
                        ? Stack(
                            children: <Widget>[
                              Icon(icon[i]),
                              Padding(
                                padding: const EdgeInsets.only(left: 18),
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
                                    orderCount.toString(),
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Icon(icon[i]),
                    onTap: onPressed[i],
                  );
                }),
          )
        ],
      ),
    );
  }
}
