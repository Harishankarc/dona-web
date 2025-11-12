import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/paymenttype_model.dart';
import 'package:flutter/material.dart';

class AnalyticsController extends MyController {
  TextEditingController paidamountcontroller = TextEditingController();
  TextEditingController notescontroller = TextEditingController();
  TextEditingController deductionamountcontroller = TextEditingController();
  TextEditingController leavedayscontroller = TextEditingController();

  bool isLoading = false;

  dynamic data = {};
  List<dynamic> voucherdata = [];

  Map<String, dynamic> driverbalance = {};
  Map<String, dynamic> tax = {};
  Map<String, dynamic> currency = {};

  dynamic selectedvehicle;
  PaymentTypeModel? selectedpaymenttype;

  DateTime voucherdate = DateTime.now();

  Future<void> fetchData() async {
    setLoading(true);

    final dynamic currencyresponse = await APIService.getCurrencyListAPI();

    final dynamic taxmasterresponse =
        await APIService.getTaxMasterByTerm("Y", "");
    currency = (currencyresponse).isNotEmpty
        ? {
            'id': currencyresponse[0]["id"].toString(),
            'currency': currencyresponse[0]["currency"].toString(),
            'exchange_rate': currencyresponse[0]["exchange_rate"].toString(),
          }
        : {};

    tax = taxmasterresponse.isNotEmpty ? taxmasterresponse[0] : {};
    final response = await APIService.dashboard();
    if (response['status'] == 'success') {
      data = response['data'];
    }
    final voucehrresp = await APIService.dashboardDriverBalances();
    if (voucehrresp['status'] == 'success') {
      voucherdata = voucehrresp['data'];
    }
    print(data);
    print(voucherdata);
    setLoading(false);
  }

  void setLoading(bool value) {
    isLoading = value;
    update();
  }

  void setCollectionDate(dynamic value) {
    voucherdate = value;
    update();
  }

  void setPaymentType(PaymentTypeModel? value) {
    selectedpaymenttype = value;
    update();
  }

  void calculateDeductionAmount() async {
    deductionamountcontroller.text = (num.parse(
                selectedvehicle["charge_per_day"].toString().isEmpty
                    ? "0"
                    : selectedvehicle["charge_per_day"].toString()) *
            num.parse(leavedayscontroller.text.isEmpty
                ? "0"
                : leavedayscontroller.text))
        .toStringAsFixed(2);
    update();
  }

  Future<List<dynamic>> selectVehicleList(String term) async {
    final dynamic vehicleresponse = await APIService.getVehicleListAPI(term);
    return vehicleresponse["status"] == "success"
        ? vehicleresponse["data"]
        : [];
  }

  void setSelectedVehicle(dynamic val) async {
    if (val != null) {
      selectedvehicle = val;
      final dynamic response = await APIService.getVehicleAndDriverBalanceAPI(
          selectedvehicle["assigned_to"].toString(),
          selectedvehicle["id"].toString());
      driverbalance = response["status"] == "success" ? response : {};
      print("This is the selected vehicle");
      print(selectedvehicle);
    } else {
      selectedvehicle = null;
      driverbalance = {};
    }

    update();
  }

  Future<void> setData(dynamic value) async {
    print("This is the collection details");
    print(value);
    if (value == null) {
      selectedvehicle = null;
      driverbalance = {};
      voucherdate = DateTime.now();
      paidamountcontroller.text = "";
      selectedpaymenttype = null;
      notescontroller.text = "";
      leavedayscontroller.text = "";
      deductionamountcontroller.text = "";
    } else {
      selectedvehicle = {
        "id": value["vehicle_id"].toString(),
        "name": value["vehicle_main_name"].toString(),
        "registration": value["registration_number"].toString(),
        "assigned_to": value["subledger_id"].toString(),
        "assigned_to_name": value["subledger_name"].toString(),
        "chasis_number": value["chasis_number"].toString(),
        "engine_number": value["engine_number"].toString(),
        "advance_amount": value["advance_amount"].toString(),
        "charge_per_day": value["charge_per_day"].toString()
      };
      print("This is the editing");
      print(selectedvehicle);
      final dynamic response = await APIService.getVehicleAndDriverBalanceAPI(
          selectedvehicle["assigned_to"].toString(),
          selectedvehicle["id"].toString());
      driverbalance = response["status"] == "success" ? response : {};
      voucherdate = DateTime.parse(value['voucher_date'].toString());
      paidamountcontroller.text = value["voucher_value"].toString();
      selectedpaymenttype = PaymentTypeModel(
          id: value["payment_type_id"].toString(),
          name: value["payment_type_name"].toString());
      notescontroller.text = value["remarks"].toString();
    }
    update();
  }

  Future<Map<String, dynamic>> savePaymentCollection() async {
    print("This is the cache data");
    print(LocalStorage.getLoggedUserdata());
    final dynamic response = await APIService.addPaymentCollectionVoucherAPI(
        "MC",
        selectedvehicle["id"].toString(),
        selectedvehicle["name"].toString() +
            " / " +
            selectedvehicle["registration"].toString(),
        selectedvehicle["assigned_to"].toString(),
        selectedvehicle["assigned_to_name"].toString(),
        voucherdate.year.toString() +
            "-" +
            voucherdate.month.toString() +
            "-" +
            voucherdate.day.toString(),
        currency["id"].toString(),
        currency["currency"].toString(),
        currency["exchange_rate"].toString(),
        paidamountcontroller.text,
        selectedpaymenttype!.id.toString(),
        notescontroller.text,
        LocalStorage.getLoggedUserdata()['branchid'].toString(),
        LocalStorage.getLoggedUserdata()['userid'].toString());
    return response;
  }

  Future<Map<String, dynamic>> saveLeaveVoucher(String fileidref) async {
    final dynamic response = await APIService.addLeaveVoucherAPI(
        "LV",
        selectedvehicle["id"].toString(),
        "${selectedvehicle["name"]} / ${selectedvehicle["registration"]}",
        selectedvehicle["assigned_to"].toString(),
        selectedvehicle["assigned_to_name"].toString(),
        "${voucherdate.year}-${voucherdate.month}-${voucherdate.day}",
        currency["id"].toString(),
        currency["currency"].toString(),
        currency["exchange_rate"].toString(),
        deductionamountcontroller.text,
        selectedvehicle["charge_per_day"].toString(),
        leavedayscontroller.text,
        notescontroller.text,
        LocalStorage.getLoggedUserdata()['branchid'].toString(),
        LocalStorage.getLoggedUserdata()['userid'].toString(),
        fileidref);
    return response;
  }
}
