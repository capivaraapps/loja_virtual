import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/Data/product_data.dart';

class CartProduct {
  String cartId;
  String category;
  String productId;
  int quantity;
  String size;

  ProductData productData;

  CartProduct();

  CartProduct.fromDocument(DocumentSnapshot doc) {
    cartId = doc.documentID;
    category = doc.data["category"];
    productId = doc.data["productId"];
    quantity = doc.data["quantity"];
    size = doc.data["size"];
  }

  Map<String, dynamic> toMap() {
    return {
      "category": category,
      "productId": productId,
      "quantity": quantity,
      "size": size,
      // "product": productData.toResumeMap()
    };
  }

}