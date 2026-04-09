import 'package:fef_production_app/models/Product.dart';

class Client {
  final String id;
  final String name;
  final Map<String, Product> products;
  final Map<String, bool> meta;
  /// How the price is encoded in EAN-13: `franc` (legacy ×6.55957) or `euro` (centimes).
  final String barcodePriceBase;

  Client(this.id, this.name, this.products, this.meta,
      [this.barcodePriceBase = 'franc']);

  Client.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        products = Map.castFrom(json['products'])
            .map((key, value) => MapEntry(key, Product.fromJson(value))),
        meta = json['meta'] != null ? Map.castFrom(json['meta']) : Map(),
        barcodePriceBase = _parseBarcodePriceBase(json['barcodePriceBase']);
}

String _parseBarcodePriceBase(dynamic v) {
  if (v == null) return 'franc';
  final s = v.toString().toLowerCase();
  return s == 'euro' ? 'euro' : 'franc';
}
