import 'dart:async';

import 'package:flutter/material.dart';
import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';

class ModelsListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();

  List<dynamic> data = [];

  bool loading = false;

  TextEditingController namecontroller = TextEditingController();

  Future<void> loadData([bool load = true]) async {
    setLoading(load);
    final response =
        await APIService.getVehicleModelTypes(searchcontroller.text);
    data = response;
    setLoading(false);
  }

  void setLoading(bool value) {
    loading = value;
    update();
  }

  void clearData() {
    namecontroller.text = "";
    update();
  }

  setData(dynamic value) {
    namecontroller.text = value['name'] ?? '';
    update();
  }
}
