import 'package:collection/collection.dart';
import 'package:fef_production_app/controllers/PrintController.dart';
import 'package:fef_production_app/utils/readableGrams.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PrintScreen extends StatelessWidget {
  final c = Get.put(PrintController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Obx(() => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    c.context?.clientName ?? 'no client',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    c.context?.product.name ?? 'no product',
                    style: TextStyle(fontSize: 16),
                  )
                ],
              )),
        ),
        floatingActionButton: Obx(() => FloatingActionButton(
              backgroundColor: c.canPrint ? Colors.green : Colors.red,
              onPressed: () {
                c.refreshPrinters();
              },
              child: Icon(Icons.print),
            )),
        body: SafeArea(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [
                TextField(
                    controller: c.dateController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today), //icon of text field
                        labelText: "Date de production" //label text of field
                        ),
                    readOnly: true, // when true user cannot edit text
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: c.context?.date ??
                              DateTime.now(), //get today's date
                          firstDate: DateTime.now().subtract(Duration(
                              days:
                                  7)), //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime.now().add(Duration(days: 7)));
                      if (pickedDate != null) c.changeDate(pickedDate);
                    }),
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Pièces', labelStyle: TextStyle(fontSize: 24)),
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: c.piecesController,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Poids en grammes',
                      labelStyle: TextStyle(fontSize: 24)),
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: c.weightController,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(50)),
                      onPressed: () {
                        c.printBarcode();
                      },
                      child: Text(
                        'Imprimer',
                        style: TextStyle(fontSize: 24),
                      )),
                ),
                Obx(() => Text('Total: ${readableGrams(c.weights.sum)}')),
                Obx(() => Wrap(
                    children: c.weights
                        .mapIndexed((index, w) => ActionChip(
                              label: Text(w.toString() + 'g'),
                              avatar: CloseButtonIcon(),
                              onPressed: () {
                                c.removeWeight(index);
                              },
                            ))
                        .toList(growable: true)))
              ])),
        ));
  }
}
