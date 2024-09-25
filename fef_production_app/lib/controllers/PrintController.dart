import 'package:brother_printer/brother_printer.dart';
import 'package:fef_production_app/barcode/Barcode.dart';
import 'package:fef_production_app/models/PrintContext.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final m = Mutex();

  bool get canPrint => this._printer.value != null;
  PrintContext? get context => this._context.value;
  get printer => this._printer.value!;
  List<int> get weights => this._weights.toList(growable: true);

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
        try {
          await BrotherPrinter.printPDF(
              path: path,
              device: printer,
              labelSize: BrotherLabelSize.QLRollW62RB);
          this._weights.add(weight);
        } catch (e) {
          OpenFile.open(path);
          Get.snackbar("Erreur", e.toString());
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
}
