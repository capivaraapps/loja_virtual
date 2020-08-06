import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/Models/cart_model.dart';

class ShipmentCard extends StatefulWidget {
  @override
  _ShipmentCardState createState() => _ShipmentCardState();
}

class _ShipmentCardState extends State<ShipmentCard> {

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ExpansionTile(
        title: Text(
          "Calcular frete",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        onExpansionChanged: (bool expanding) => setState(() => this.isExpanded = expanding),
        leading: Icon(Icons.location_on),
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Digite seu CEP"
              ),
              initialValue: CartModel.of(context).cep ?? "",
              onFieldSubmitted: (text) {
                if (!validateCEP(text)) {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("CEP invalido"),
                        backgroundColor: Colors.red,
                      )
                  );
                } else {
                  CartModel.of(context).setShipment(text);
                  Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Valor do frete calculado!"),
                        backgroundColor: Theme.of(context).primaryColor,
                      )
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  bool validateCEP(String value) {
    if (RegExp("^[0-9]{8}\$").hasMatch(value)) return true;
    return false;
  }

}
