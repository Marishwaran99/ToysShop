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
      state;
  int pincode;
  List<String> cartProducts;
  List<String> boughtProducts;
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
      this.reviews});
  Map<String, dynamic> toMap() {
    return {
      'uid': uid ?? '',
      'username': username ?? '',
      'userEmail': userEmail ?? '',
      'photoUrl': photoUrl ?? '',
      'address': address,
      'pincode': '',
      'state': state,
      'city': city,
      'cartProducts': cartProducts ?? [],
      'role': 'user',
      'review': reviews ?? [],
      'boughtProducts': boughtProducts ?? [],
      'loginType': ''
    };
  }

  factory User.fromMap(Map snapshot) {
    snapshot = snapshot ?? {};
    return User(
        photoUrl: snapshot['photoUrl'],
        username: snapshot["username"],
        userEmail: snapshot["email"],
        role: snapshot['role'],
        address: snapshot['address'],
        state: snapshot['state'],
        city: snapshot['city'],
        cartProducts: snapshot["cartProducts"],
        boughtProducts: snapshot["boughtProducts"],
        reviews: snapshot["reviews"],
        loginType: snapshot['loginType'],
        uid: snapshot['uid'],
        pincode: snapshot['pincode']);
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map snapshot = doc.data;
    return User(
        photoUrl: snapshot['photoUrl'],
        username: snapshot["displayName"],
        userEmail: snapshot["email"],
        role: snapshot['role'],
        address: snapshot['address'],
        state: snapshot['state'],
        city: snapshot['city'],
        cartProducts: snapshot["cartProducts"],
        boughtProducts: snapshot["boughtProducts"],
        reviews: snapshot["reviews"],
        loginType: snapshot['loginType'],
        uid: snapshot['uid'],
        pincode: snapshot['pincode']);
  }
}
