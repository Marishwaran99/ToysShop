import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toys_shop/models/user.dart';

abstract class BaseDatastore {
  Future<String> addUserData(User user);
  Future<Map<String, dynamic>> getUserData(String uid);
  Future<String> updateUserData(String uid, String name);
  Future<String> addProductToCart(String uid, Map<String, dynamic> productId);
}

class Datastore implements BaseDatastore {
  Firestore _firestore = Firestore.instance;
  @override
  Future<String> addUserData(User user) async {
    String status = await _firestore
        .collection('users')
        .document(user.uid)
        .setData(user.toMap())
        .then((val) => 'success')
        .catchError((onError) => onError.toString());
    return status;
  }

  @override
  Future<String> updateUserData(String uid, String name) async {
    String status = await _firestore
        .collection('users')
        .document(uid)
        .updateData({'name': name})
        .then((val) => 'success')
        .catchError((onError) => onError.toString());
    return status;
  }

  @override
  Future<Map<String, dynamic>> getUserData(String uid) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('users').document(uid).get();
    Map<String, dynamic> userData = snapshot.data;
    return userData;
  }

  @override
  Future<String> addProductToCart(
      String uid, Map<String, dynamic> productId) async {
    String status = await _firestore
        .collection("users")
        .document(uid)
        .updateData({
          'cartProducts': FieldValue.arrayUnion([productId])
        })
        .then((val) => 'success')
        .catchError((err) => err.toString());
    return status;
  }
}
