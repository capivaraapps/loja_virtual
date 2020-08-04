import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/Data/cart_product.dart';
import 'package:loja_virtual/Models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {

  UserModel user;
  List<CartProduct> products = [];

  CartModel(this.user);

  static CartModel of(BuildContext context) => ScopedModel.of<CartModel>(context);

  void addCartItem(CartProduct item) {
    products.add(item);
    Firestore
        .instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .add(item.toMap())
        .then((doc) => {
          item.cartId = doc.documentID
    });

    notifyListeners();
  }

  void removeCartItem(CartProduct item) {
    Firestore
        .instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(item.cartId)
        .delete();
    products.remove(item);
    notifyListeners();
  }
}