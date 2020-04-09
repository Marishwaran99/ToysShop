
class Wishlist{
  int id;
  int productId;
  Wishlist({this.productId});
  Wishlist.withId(id, productId);


  set productID(int id){
    this.productId = id;
  }

  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    if(id !=null){
      map['id'] = id;

    }

    map['productId'] = productId;
    return map;
  }

  Wishlist.fromMapObject(Map<String, dynamic> map){
    this.id = map['id'];
    this.productId = map['productId'];
  }

}