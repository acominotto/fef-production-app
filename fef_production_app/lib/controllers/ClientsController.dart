import 'dart:convert';

import 'package:fef_production_app/const/Env.dart';
import 'package:fef_production_app/const/GetPages.dart';
import 'package:fef_production_app/controllers/AuthController.dart';
import 'package:fef_production_app/controllers/PrintController.dart';
import 'package:fef_production_app/models/Client.dart';
import 'package:fef_production_app/models/PrintContext.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ClientsController extends GetxController {
  var _clients = <Client>[].obs;
  var _currentClient = Rxn<Client>();

  List<Client> get clients => this._clients.value;
  Client? get currentClient => this._currentClient.value;

  fetchData() async {
    try {
      var token = Get.find<AuthController>().token;
      var response = await http.get(
          Uri.parse('${Env.BackendURL}/mobile/v1/clients'),
          headers: {'Cookie': 'fef-cookie=${token}'});
      if (response.statusCode == 200) {
        var result = jsonDecode(utf8.decode(response.bodyBytes));
        print('clients: ' + result.toString());
        _clients.value =
            List.from(result).map((json) => Client.fromJson(json)).toList();
      } else {
        print('Error while fetching clients: ${token} ' +
            response.statusCode.toString());
        Get.snackbar('Error while fetching clients', response.toString());
      }
    } catch (e) {
      Get.snackbar('Error while fetching clients', e.toString());
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchData();
  }

  selectClient(Client c) {
    this._currentClient.value = c;
    Get.toNamed(Routes.client);
  }

  selectProduct(String productId) {
    var client = this.currentClient!;
    var product = client.products[productId]!;
    Get.find<PrintController>().setContext(new PrintContext(client, product));
    Get.toNamed(Routes.print);
  }
}
