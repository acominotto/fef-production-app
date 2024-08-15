import 'package:fef_production_app/models/Product.dart';

class Client {
  final String id;
  final String name;
  final Map<String, Product> products;
  final Map<String, bool> meta;
  Client(this.id, this.name, this.products, this.meta);

  Client.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        products = Map.castFrom(json['products'])
            .map((key, value) => MapEntry(key, Product.fromJson(value))),
        meta = json['meta'] != null ? Map.castFrom(json['meta']) : Map();
}
