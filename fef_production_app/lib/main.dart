import 'package:fef_production_app/bindings/AuthScreenBindings.dart';
import 'package:fef_production_app/const/GetPages.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialBinding: AuthScreenBindings(),
      getPages: getPages,
      initialRoute: Routes.auth,
    );
  }
}
