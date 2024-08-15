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
                ? Text('No client')
                : Obx(() => GridView.count(
                    crossAxisCount: 2,
                    children: c.currentClient!.products.keys
                        .map((p) => InkWell(
                              onTap: () {
                                c.selectProduct(p);
                              },
                              child: Card(
                                  child: Center(
                                      child: Text(
                                c.currentClient!.products[p]!.name,
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ))),
                            ))
                        .toList()))));
  }
}
