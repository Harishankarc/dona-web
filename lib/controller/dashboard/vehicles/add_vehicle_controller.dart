import 'dart:async';

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/branch_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AddVehicleController extends MyController {
  TextEditingController searchcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController brandcontroller = TextEditingController();
  TextEditingController registrationcontroller = TextEditingController();
  TextEditingController enginenocontroller = TextEditingController();
  TextEditingController chassiscontroller = TextEditingController();
  TextEditingController gpsimeicontroller = TextEditingController();
  TextEditingController gpssimnumbercontroller = TextEditingController();
  TextEditingController gpsimsinumbercontroller = TextEditingController();

  bool isdefault = false;
  bool selectedall = false;

  DateTime? date = DateTime.now();

  Map<String, String> statusMap = {
    'P': 'Pending',
    'WS': 'Work Started',
    'WC': 'Work Completed',
    'D': 'Delivered',
  };
  MapEntry<String, String>? updatedStatus;
  int? selectedStatusIndex;

  Map<String, Color> statusColorMap = {
    'O': Colors.blue,
    'D': Colors.green,
    'R': Colors.red,
    'P': Colors.amber
  };

  List<Map<String, dynamic>> vehiclestatus = [
    {'id': 'A', 'name': 'Active'},
    {'id': 'D', 'name': 'Decommissioned '},
    {'id': 'R', 'name': 'Repairs '},
  ];

  dynamic selectedvehiclestatus = {'id': 'A', 'name': 'Active'};

  List<dynamic> data = [];

  List<dynamic> allocationsdata = [];

  bool loading = false;

  int page = 1;
  int limit = 20;

  BranchModel? selectedbranch = BranchModel.fromJson({
    'id': LocalStorage.getLoggedUserdata()['branchid'].toString(),
    'name': LocalStorage.getLoggedUserdata()['branchname'].toString()
  });

  dynamic selectedtobranch;
  List<Map<String, dynamic>> modelList = [];

  int totalPages = 0;

  DateTime? startDate;
  DateTime? endDate;
  DateTime? dateofreg;
  DateTime? insurancevalidupto;
  DateTime? fitnessvalidupto;
  DateTime? taxvalidupto;
  DateTime? permitvalidupto;
  DateTime? metervalidupto;
  DateTime? puccvalidupto;
  DateTime? gas1validupto;
  DateTime? gas2validupto;

  String? selectedCategory;
  String? selectedDriver;
  PlatformFile? attachment;

  setAttachment(PlatformFile? value) {
    attachment = value;
    update();
  }

   void setVehicleStatus(dynamic value) {
    selectedvehiclestatus = value;
    update();
  }

  void clearForm() {
    searchcontroller.clear();
    namecontroller.clear();
    brandcontroller.clear();
    registrationcontroller.clear();
    enginenocontroller.clear();
    chassiscontroller.clear();
    selectedvehiclemodel = null;
    selectedvehicleBrands = null;
    selectedvehiclecategory = null;
    dateofreg = null;
    attachment = null;
    selectedvehicleDriver = null;
  }

  void setSelectedCategory(String? value) {
    selectedCategory = value;
    update();
  }

  dynamic selectedvehiclemodel;
  void setSelectedModel(dynamic val) {
    selectedvehiclemodel = val;
    update();
  }

  dynamic selectedvehicleBrands;
  void setSelectedBrands(dynamic val) {
    selectedvehicleBrands = val;
    update();
  }

  dynamic selectedvehiclecategory;
  void setSelectedVehicleCategory(dynamic val) {
    selectedvehiclecategory = val;
    update();
  }

  dynamic selectedvehicleDriver;
  void setSelectedVehicleDriver(dynamic val) {
    selectedvehicleDriver = val;
    update();
  }

  void setSelectedDriver(String? value) {
    selectedCategory = value;
    update();
  }

  void setBranch(value) {
    selectedbranch = value;
    loadData();
  }

  void setDate(DateTime? value) {
    date = value;
  }

  void setRegDate(DateTime? value) {
    dateofreg = value;
    update();
  }

  void setInsuranceDate(DateTime? value) {
    insurancevalidupto = value;
    update();
  }

  void setFitnessDate(DateTime? value) {
    fitnessvalidupto = value;
    update();
  }

  void setTaxValidDate(DateTime? value) {
    taxvalidupto = value;
    update();
  }

  void setPermitValidDate(DateTime? value) {
    permitvalidupto = value;
    update();
  }

  void setMeterValidDate(DateTime? value) {
    metervalidupto = value;
    update();
  }

  void setPUCCValidDate(DateTime? value) {
    puccvalidupto = value;
    update();
  }

  void setGas1ValidDate(DateTime? value) {
    gas1validupto = value;
    update();
  }

  void setGas2ValidDate(DateTime? value) {
    gas2validupto = value;
    update();
  }

  void setUpdateStatus(
    MapEntry<String, String>? value,
  ) {
    updatedStatus = value;

    update();
  }

  void setStatusData(dynamic data) {
    updatedStatus = MapEntry(
      data['status'].toString(),
      statusMap[data['status']].toString(),
    );
    selectedStatusIndex =
        statusMap.keys.toList().indexOf(data['status'].toString());
    update();
  }

  Future<void> loadData() async {
    loading = true;
    final response = await APIService.getVehicleListAPI(
      searchcontroller.text,
    );
    data = response['data'];
    loading = false;
    update();
  }

  void setLoading(bool value) {
    loading = value;
    update();
  }

  void setAllocationData(List<dynamic> value) {
    allocationsdata = value;
    update();
  }

  String getIdFromName(
    String name,
  ) {
    return RegExp(r'\((\d+)\)').firstMatch(name)?.group(1) ?? '';
  }

  void setDefault(bool? value) {
    isdefault = value ?? false;

    update();
  }

  void onPreviousPage(int cpage) {
    page = cpage;
    loadData();
  }

  void onNextPage(int cpage) {
    page = cpage;
    loadData();
  }

  void gotoLastPage(int? p) {
    page = p ?? 1;
    loadData();
  }

  void gotoFirstPage(int? p) {
    page = p ?? 1;
    loadData();
  }

  setStartDate(DateTime? value) {
    startDate = value;
    loadData();
    update();
  }

  setEndDate(DateTime? value) {
    endDate = value;
    loadData();
    update();
  }

  Future<Map<String, dynamic>> viewVoucherByFileID(
      String fileid, String branchid) async {
    Map<String, dynamic> response =
        await APIService.getSalesDetailsByFileIdAPINew(fileid, branchid);
    print("This is the file details");
    print(response);
    if (response["status"] == "success") {
      return response;
    } else {
      return {};
    }
  }

  Future<Map<String, dynamic>> setVoucherData(data) async {
    print(data);
    final response = await APIService.getSalesDetailsByFileIdAPI(
        data['file_id'].toString(), data['branch_id'].toString());
    return response;
  }

  Future<Map<String, dynamic>> setVoucherAllocationsData(data) async {
    print(data);
    final response = await APIService.getVoucherAllocationDetailsByFileID(
        data['file_id'].toString());
    return response;
  }

  Future<String> downloadInvoice(res, data) async {
    final companyresponse = await APIService.getCompanyDetails();
    print("========================");
    print(companyresponse['data']['address']);
    print("========================");
    final items = (res['voucher_details'] as List).map((item) {
      return {
        'item_code': item['item_code'],
        'item_name': item['item_name'],
        'unit_name': item['unit_name'],
        'quantity': item['quantity'],
        'net_amount': item['net_amount'],
      };
    }).toList();

    final payload = {
      'title': 'Sales Invoice',
      'companyName': 'Le Laundrette',
      'logourl':
          "${APIService.baseurl}uploads/static/${companyresponse["data"]["logo"]}",
      'address': companyresponse['data']['address'].toString(),
      'mobile': companyresponse['data']['mobile'].toString(),
      'file_id': data['file_id'].toString(),
      'customer_name': res['voucher_head']['subledger_name'].toString(),
      'customer_phone': data['phonenumber'].toString(),
      'voucher_date': data['voucher_date'].toString(),
      'branch': data['branch_name'].toString(),
      'created_by': data['created_by_name'].toString(),
      'items': items,
      'total_amount': res['voucher_head']['net'],
    };
    print("=========================================");
    print(payload);
    print("=========================================");

    final response = await APIService.salesInvoicePDFAPI(payload: payload);

    return response;
  }

  Future<Map<String, dynamic>> addReceiptVoucherByAllocation(
      List<dynamic> allocation, dynamic data, String amount) async {
    final dynamic vouchertyperesponse =
        await APIService.getVoucherTypeDetailsByAttributeIDAPI(
      "12",
      "33",
    );
    print("This is voucher type response");
    print(vouchertyperesponse);
    print(LocalStorage.getLoggedUserdata()['default_exchange_rate'].toString());
    if (vouchertyperesponse["status"] == "success") {
      if (vouchertyperesponse["data"].length == 0) {
        return {"status": "failed", "message": "Ledger is not available"};
      } else {
        final Map<String, dynamic> vouchertypedetailsdata =
            vouchertyperesponse["data"].length == 0
                ? {}
                : vouchertyperesponse["data"][0];
        final List<dynamic> voucherheadresult = [
          {
            "ledger_id": "136",
            "attribute_id": "1",
            "subledger_id": data['subledger_id'].toString(),
            "voucher_type": 33,
            "subledger_name": data['subledger_name'].toString(),
            "ref_number": data['file_id'],
            "voucher_value": -double.parse(amount),
            "amount": -double.parse(amount),
            "vat": 0,
            "net": -double.parse(amount),
            "discount_percent": 0,
            "discount_amount": 0,
            "rounding": 0,
            "invoice_type": 0,
            "tax_type": 0,
            "payment_terms": 0,
            "narration": "",
            "bank_name": "",
            "card_no": "",
            "cheque_no": "",
            "cheque_date": "",
            "cheque_cleared": "N",
            "is_allocated": "N",
            "currency_id":
                LocalStorage.getLoggedUserdata()['default_currency_id']
                    .toString(),
            "currency":
                LocalStorage.getLoggedUserdata()['default_currency'].toString(),
            "ex_rate": LocalStorage.getLoggedUserdata()['default_exchange_rate']
                .toString(),
            "value_type": "Cr"
          },
          {
            "ledger_id": vouchertypedetailsdata["ledger_id"],
            "attribute_id": vouchertypedetailsdata["attribute_id"],
            "subledger_id": 0,
            "voucher_type": 33,
            "subledger_name": "",
            "ref_number": data['file_id'],
            "voucher_value":
                vouchertypedetailsdata["value_type"].toString() == "Dr"
                    ? double.parse(amount)
                    : -double.parse(amount),
            "amount": vouchertypedetailsdata["value_type"].toString() == "Dr"
                ? double.parse(amount)
                : -double.parse(amount),
            "vat": 0,
            "net": vouchertypedetailsdata["value_type"].toString() == "Dr"
                ? double.parse(amount)
                : -double.parse(amount),
            "discount_percent": 0,
            "discount_amount": 0,
            "rounding": 0,
            "invoice_type": 0,
            "tax_type": 0,
            "payment_terms": 0,
            "narration": "",
            "bank_name": "",
            "card_no": "",
            "cheque_no": "",
            "cheque_date": "",
            "cheque_cleared": "N",
            "is_allocated": "N",
            "currency_id":
                LocalStorage.getLoggedUserdata()['default_currency_id']
                    .toString(),
            "currency":
                LocalStorage.getLoggedUserdata()['default_currency'].toString(),
            "ex_rate": LocalStorage.getLoggedUserdata()['default_exchagne_rate']
                .toString(),
            "value_type": vouchertypedetailsdata["value_type"].toString()
          }
        ];
        print("=========================");
        print("=========================");
        print(voucherheadresult);
        print("=========================");
        print("=========================");

        final dynamic response = await APIService.addReceiptAPI(
          "RV",
          amount,
          "",
          allocation.length == 1 ? "S" : "M",
          LocalStorage.getLoggedUserdata()['branch_id'].toString(),
          "0",
          LocalStorage.getLoggedUserdata()['userid'].toString(),
          "1",
          voucherheadresult,
          allocation,
          "W",
          LocalStorage.getLoggedUserdata()['userid'].toString(),
        );
        return response;
      }
    } else {
      return vouchertyperesponse;
    }
  }

  void setAllData(String type, List<dynamic> data) {
    for (int i = 0; i < data.length; i++) {
      if (type == "S") {
        data[i]["is_selected"] = "Y";
      } else {
        data[i]["is_selected"] = "N";
      }
    }
  }

  setSelectIndexByAllocation(bool? value, int index) {
    allocationsdata[index]["is_selected"] = value == true ? "Y" : "N";
    update();
  }

  setSelectAll(bool? value) {
    selectedall = value ?? false;
    setAllData(selectedall ? "S" : "N", allocationsdata);
    update();
  }

  Future<List<dynamic>> selectedRecords(List<dynamic> items) async {
    List<dynamic> result = [];
    for (int i = 0; i < items.length; i++) {
      if (items[i]["is_selected"].toString() == "Y") {
        result.add(items[i]["allocation_id"].toString());
      }
    }
    return result;
  }
}
