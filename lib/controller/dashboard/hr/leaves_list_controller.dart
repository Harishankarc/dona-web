import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LeavesListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();
  TextEditingController deductionamountcontroller = TextEditingController();
  TextEditingController leavedayscontroller = TextEditingController();
  TextEditingController notescontroller = TextEditingController();

  String vouchertypeid = "6";

  String branchids = "";

  late int totalpages;
  late int totalcount;

  List<dynamic> data = [];

  Map<String, dynamic> companysettings = {};
  Map<String, dynamic> tax = {};
  Map<String, dynamic> currency = {};

  dynamic selecteddriver;
  dynamic selectedvehicle;

  DateTime voucherdate = DateTime.now();

  bool loading = false;

  int pagenumber = 1;
  int pagelimit = 20;

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

  void setLoading(bool value) {
    loading = value;
    update();
  }

  void setLeaveDate(dynamic value) {
    voucherdate = value;
    update();
  }

  void setPageNumber(int page) async {
    pagenumber = page;
    await loadVoucher();
    update();
  }

  void setData(dynamic value) {
    if (value == null) {
      selecteddriver = null;
      selectedvehicle = null;
      voucherdate = DateTime.now();
      deductionamountcontroller.text = "";
      notescontroller.text = "";
    } else {
      print("This is the data details");
      print(value);
      selecteddriver = {
        "id": value["subledger_id"].toString(),
        "name": value["subledger_name"].toString()
      };
      selectedvehicle = {
        "id": value["vehicle_id"].toString(),
        "name": value["vehicle_main_name"].toString(),
        "registration": value["registration_number"].toString(),
        "charge_per_day": value["charge_per_day"].toString()
      };
      voucherdate = DateTime.parse(value['voucher_date'].toString());
      leavedayscontroller.text = value["leave_days"].toString();
      deductionamountcontroller.text = value["voucher_value"].toString();
      notescontroller.text = value["remarks"].toString();
    }
    update();
  }

  Future<List<dynamic>> selectDriverList(String term) async {
    final dynamic driverresponse = await APIService.getDriverListAPI(term, "1");
    return driverresponse["status"] == "success" ? driverresponse["data"] : [];
  }

  Future<List<dynamic>> selectVehicleList(String term) async {
    final dynamic vehicleresponse =
        await APIService.getVehicleListByAssignedToAPI(
            term, selecteddriver["id"].toString());
    return vehicleresponse["status"] == "success"
        ? vehicleresponse["data"]
        : [];
  }

  void setSelectedDriver(dynamic val) async {
    if (val != null) {
      selecteddriver = val;
    } else {
      selecteddriver = null;
      selectedvehicle = null;
    }

    update();
  }

  void setSelectedVehicle(dynamic val) async {
    if (val != null) {
      selectedvehicle = val;
    } else {
      selectedvehicle = null;
      deductionamountcontroller.text = "";
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

  Future<Map<String, dynamic>> saveLeaveVoucher() async {
    final dynamic response = await APIService.addLeaveVoucherAPI(
        "LV",
        selectedvehicle["id"].toString(),
        "${selectedvehicle["name"]} / ${selectedvehicle["registration"]}",
        selecteddriver["id"].toString(),
        selecteddriver["name"].toString(),
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
        "");
    return response;
  }

  Future<Map<String, dynamic>> editLeaveVoucher(String id) async {
    final dynamic response = await APIService.editLeaveVoucherAPI(
      id,
      selectedvehicle["id"].toString(),
      "${selectedvehicle["name"]} / ${selectedvehicle["registration"]}",
      selecteddriver["id"].toString(),
      selecteddriver["name"].toString(),
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
