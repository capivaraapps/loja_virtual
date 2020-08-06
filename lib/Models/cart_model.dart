import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/Data/cart_product.dart';
import 'package:loja_virtual/Models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {

  UserModel user;
  List<CartProduct> products = [];
  bool isLoading = false;
  String cupomCode;
  int discountPercentage = 0;
  double shipment = 0.0;
  String cep;

  CartModel(this.user) {
    if (user.isLoggedIn()) {
      _loadCartItems();
    }
  }

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

  void decrement( CartProduct cartProduct) {
    cartProduct.quantity--;
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cartId).updateData(cartProduct.toMap());

    notifyListeners();
  }

  void increment( CartProduct cartProduct) {
    cartProduct.quantity++;
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cartId).updateData(cartProduct.toMap());

    notifyListeners();
  }

  void _loadCartItems() async {
    QuerySnapshot query = await Firestore.instance
      .collection("users")
      .document(user.firebaseUser.uid)
      .collection("cart")
      .getDocuments();

    products = query.documents.map((doc) => CartProduct.fromDocument(doc)).toList();

    notifyListeners();
  }

  void setCupom (String cupomCode, int percentage) {
    this.cupomCode = cupomCode;
    this.discountPercentage = percentage;

    notifyListeners();
  }

  void setShipment (String cep) {
    this.cep = cep;
    this.shipment = 9.99; // TODO - CHAMAR SERVIÇO QUE CALCULE O FRETE

    notifyListeners();
  }

  double getProductPrice() {
    double price = 0.0;
    for(CartProduct p in products) {
      if(p.productData != null) {
        price += p.quantity * p.productData.price;
      }
    }

    return price;
  }

  double getDiscount() {
    return getProductPrice() * discountPercentage / 100;
  }

  double getShipment() {
    return this.shipment;
  }

  void updatePrices() {
    notifyListeners();
  }
  
  Future<String> finishOrder() async {
    if (products.length == 0) return null;
    isLoading = true;
    notifyListeners();

    double productsPrice = getProductPrice();
    double productsDiscount = getDiscount();
    double productsShipment = getShipment();
    
    DocumentReference refOrder = await Firestore.instance
      .collection("orders")
      .add({
        "clientId": user.firebaseUser.uid,
        "products": products.map((cartProduct) => cartProduct.toMap()).toList(),
        "shipPrice": productsShipment,
        "productPrice": productsPrice,
        "discount": productsDiscount,
        "totalPrice": productsPrice - productsDiscount + productsShipment,
        "status": 1
    });

    await Firestore.instance
      .collection("users")
      .document(user.firebaseUser.uid)
      .collection("orders")
      .document(refOrder.documentID)
      .setData({
        "orderId": refOrder.documentID
    });

    QuerySnapshot query = await Firestore.instance
      .collection("users")
      .document(user.firebaseUser.uid)
      .collection("cart")
      .getDocuments();

    for(DocumentSnapshot doc in query.documents) {
      doc.reference.delete();
    }

    products.clear();
    discountPercentage = 0;
    cupomCode = null;
    cep = null;
    isLoading = false;

    notifyListeners();

    return refOrder.documentID;
  }
}