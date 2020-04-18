import 'package:cloud_firestore/cloud_firestore.dart';

// class Product{
//   int id, discount, price, quantity;
//   String title, description, thumbnailImage, adminId, timestamp;
//   List<dynamic> previewImages;
//   int stock;
//   Product(this.id, this.title, this.description, this.discount, this.quantity, this.thumbnailImage, this.price, this.adminId, {this.previewImages, this.stock});
// }

class ProductList{
  int id, discount, price, quantity;
  String title, description, thumbnailImage, adminId;
  List<dynamic> previewImages;
  int stock;
  ProductList({this.id, this.title, this.description, this.discount, this.quantity, this.thumbnailImage, this.price, this.adminId, this.previewImages, this.stock});
  factory ProductList.fromDocument(DocumentSnapshot doc){
    return ProductList(
      id: doc.data['id'],
      title: doc.data['title'],
      description: doc.data['description'],
      discount: doc.data['discount'],
      quantity: doc.data['quatity'],
      thumbnailImage: doc.data['thumbnailImage'],
      price: doc.data['price'],
      adminId: doc.data['adminId'],
      previewImages: doc.data['previewImages'],
      stock: doc.data['stock'],
    );
  }
}