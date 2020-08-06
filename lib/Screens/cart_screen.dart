import 'package:flutter/material.dart';
import 'package:loja_virtual/Models/cart_model.dart';
import 'package:loja_virtual/Models/user_model.dart';
import 'package:loja_virtual/Screens/login_screen.dart';
import 'package:loja_virtual/Screens/order_screen.dart';
import 'package:loja_virtual/Widgets/cart_price.dart';
import 'package:loja_virtual/Widgets/cart_tile.dart';
import 'package:loja_virtual/Widgets/discount_card.dart';
import 'package:loja_virtual/Widgets/shipment_card.dart';
import 'package:scoped_model/scoped_model.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meu carrinho"),
        actions: [
          Container(
            padding: EdgeInsets.only(right: 8.0),
            alignment: Alignment.center,
            child: ScopedModelDescendant<CartModel>(
              builder: (context, child, model) {
                int productsLength = model.products.length;
                if (UserModel.of(context).isLoggedIn()){
                  return Text(
                    "${productsLength ?? 0} ${productsLength == 1 ? " ITEM" : " ITENS"}",
                    style: TextStyle(fontSize: 17.0),
                  );
                } else {
                  return Text("");
                }
              }
            ),
          )
        ],
      ),
      body: ScopedModelDescendant<CartModel>(
        builder: (context, child, model){
          if (model.isLoading && UserModel.of(context).isLoggedIn()) {
            return Center(child: CircularProgressIndicator(),);
          } else if (!UserModel.of(context).isLoggedIn()) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart, size: 80.0, color: Theme.of(context).primaryColor,),
                  SizedBox(height: 16.0,),
                  Text("Faça login para adicionar produtos ao carrinho",
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0,),
                  RaisedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginScreen())
                      );
                    },
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    child: Text("Entrar",
                      style: TextStyle(fontSize: 18.0),),
                  ),
                ],
              ),
            );
          } else if (model.products == null || model.products.length == 0) {
            return Center(
              child: Text(
                "Carrinho vazio",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return ListView(
              children: [
                Column(
                  children: model.products.map((product) {
                    return CartTile(product);
                  }).toList(),
                ),
                DiscountCard(),
                ShipmentCard(),
                CartPrice(() async {
                  String orderId = await model.finishOrder();
                  if(orderId != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => OrderScreen(orderId))
                    );
                  }
                }),
              ],
            );
          }
        }
      ),
    );
  }
}
