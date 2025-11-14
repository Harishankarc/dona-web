// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:flutter/material.dart';

class AddDayBookController extends MyController {
  List<dynamic> statuslist = [
    {"id": "P", "name": "Pending"},
    {"id": "C", "name": "Completed"},
    {"id": "H", "name": "Hold"},
  ];

  List<Map<String, dynamic>> addedRows = [];
  int nextId = 1;

  final TextEditingController discountcontroller = TextEditingController();
  final TextEditingController driverController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timeWorkController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController shiftingChargeController =
      TextEditingController();
  final TextEditingController driverSalaryController = TextEditingController();
  final TextEditingController driverBataController = TextEditingController();

  dynamic selectedVehicle;
  dynamic selectedDriver;
  dynamic selectedCustomer;
  dynamic selectedPayment;
  dynamic selectedStatus;

  void updateVehicle(dynamic vehicle) {
    selectedVehicle = vehicle;
    shiftingChargeController.text = selectedVehicle == null
        ? ""
        : selectedVehicle["shifting_charge"].toString();
    update();
  }

  void updateDriver(dynamic driver) {
    selectedDriver = driver;
    driverSalaryController.text = selectedDriver == null
        ? ""
        : selectedDriver["salary_per_day"].toString();
    update();
  }

  void updateCustomer(dynamic customer) {
    selectedCustomer = customer;
    update();
  }

  void updateRate(String hour) {
    num hours = num.tryParse(hour) ?? 0;

    if (hours < 1) {
      rateController.text = selectedVehicle == null
          ? "0"
          : selectedVehicle["minimum_charge"].toString();
      amountController.text =
          (num.parse(rateController.text) * num.parse(timeWorkController.text))
              .toStringAsFixed(2);
    } else {
      rateController.text = selectedVehicle == null
          ? "0"
          : selectedVehicle["charge_per_hour"].toString();
      amountController.text =
          (num.parse(rateController.text) * num.parse(timeWorkController.text))
              .toStringAsFixed(2);
    }

    update();
  }

  void updatePaymentType(dynamic value) {
    selectedPayment = value;
    update();
  }

  void updateStatus(dynamic value) {
    selectedStatus = value;
    update();
  }

  String vouchertypeid = "1";

  List<dynamic> data = [];

  DateTime? voucherdate = DateTime.now();

  bool loading = false;

  void setLoading(bool value) {
    loading = value;
    update();
  }

  void setVoucherDate(DateTime? value) {
    voucherdate = value;
    update();
  }

  // Remove item from list
  void removeItem(int index) {
    if (index >= 0 && index < data.length) {
      data.removeAt(index);
      update();
    }
  }


  Future<void> addVehicleData(
    Map<String, dynamic> maindata,
  ) async {
    String vehicleId = maindata["vehicle_id"].toString();
    String vehicleName = maindata["vehicle_name"].toString();

    int index = data.indexWhere(
      (item) => item["vehicle_id"].toString() == vehicleId,
    );

    if (index != -1) {
      data[index]["vehicles_data"].add(maindata);
    } else {
      data.add({
        "vehicle_index": data.length,
        "vehicle_id": vehicleId,
        "vehicle_name": vehicleName,
        "vehicles_data": [maindata],
      });
    }

    update();
  }

  void removeVehicleDataItem(
    int vehicleIndex,
    int dataIndex,
  ) {
    if (vehicleIndex < 0 || vehicleIndex >= data.length) {
      return;
    }

    List<dynamic> vehiclesData = data[vehicleIndex]["vehicles_data"];

    if (dataIndex < 0 || dataIndex >= vehiclesData.length) {
      return;
    }

    vehiclesData.removeAt(dataIndex);

    if (vehiclesData.isEmpty) {
      data.removeAt(vehicleIndex);
    }

    for (int i = 0; i < data.length; i++) {
      data[i]["vehicle_index"] = i;
    }
  }

  void clearMainData() {}

  Future<Map<String, dynamic>> addVoucher() async {
    print("This is the local storage");
    print(LocalStorage.getLoggedUserdata());
    return APIService.addVoucherAPI(
        "VE",
        LocalStorage.getLoggedUserdata()['userid'].toString(),
        APIService.formatDate(voucherdate, true),
        LocalStorage.getLoggedUserdata()['branchid'].toString(),
        data);
  }

  @override
  void dispose() {
    driverController.dispose();
    vehicleController.dispose();
    locationController.dispose();
    timeWorkController.dispose();
    amountController.dispose();
    shiftingChargeController.dispose();
    driverSalaryController.dispose();
    driverBataController.dispose();
    super.dispose();
  }
}
