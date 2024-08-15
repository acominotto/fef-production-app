import 'package:fef_production_app/bindings/AuthScreenBindings.dart';
import 'package:fef_production_app/bindings/ClientScreenBindings.dart';
import 'package:fef_production_app/bindings/HomeScreenBindings.dart';
import 'package:fef_production_app/bindings/PrintScreenBindings.dart';
import 'package:fef_production_app/screens/auth.dart';
import 'package:fef_production_app/screens/client.dart';
import 'package:fef_production_app/screens/home.dart';
import 'package:fef_production_app/screens/print.dart';
import 'package:get/get.dart';

var getPages = [
  GetPage(
      name: Routes.home,
      page: () => HomeScreen(),
      binding: HomeScreenBindings()),
  GetPage(
      name: Routes.auth,
      page: () => AuthScreen(),
      binding: AuthScreenBindings()),
  GetPage(
      name: Routes.client,
      page: () => ClientScreen(),
      binding: ClientScreenBindings()),
  GetPage(
      name: Routes.print,
      page: () => PrintScreen(),
      binding: PrintScreenBindings())
];

class Routes {
  static const home = '/home';
  static const auth = '/auth';
  static const client = '/client';
  static const print = '/print';
}
