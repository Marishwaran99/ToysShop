import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:toys_shop/models/user.dart';

abstract class BaseDatastore {
  Future<String> addUserData(User user);
  Future<Map<String, dynamic>> getUserData(String uid);
  Future<String> updateUserData(String uid, String name);
  Future<String> addProductToCart(String uid, Map<String, dynamic> productId);
  Future<String> storeProfilePic(String uid, File image);
  Future<String> saveDeliveryLocation(
      String uid, Map<String, dynamic> deliveryAddress);

  Future<String> addProduct(Map<String, dynamic> product);
  Future<String> addProductImage(File image, String id);
  Future<String> deleteProductImage(String id);
  Future<String> updateProduct(String id, Map<String, dynamic> product);
  Stream<QuerySnapshot> getProducts();
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
  Future<String> addProduct(Map<String, dynamic> product) async {
    String status = await _firestore
        .collection("products")
        .document()
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
}
