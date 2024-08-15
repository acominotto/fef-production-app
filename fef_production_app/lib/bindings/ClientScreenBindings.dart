import 'package:fef_production_app/controllers/PrintController.dart';
import 'package:get/get.dart';

class ClientScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(PrintController());
  }
}
