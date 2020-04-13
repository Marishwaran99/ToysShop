import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toys_shop/models/review.dart';

class User {
  String uid, username, email, address;
  List<String> cartProducts, boughtProducts;
  List<Review> reviews;

  User(
      {this.uid,
      this.username,
      this.email,
      this.address,
      this.cartProducts,
      this.boughtProducts,
      this.reviews});
  Map<String, dynamic> toMap() {
    return {
      'uid': uid ?? '',
      'name': username ?? '',
      'email': email ?? '',
      'address': address ?? '',
      'cartProducts': cartProducts ?? [],
      'boughtProducts': boughtProducts ?? [],
      'reviews': reviews ?? [],
    };
  }

  factory User.fromMap(Map snapshot) {
    snapshot = snapshot ?? {};
    return User(
        username: snapshot["username"],
        email: snapshot["email"],
        address: snapshot["address"],
        cartProducts: snapshot["cartProducts"],
        boughtProducts: snapshot["boughtProducts"],
        reviews: snapshot["reviews"]);
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return User(
        username: data["username"] ?? '',
        email: data["email"] ?? '',
        address: data["address"] ?? '',
        cartProducts: data["cartProducts"] ?? [],
        boughtProducts: data["boughtProducts"] ?? [],
        reviews: data["reviews"] ?? 0);
  }
}
