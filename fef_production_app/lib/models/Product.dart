class Product {
  final String id;
  final String category;
  final String name;
  final ProductConservation conservation;
  final String composition;
  final num price;
  final String barcodePrefix;
  final String? allergens;

  Product(this.id, this.category, this.name, this.conservation,
      this.composition, this.price, this.barcodePrefix, this.allergens);

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        category = json['category'],
        name = json['name'],
        conservation = ProductConservation.fromJson(json['conservation']),
        composition = json['composition'],
        price = json['price'],
        barcodePrefix = json['barcodePrefix'],
        allergens = json['allergens'];
}

class ProductConservation {
  final num days;
  final String how;
  final String? complement;

  ProductConservation(this.days, this.how, this.complement);
  ProductConservation.fromJson(Map<String, dynamic> json)
      : days = json['days'],
        how = json['how'],
        complement = json['complement'];
}
