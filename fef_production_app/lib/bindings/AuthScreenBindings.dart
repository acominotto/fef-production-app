import 'package:fef_production_app/controllers/AuthController.dart';
import 'package:get/get.dart';

class AuthScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
