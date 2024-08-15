import 'dart:convert';

import 'package:fef_production_app/const/Env.dart';
import 'package:fef_production_app/const/GetPages.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  var _isLoaded = false.obs;
  var _token = ''.obs;

  bool get isLoaded => _isLoaded.value;
  String get token => _token.value;

  fetchData() async {
    try {
      var body = jsonEncode(<String, String>{'pin': 'F13V3T'});
      print('getting auth: ' + body);
      var response = await http.post(
          Uri.parse('${Env.BackendURL}/auth/sign-in'),
          headers: <String, String>{'Content-Type': 'application/json'},
          body: body);

      if (response.statusCode == 200) {
        print('updating cookie');
        updateCookie(response);
        Get.offNamed(Routes.auth);
        Get.toNamed(Routes.home);
      } else {
        print('response status: ' + response.statusCode.toString());
        print('response body: ' + response.body.toString());
      }
    } catch (e) {
      print('error: ' + e.toString());
      Get.snackbar('Error while fetching clients', e.toString());
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    print('onInit');
    await fetchData();
  }

  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      var cookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
      print('cookie: ' + rawCookie);
      _token.value = cookie.substring("login-cookie=".length);
      _isLoaded.value = true;
      Get.snackbar('cookie', 'has value: ' + _token.value);
      print('cookie has value ' + _token.value);
    } else {
      Get.snackbar('cookie', 'is absent');
      print('cookie is absent');
    }
  }
}
