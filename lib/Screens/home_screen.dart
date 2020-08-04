import "package:flutter/material.dart";
import 'package:loja_virtual/Tabs/home_tab.dart';
import 'package:loja_virtual/Tabs/products_tab.dart';
import 'package:loja_virtual/Widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {

  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Scaffold(
          body: HomeTab(),
          drawer: CustomDrawer(_pageController),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Categorias"),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: ProductsTab(),
        ),
        Container(color: Colors.blue,),
        Container(color: Colors.green,),
      ],
    );
  }
}
