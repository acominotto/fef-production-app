import 'package:fef_production_app/controllers/ClientsController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ClientsController c = Get.put(ClientsController());

    return Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(c.currentClient?.name ?? 'No client')),
        ),
        body: SafeArea(
            child: c.currentClient == null
                ? Text(
                    'No client',
                    style: TextStyle(color: Colors.white),
                  )
                : Obx(
                    () => ListView.separated(
                      itemCount: c.searchResults.length + 1,
                      padding: const EdgeInsets.only(top: 4),
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        if (index == 0)
                          return TextField(
                            onChanged: (value) {
                              c.setSearch(value);
                            },
                            decoration: InputDecoration(
                                hintText: 'Rechercher un produit',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12))),
                          );
                        else {
                          var product = c.searchResults[index - 1];
                          return ListTile(
                            title: Text('${product.name}'),
                            subtitle: c.currentClient?.meta?['price'] == false
                                ? null
                                : Text(
                                    '${product.price}€/${product.isPricePerPiece ? 'p' : 'kg'}'),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              c.selectProduct(product.id);
                            },
                          );
                        }
                      },
                    ),
                  )));
  }
}
