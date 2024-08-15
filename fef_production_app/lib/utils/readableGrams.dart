String readableGrams(num grams) {
  if (grams < 1000) {
    return "${grams.toStringAsFixed(0)}g";
  } else {
    var kg = grams / 1000.0;
    if (kg % 1 == 0) return "${kg.toInt()} kg";
    return "${kg.toStringAsFixed(3).replaceAll(".", ",")} kg";
  }
}
