import 'dart:async';

import 'package:flutter/material.dart';
import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';

class DocumentTypeController extends MyController {
  TextEditingController searchcontroller = TextEditingController();

  List<dynamic> data = [];

  List<Map<String, dynamic>> documentforlist = [
    {'id': 'A', 'name': 'For All'},
    {'id': 'V', 'name': 'Vehicle'},
    {'id': 'D', 'name': 'Driver'},
  ];

  List<Map<String, dynamic>> ismandatorylist = [
    {'id': 'Y', 'name': 'Yes'},
    {'id': 'N', 'name': 'No'},
  ];

  bool loading = false;

  TextEditingController namecontroller = TextEditingController();
  TextEditingController remainderdayscontroller = TextEditingController();
  Map<String, dynamic> selecteddocumentfor = {};
  Map<String, dynamic> selectedismandatory = {};

  Future<void> loadData([bool load = true]) async {
    setLoading(load);
    final response =
        await APIService.getDocumentTypes(searchcontroller.text, "");
    data = response;
    setLoading(false);
  }

  void setLoading(bool value) {
    loading = value;
    update();
  }

  void setDocumentFor(dynamic value) {
    selecteddocumentfor = value;
    update();
  }

  void setIsMandatory(dynamic value) {
    selectedismandatory = value;
    update();
  }

  void setClearData() {
    namecontroller.text = "";
    remainderdayscontroller.text = "";
    selecteddocumentfor = {};
    selectedismandatory = {};
    update();
  }

  setData(dynamic value) {
    namecontroller.text = value['name'] ?? '';
    remainderdayscontroller.text = value["reminder_days"].toString().isEmpty
        ? "0"
        : value["reminder_days"].toString();
    selecteddocumentfor = documentforlist[
        getIndexById(documentforlist, value["document_for"].toString())];
    selectedismandatory = ismandatorylist[
        getIndexById(ismandatorylist, value["is_mandatory"].toString())];
    update();
  }

  int getIndexById(List<dynamic> dataList, String id) {
    return dataList.indexWhere((element) => element['id'].toString() == id);
  }
}
