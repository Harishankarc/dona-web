import 'dart:async';

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DriversDocumentController extends MyController {
  TextEditingController searchcontroller = TextEditingController();

  List<dynamic> data = [];

  String listtype = "D";

  dynamic selecteddocumenttype;
  DateTime? dateOfValidity;
  DateTime? reminderDate;

  PlatformFile? attachment;

  bool loading = false;

  Future<void> loadData([bool load = true]) async {
    setLoading(load);
    final response = await APIService.getDocumentListByTypeAPI(
      listtype,
      searchcontroller.text,
    );
    data = response['data'];
    setLoading(false);
  }

  void setLoading(bool value) {
    loading = value;
    update();
  }

  void setSelecteddocumenttype(dynamic val) {
    selecteddocumenttype = val;
    update();
  }

  setValidity(DateTime? value) {
    dateOfValidity = value;
    reminderDate = dateOfValidity?.subtract(Duration(
        days: int.parse(selecteddocumenttype["reminder_days"].toString())));
    update();
  }

  setReminder(DateTime? value) {
    reminderDate = value;
    update();
  }

   setAttachment(PlatformFile? value) {
    attachment = value;
    update();
  }


  void setDocumentData(dynamic data) {
    if (data != null) {
      selecteddocumenttype = data['document_type_id'].toString() == "0"
          ? null
          : {
              'id': data['document_type_id'].toString(),
              'name': data['document_type_name'].toString(),
              "reminder_days": data["reminder_days"].toString()
            };
      dateOfValidity = data['validity_date'].toString() == '0000-00-00'
          ? null
          : DateTime.parse(data['validity_date'].toString());
      reminderDate = data['reminder_date'].toString() == '0000-00-00'
          ? null
          : DateTime.parse(data['reminder_date'].toString());
      attachment = data == null
          ? null
          : data['attachment'].toString().isEmpty
              ? null
              : PlatformFile(name: data['attachment'], size: 0);
    }
  }
}
