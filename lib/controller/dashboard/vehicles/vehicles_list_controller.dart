import 'dart:async';

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/branch_model.dart';
import 'package:flutter/material.dart';

class VehiclesListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController registrationcontroller = TextEditingController();
  TextEditingController chargeperhourcontroller = TextEditingController();
  TextEditingController minimumchargecontroller = TextEditingController();
  TextEditingController shiftingchargecontroller = TextEditingController();

  List<dynamic> data = [];

  bool loading = false;
  bool needshifting = false;

  BranchModel? selectedbranch = BranchModel.fromJson({
    'id': LocalStorage.getLoggedUserdata()['branchid'].toString(),
    'name': LocalStorage.getLoggedUserdata()['branchname'].toString()
  });

  Future<void> loadData([bool load = true]) async {
    setLoading(load);
    final response = await APIService.getVehicleListAPI(
      searchcontroller.text,
    );
    data = response['data'];
    setLoading(false);
    update();
  }

  void setData(dynamic data) {
    if (data != null) {
      namecontroller.text = data['name'];
      registrationcontroller.text = data['registration'].toString();
      chargeperhourcontroller.text = data['charge_per_hour'].toString();
      minimumchargecontroller.text = data['minimum_charge'].toString();
      needshifting = data["need_shifting"].toString() == "Y" ? true : false;
      shiftingchargecontroller.text = data['shifting_charge'].toString();
    } else {
      namecontroller.text = "";
      registrationcontroller.text = "";
      chargeperhourcontroller.text = "";
      minimumchargecontroller.text = "";
      needshifting = false;
      shiftingchargecontroller.text = "";
    }
  }

  void setLoading(bool value) {
    loading = value;
    update();
  }

  void setShifting(bool value) {
    needshifting = value;
    if (needshifting == false) {
      shiftingchargecontroller.text = "";
    }

    update();
  }

  @override
  void onInit() {
    super.onInit();
  }
}
