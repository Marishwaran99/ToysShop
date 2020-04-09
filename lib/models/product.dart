class Product{
  int id, discount, price;
  String title, description, thumbnailImage;
  List<String> previewImages;
  int stock;
  Product(this.id, this.title, this.description, this.discount, this.thumbnailImage, this.price, {this.previewImages, this.stock});
}