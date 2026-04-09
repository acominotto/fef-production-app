import 'dart:convert';

import 'package:brother_printer/brother_printer.dart';
import 'package:fef_production_app/barcode/Barcode.dart';
import 'package:fef_production_app/const/Env.dart';
import 'package:fef_production_app/controllers/AuthController.dart';
import 'package:fef_production_app/models/PrintContext.dart';
import 'package:fef_production_app/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mutex/mutex.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

final f = DateFormat('dd/MM/yyyy');

class PrintController extends GetxController {
  var _context = Rxn<PrintContext>();
  final weightController = TextEditingController();
  final piecesController = TextEditingController();
  final dateController = TextEditingController(text: f.format(DateTime.now()));
  var _weights = RxList(<int>[]);
  var _printer = Rxn<BrotherDevice>();
  var _isBlackAndWhite = Rx(false);
  final m = Mutex();

  bool get canPrint => this._printer.value != null;
  PrintContext? get context => this._context.value;
  bool get isBlackAndWhite => this._isBlackAndWhite.value;
  get printer => this._printer.value!;
  List<int> get weights => this._weights.toList(growable: true);

  addToProduction(Ticket ticket) async {
    try {
      var body = jsonEncode(ticket.toJson());
      var token = Get.find<AuthController>().token;
      print('print ticket: ' + body.toString());
      var response = await http.post(
          Uri.parse('${Env.BackendURL}/mobile/v1/ticket-print'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Cookie': 'fef-cookie=${token}'
          },
          body: body);

      if (response.statusCode == 200) {
        //Get.snackbar('Succès', 'Ticket added to production');
      } else {
        print('response status: ' + response.statusCode.toString());
        //Get.snackbar('Erreur', 'Failed to add ticket to production');
      }
    } catch (e) {
      print('error: ' + e.toString());
      Get.snackbar('Error while fetching clients', e.toString());
    }
  }

  void changeDate(DateTime dt) {
    this.dateController.text = f.format(dt);
    this.context?.date = dt;
  }

  @override
  void onClose() {
    weightController.dispose();
    piecesController.dispose();
    super.onClose();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    await refreshPrinters();
  }

  printBarcode() async {
    await m.protect(() async {
      var labelSize = isBlackAndWhite
          ? BrotherLabelSize.QLRollW62
          : BrotherLabelSize.QLRollW62RB;
      var weightTxt = this.weightController.text;
      var piecesTxt = this.piecesController.text;
      if ((context != null &&
              context!.product.isPricePerPiece &&
              piecesTxt != '') ||
          weightTxt != '') {
        var weight =
            weightTxt == '' || weightTxt == '0' ? 0 : int.parse(weightTxt);
        var pieces =
            piecesTxt == '' || piecesTxt == '0' ? 0 : int.parse(piecesTxt);

        print('printing ${context!.clientId} ${context!.product.id} ${weight}');
        final path = await Barcode.generate(context!, weight, pieces);
        var ticket =
            Ticket(weight, pieces, context!.clientId, context!.product.id);
        try {
          await BrotherPrinter.printPDF(
              path: path, device: printer, labelSize: labelSize);

          this.addToProduction(ticket);
          this._weights.add(weight);
        } catch (e) {
          try {
            await BrotherPrinter.printPDF(
                path: path,
                device: printer,
                labelSize: labelSize == BrotherLabelSize.QLRollW62
                    ? BrotherLabelSize.QLRollW62RB
                    : BrotherLabelSize.QLRollW62);
            this.addToProduction(ticket);
            this._weights.add(weight);
          } catch (e) {
            this.addToProduction(ticket);
            OpenFile.open(path);
            Get.snackbar("Erreur", e.toString());
          }
        }
      }
    });
  }

  refreshPrinters() async {
    await Permission.bluetoothScan.request();
    if (await Permission.bluetoothScan.isGranted) {
      await Permission.bluetoothAdvertise.request();
      if (await Permission.bluetoothAdvertise.isGranted) {
        await Permission.bluetoothConnect.request();
        if (await Permission.bluetoothConnect.isGranted) {
          var devices = await BrotherPrinter.searchDevices();
          if (devices.isNotEmpty) {
            _printer.value = devices[0];
            Get.snackbar('Imprimante', 'Connecté à ${devices[0].modelName}');
          } else {
            _printer.value = null;
            Get.snackbar('Imprimante', 'Aucune imprimante trouvée...');
          }
        }
      }
    }
  }

  removeWeight(int index) {
    _weights.removeAt(index);
  }

  setContext(PrintContext ctx) {
    this._context.value = ctx;
    _weights.value = [];
  }

  toggleBlackAndWhite() {
    this._isBlackAndWhite.value = !this._isBlackAndWhite.value;
  }
}
