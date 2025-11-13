// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:LeLaundrette/controller/my_controller.dart';
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

  void reassignIDs() {
    int newId = 1;

    Map<String, String> driverIdMap = {};

    for (var item in data) {
      String driver = item['driver_name'];

      if (!driverIdMap.containsKey(driver)) {
        driverIdMap[driver] = newId.toString();
        newId++;
      }

      item['id'] = driverIdMap[driver]!;
    }

    nextId = newId;

    update();
  }

  String vouchertypeid = "1";
  String branchids = "";

  // Main data list for items
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

  // Calculate totals
  String calculateTotal(List<dynamic> items) {
    double total = 0;
    for (var item in items) {
      double rate = double.tryParse(item['rate']?.toString() ?? '0') ?? 0;
      double quantity =
          double.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      total += rate * quantity;
    }
    return total.toString();
  }

  String calculateTotalTax(List<dynamic> items) {
    double totalTax = 0;
    for (var item in items) {
      double rate = double.tryParse(item['rate']?.toString() ?? '0') ?? 0;
      double quantity =
          double.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      double taxPercentage =
          double.tryParse(item['tax_percentage']?.toString() ?? '0') ?? 0;
      totalTax += (rate * quantity) * (taxPercentage / 100);
    }
    return totalTax.toString();
  }

  String calculateTotalNet(List<dynamic> items) {
    double totalNet = 0;
    for (var item in items) {
      double net = double.tryParse(item['net']?.toString() ?? '0') ?? 0;
      double quantity =
          double.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      totalNet += net * quantity;
    }
    return totalNet.toString();
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
