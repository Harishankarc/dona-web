import 'dart:async';

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:flutter/material.dart';

class ReminderDocumentListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();

  List<dynamic> data = [];

  Map<String, dynamic> listtype =  {"id": "V", "name": "Vehicle"} ;

  bool loading = false;

  List<dynamic> filterstatus = [
    {"id": "V", "name": "Vehicle"},
    {"id": "D", "name": "Driver"}
  ];

  Future<void> loadData([bool load = true]) async {
    setLoading(load);
    final response = await APIService.getDocumentListByReminderAPI(
      listtype.isEmpty ? "" : listtype["id"].toString(),
      searchcontroller.text,
    );
    data = response['data'];
    setLoading(false);
  }

  void setLoading(bool value) {
    loading = value;
    update();
  }
}
