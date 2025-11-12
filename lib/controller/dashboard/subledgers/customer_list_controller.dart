import 'dart:async';

import 'package:flutter/material.dart';
import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/branch_model.dart';

class CustomerListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();

  TextEditingController namecontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController secondaryphonecontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();

  String subledgertype = "3";

  @override
  void onInit() {
    loadData();
    super.onInit();
  }

  List<dynamic> data = [];

  bool loading = false;

  BranchModel? selectedbranch = BranchModel.fromJson({
    'id': LocalStorage.getLoggedUserdata()['branchid'].toString(),
    'name': LocalStorage.getLoggedUserdata()['branchname'].toString()
  });

  Future<void> loadData([bool load = true]) async {
    setLoading(load);
    final response = await APIService.getSubledgerListAPI(
        searchcontroller.text, subledgertype);
    data = response["status"] == "success" ? response['data'] : [];
    setLoading(false);
  }

  void setLoading(bool value) {
    loading = value;
    update();
  }

  void clearForm() {
    namecontroller.clear();
    phonecontroller.clear();
    secondaryphonecontroller.clear();
    addresscontroller.clear();

    update();
  }

  void setData(dynamic value) {
    if (value != null) {
      namecontroller.text = value['name'];
      phonecontroller.text = value['phone'];
      secondaryphonecontroller.text = value['secondary_phone'];
      addresscontroller.text = value['address'];
    } else {
      namecontroller.text = "";
      phonecontroller.text = "";
      secondaryphonecontroller.text = "";
      addresscontroller.text = "";
    }
    update();
  }
}
