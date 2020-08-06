import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/Models/cart_model.dart';

class DiscountCard extends StatefulWidget {
  @override
  _DiscountCardState createState() => _DiscountCardState();
}

class _DiscountCardState extends State<DiscountCard> {

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ExpansionTile(
        title: Text(
          "Cupom de desconto",
          textAlign: TextAlign.start,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
        ),
        onExpansionChanged: (bool expanding) => setState(() => this.isExpanded = expanding),
        leading: Icon(Icons.card_giftcard),
        trailing: isExpanded ? Icon(Icons.remove) : Icon(Icons.add),
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Digite seu cupom"
              ),
              initialValue: CartModel.of(context).cupomCode ?? "",
              onFieldSubmitted: (text) {
                Firestore.instance
                  .collection("cupons")
                  .document(text)
                  .get().then((snap) {
                    if(snap.data != null) {
                      if (snap.data["valid"] == true) {
                        
                        CartModel.of(context).setCupom(text, snap.data["percentage"]);
                        Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Desconto de ${snap
                                  .data["percentage"]}% aplicado!"),
                              backgroundColor: Theme.of(context).primaryColor,
                            )
                        );
                      } else {

                        CartModel.of(context).setCupom(null, 0);
                        Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Validade do cupom expirada :("),
                              backgroundColor: Colors.red,
                            )
                        );
                      }
                    } else {

                      CartModel.of(context).setCupom(null, 0);
                      Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Cupom não encontrado :("),
                            backgroundColor: Colors.red,
                          )
                      );
                    }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
