import 'package:fef_production_app/controllers/ClientsController.dart';
import 'package:get/get.dart';

class HomeScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClientsController());
  }
}
