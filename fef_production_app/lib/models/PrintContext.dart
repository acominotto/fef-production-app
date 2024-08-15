import 'package:fef_production_app/models/Client.dart';
import 'package:fef_production_app/models/Product.dart';

class PrintContext {
  final Client client;
  final Product product;
  DateTime date;

  PrintContext(this.client, this.product)
      : this.date = PrintContext._initDate();
  get clientId => this.client.id;

  get clientName => this.client.name;

  static _initDate() {
    var now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
