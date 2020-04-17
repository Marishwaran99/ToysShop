import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toys_shop/models/user.dart';

abstract class BaseDatastore {
  //user functions
  Future<String> addUserData(User user);
  Future<Map<String, dynamic>> getUserData(String uid);
  Future<String> updateUserData(String uid, String name);
  Future<String> storeProfilePic(String uid, File image);
  //product function
  Future<String> addProductToCart(String uid,int amount, Map<String, dynamic> product);
  Future<String> saveDeliveryLocation(
      String uid, Map<String, dynamic> deliveryAddress);
  Future<String> addProduct(String id, Map<String, dynamic> product);
  Future<String> addProductImage(File image, String id);
  Future<String> deleteProductImage(String id);
  Future<String> deleteProduct(String id);
  Future<String> updateProduct(String id, Map<String, dynamic> product);
  String getProductId();
  Stream<QuerySnapshot> getProducts();
  Future<List<String>> getCartProducts(String uid);
}

class Datastore implements BaseDatastore {
  Firestore _firestore = Firestore.instance;
  StorageReference _storageReference = FirebaseStorage.instance.ref();
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
      String uid,int amount, Map<String, dynamic> product) async {
        var batch = _firestore.batch();
    DocumentReference userRef = _firestore.collection("users").document(uid);
    DocumentReference productRef =
        _firestore.collection("products").document(product['productId']);
    batch.updateData(userRef, {
      'cartProducts': FieldValue.arrayUnion([product])
    });
    batch.updateData(productRef, {'stock': amount});

    String status = await batch.commit().then((val)=>'success').catchError((err)=>err.toString());
    return status;
  }

  @override
  Future<String> storeProfilePic(String uid, File image) async {
    StorageUploadTask uploadTask = _storageReference.child(uid).putFile(image);
    StorageTaskSnapshot uploadTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await uploadTaskSnapshot.ref.getDownloadURL();
    log(downloadUrl);
    String status = await _firestore
        .collection('users')
        .document(uid)
        .updateData({'photoUrl': downloadUrl})
        .then((val) => 'success')
        .catchError((err) => err.toString());
    return status;
  }

  @override
  Future<String> saveDeliveryLocation(
      String uid, Map<String, dynamic> deliveryAddress) async {
    String status = await _firestore
        .collection("users")
        .document(uid)
        .updateData({'deliveryAddress': deliveryAddress})
        .then((val) => 'success')
        .catchError((err) => err.toString());
    return status;
  }

  @override
  Future<String> addProductImage(File image, String id) async {
    StorageUploadTask uploadTask = _storageReference.child(id).putFile(image);
    StorageTaskSnapshot uploadTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await uploadTaskSnapshot.ref.getDownloadURL();
    log(downloadUrl);
    return downloadUrl;
  }

  @override
  Future<String> addProduct(String id, Map<String, dynamic> product) async {
    String status = await _firestore
        .collection("products")
        .document(id)
        .setData(product)
        .then((val) => 'success')
        .catchError((err) => err.toString());

    log(status);
    return status;
  }

  @override
  Stream<QuerySnapshot> getProducts() {
    Stream<QuerySnapshot> querySnapshot =
        _firestore.collection("products").snapshots();
    return querySnapshot;
  }

  @override
  Future<String> deleteProductImage(String id) async {
    String status = await _storageReference
        .child(id)
        .delete()
        .then((val) => 'success')
        .catchError((err) => err.toString());
    return status;
  }

  @override
  Future<String> updateProduct(String id, Map<String, dynamic> product) async {
    String status = await _firestore
        .collection("products")
        .document(id)
        .updateData(product)
        .then((val) => 'success')
        .catchError((err) => err.toString());
    return status;
  }

  @override
  String getProductId() {
    String id = _firestore.collection("products").document().documentID;
    return id;
  }

  @override
  Future<String> deleteProduct(String id) async {
    String status = await _firestore
        .collection("products")
        .document(id)
        .delete()
        .then((val) => 'success')
        .catchError((err) => err.toString());
    return status;
  }

  @override
  Future<List<String>> getCartProducts(String uid) async{
    DocumentSnapshot snapshot = await _firestore.collection('users').document(uid).get();
    Map<String, dynamic> user = snapshot.data;
    List<String> cartProducts = user['cartProducts'].cast<String>();
    return cartProducts;
  }
}
