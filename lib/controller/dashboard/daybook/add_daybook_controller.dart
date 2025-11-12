
// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/paymenttype_model.dart';
import 'package:flutter/material.dart';

class AddDayBookController extends MyController {
  TextEditingController searchcontroller = TextEditingController();
  TextEditingController paidamountcontroller = TextEditingController();
  TextEditingController notescontroller = TextEditingController();
  TextEditingController deductionamountcontroller = TextEditingController();
  TextEditingController leavedayscontroller = TextEditingController();



  List<Map<String, dynamic>> addedRows = [];
  int nextId = 1; 
  String selectedPayment = 'Cash';
  String selectedStatus = 'Pending';

  final TextEditingController driverController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timeWorkController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController shiftingChargeController =
      TextEditingController();
  final TextEditingController driverSalaryController = TextEditingController();
  final TextEditingController driverBataController = TextEditingController();

  void updatePaymentType(String? value) {
    selectedPayment = value ?? 'Cash';
    update();
  }

  void updateStatus(String? value) {
    selectedStatus = value ?? 'Pending';
    update();
  }


  String vouchertypeid = "1";

  String branchids = "";

  late int totalpages;
  late int totalcount;

  List<dynamic> data = [];

  Map<String, dynamic> companysettings = {};
  Map<String, dynamic> tax = {};
  Map<String, dynamic> currency = {};

  Map<String, dynamic> driverbalance = {};

  dynamic selectedvehicle;
  PaymentTypeModel? selectedpaymenttype;

  DateTime? voucherdate = DateTime.now();

  bool loading = false;

  int pagenumber = 1;
  int pagelimit = 20;

  void setLoading(bool value) {
    loading = value;
    update();
  }

  void setPageNumber(int page) async {
    pagenumber = page;
    update();
  }

  setVoucherDate(DateTime? value) {
    voucherdate = value;
    update();
  }


}
