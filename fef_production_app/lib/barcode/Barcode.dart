import 'dart:io';

import 'package:fef_production_app/models/Client.dart';
import 'package:fef_production_app/models/PrintContext.dart';
import 'package:fef_production_app/models/Product.dart';
import 'package:fef_production_app/utils/readableGrams.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const mm = PdfPageFormat.mm;
var eur = String.fromCharCode(128);

barcodeSide(Product product, num weight, String price, String code,
    Client client, DateTime date, num pieces) {
  return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
            padding: pw.EdgeInsets.only(bottom: 3),
            child: client.meta['price'] != false
                ? pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                        pw.Container(
                            width: 120,
                            child: pw.Text(product.name,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ))),
                        if (client.meta['price'] != false)
                          pw.Container(
                              width: 40,
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text("${price} ${eur}",
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ))),
                      ])
                : pw.Text(product.name,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ))),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Container(
              width: client.meta['logo'] == null || client.meta['logo'] == false
                  ? 70
                  : 160,
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          if (client.meta['pricePerKg'] != false)
                            textWithLabel(
                                'prix / kg', '${product.price} ${eur}'),
                          if (client.meta['weight'] != false)
                            pw.RichText(
                                text: pw.TextSpan(children: [
                              pw.TextSpan(
                                  text: readableGrams(weight),
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize:
                                          client.meta['pricePerKg'] == false
                                              ? 10
                                              : 6)),
                            ]))
                        ]),
                    if (pieces > 0)
                      textWithLabel('Nombre de pièces', pieces.toString()),
                    textWithLabel(
                        'À consommer avant',
                        DateFormat('dd/MM/yyyy').format(date.add(Duration(
                            days: product.conservation.days.toInt())))),
                    textWithLabel(
                        'Lot', DateFormat('yyyyMMdd').format(date) + '01'),
                    textWithLabel('Conservation', product.conservation.how),
                  ])),
          if (client.meta['logo'] == null || client.meta['logo'] == false)
            pw.Expanded(
                flex: 2,
                child: pw.BarcodeWidget(
                  width: 80,
                  height: 40,
                  textStyle: pw.TextStyle(fontSize: 6),
                  color: PdfColor.fromHex("#000000"),
                  barcode: pw.Barcode.ean13(),
                  data: code,
                ))
        ]),
        textWithLabel('Composition', product.composition,
            fontSize: product.composition.length > 150 ? 5 : 6),
      ]);
}

fefSide(Product product) async {
  final data = await rootBundle.load('assets/images/wkc-logo.png');
  final img = pw.MemoryImage(data.buffer.asUint8List());
  return pw.Container(
    padding: pw.EdgeInsets.only(top: 5),
    child: pw.Row(children: [
      pw.Image(img, height: 70, width: 70),
      pw.Container(
          padding: pw.EdgeInsets.only(left: 4),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Fievet et fils",
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    )),
                pw.RichText(
                    text: pw.TextSpan(children: [
                  pw.TextSpan(
                    text:
                        '18 rue de l\'abbé Seny\n57480 Kerling-lès-Sierck\nfievetetfils.wkc@gmail.com',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 6,
                    ),
                  ),
                ]))
              ]))
    ]),
  );
}

String generateCode(num price, Product p) {
  var code = p.barcodePrefix +
      (price * 100 * 6.55957).round().toString().padLeft(5, "0");
  return code;
}

String getCheckSum(String code) {
  var odd = 0;
  var even = 0;

  for (int i = 0; i < code.length; i++) {
    var index = i + 1;
    var char = code[i];
    if (index % 2 == 1)
      odd += int.parse(code[i]);
    else
      even += int.parse(code[i]);
  }

  return ((10 - ((odd + even * 3) % 10)) % 10).toString();
}

pw.RichText textWithLabel(String label, String text, {double fontSize = 6.0}) {
  return pw.RichText(
      text: pw.TextSpan(children: [
    pw.TextSpan(
        text: "${label}: ",
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    pw.TextSpan(text: text, style: pw.TextStyle(fontSize: fontSize))
  ]));
}

class Barcode {
  static generate(PrintContext context, num weight, num pieces) async {
    var product = context.product;
    var client = context.client;
    var price = ((product.price / 1000) * weight).toStringAsFixed(2);
    var code = generateCode(num.parse(price), product);
    var pdf = pw.Document();
    var back = await fefSide(product);
    pdf.addPage(pw.Page(
        pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat(62 * mm, 63 * mm),
            theme: pw.ThemeData(
                header0: pw.TextStyle(
                    fontSize: 10,
                    decoration: pw.TextDecoration.none,
                    fontWeight: pw.FontWeight.bold),
                defaultTextStyle: pw.TextStyle(
                  fontSize: 6,
                ))),
        build: (c) {
          return pw.Padding(
              padding: const pw.EdgeInsets.only(
                top: 3,
                left: 5,
                right: 5,
                bottom: 3,
              ),
              child: pw.Column(children: [
                // front
                barcodeSide(
                    product, weight, price, code, client, context.date, pieces),
                back
              ]));
        }));

    final output = await getTemporaryDirectory();
    final fileName = "${output.path}/barcode.pdf";
    final file = File(fileName);
    await file.writeAsBytes(await pdf.save());
    return fileName;
  }
}
