import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toys/models/reviews.dart';

class User {
  String uid,
      username,
      userEmail,
      photoUrl,
      loginType,
      role,
      address,
      city,
      state, pincode;
  Map<String, dynamic> deliveryAddress;
  List<dynamic> cartProducts;
  List<dynamic> boughtProducts;
  List<Review> reviews;

  User(
      {this.uid,
      this.username,
      this.userEmail,
      this.address,
      this.city,
      this.state,
      this.pincode,
      this.photoUrl,
      this.loginType,
      this.role,
      this.boughtProducts,
      this.cartProducts,
      this.reviews, this.deliveryAddress});
  Map<String, dynamic> toMap() {
    return {
      'uid': uid ?? '',
      'username': username ?? '',
      'userEmail': userEmail ?? '',
      'photoUrl': photoUrl ?? '',
      'deliveryAddress': deliveryAddress ??
          {'address': '', 'pincode': '', 'state': '', 'city': ''},
      'cartProducts': cartProducts ,
      'role': 'user',
      'reviews': reviews ,
      'boughtProducts': boughtProducts ,
      'loginType': loginType
    };
  }

  factory User.fromMap(Map snapshot) {
    return User(
      photoUrl: snapshot['photoUrl'],
      username: snapshot["username"],
      userEmail: snapshot["userEmail"],
      role: snapshot['role'],
      deliveryAddress: snapshot["deliveryAddress"],
      cartProducts: snapshot["cartProducts"],
      boughtProducts: snapshot["boughtProducts"],
      reviews: snapshot["reviews"],
      loginType: snapshot['loginType'],
      uid: snapshot['uid'],
    );
  }

  factory User.fromFirestore(DocumentSnapshot doc) {

    return User(
      uid: doc.data['uid'],
      photoUrl: doc.data['photoUrl'],
      username: doc.data["username"],
      userEmail: doc.data["userEmail"],
      role: doc.data['role'],
      address: doc.data['address'],
      city: doc.data['city'],
      state: doc.data['state'],
      pincode: doc.data['pincode'],
      cartProducts: doc.data["cartProducts"],
      boughtProducts: doc.data["boughtProducts"],
      reviews: doc.data["reviews"],
      loginType: doc.data['loginType'],
    );
  }
}
