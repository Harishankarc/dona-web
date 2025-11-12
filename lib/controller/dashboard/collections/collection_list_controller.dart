// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/paymenttype_model.dart';
import 'package:flutter/material.dart';

class CollectionsListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();
  TextEditingController paidamountcontroller = TextEditingController();
  TextEditingController notescontroller = TextEditingController();
  TextEditingController deductionamountcontroller = TextEditingController();
  TextEditingController leavedayscontroller = TextEditingController();

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

  DateTime voucherdate = DateTime.now();

  bool loading = false;

  int pagenumber = 1;
  int pagelimit = 20;

  void setLoading(bool value) {
    loading = value;
    update();
  }

  void setPageNumber(int page) async {
    pagenumber = page;
    await loadVoucher();
    update();
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

  Future<Map<String, dynamic>> editPaymentCollection(String id) async {
    final dynamic response = await APIService.editPaymentCollectionVoucherAPI(
        id,
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

  Future<Map<String, dynamic>> editLeaveVoucherByReferrenceID(
      String fileidref) async {
    final dynamic response = await APIService.editLeaveVoucherByReferrenceIDAPI(
      fileidref,
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
    );
    return response;
  }

  Future<void> setLeaveVoucherData(String fileidref) async {
    final dynamic response =
        await APIService.getLeaveVoucherByReferrenceIDAPI(fileidref);
    leavedayscontroller.text = response["status"] == "success"
        ? response["data"]["leave_days"].toString()
        : "";
    selectedvehicle["charge_per_day"] = response["status"] == "success"
        ? response["data"]["amount"].toString()
        : selectedvehicle["charge_per_day"];
    deductionamountcontroller.text = response["status"] == "success"
        ? response["data"]["voucher_value"].toString()
        : "";
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

  Future<void> loadData([bool load = true]) async {
    setLoading(load);
    final dynamic companyresponse = await APIService.getCompanyDetails();
    final dynamic currencyresponse = await APIService.getCurrencyListAPI();

    companysettings =
        companyresponse['status'] == 'success' ? companyresponse['data'] : {};
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
    await loadVoucher();
    setLoading(false);
    update();
  }

  Future<void> loadVoucher() async {
    Map<String, dynamic> response =
        await APIService.postVoucherListByPaginationByLimit(
            searchcontroller.text,
            vouchertypeid,
            branchids,
            pagenumber.toString(),
            pagelimit.toString(),
            LocalStorage.getLoggedUserdata()['userid'].toString());
    if (response["status"] == "success") {
      data = response["data"];
      totalpages = response["totalPages"];
      totalcount = response["totalCount"];
    } else {
      data = [];
    }
    update();
  }
}
