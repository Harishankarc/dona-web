import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:flutter/material.dart';

class VehicleTrackingListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();

  bool loading = false;
  DateTime? filterdate = DateTime.now();

  List<dynamic> data = [];

  Future<void> loadData([bool load = true]) async {
    setLoading(load);
    final response = await APIService.getVehicleTrackingListAPI(
      searchcontroller.text,
      APIService.formatDate(filterdate, true),
    );
    data = response["status"] == "success" ? response['data'] : [];
    setLoading(false);
    update();
  }

  Future<void> syncData([bool load = true]) async {
    setLoading(load);
    await APIService.getSyncDataAPI();
    loadData(true);
    update();
  }

  void setLoading(bool value) {
    loading = value;
    update();
  }

  setDate(DateTime? value) {
    filterdate = value;
    loadData();
    update();
  }
}
