import 'package:fef_production_app/const/GetPages.dart';
import 'package:fef_production_app/controllers/ClientsController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ClientsController ctrl = Get.put(ClientsController());
    return Scaffold(
        appBar: AppBar(
          title: Text("Clients"),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
            child: Obx(() => GridView.count(
                crossAxisCount: 2,
                children: ctrl.clients
                    .map((c) => InkWell(
                          onTap: () {
                            ctrl.selectClient(c);
                            Get.toNamed(Routes.client);
                          },
                          child: Card(
                              child: Column(
                            children: [
                              Text(c.id),
                              Text(
                                c.name,
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          )),
                        ))
                    .toList()))));
  }
}
