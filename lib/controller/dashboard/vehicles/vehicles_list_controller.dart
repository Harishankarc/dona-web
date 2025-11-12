import 'dart:async';

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/branch_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class VehiclesListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController brandcontroller = TextEditingController();
  TextEditingController registrationcontroller = TextEditingController();
  TextEditingController enginenocontroller = TextEditingController();
  TextEditingController chassiscontroller = TextEditingController();
  TextEditingController gpsimeicontroller = TextEditingController();
  TextEditingController gpssimnumbercontroller = TextEditingController();
  TextEditingController gpsimsinumbercontroller = TextEditingController();

  DateTime? dateofreg;
  DateTime? insurancevalidupto;
  DateTime? fitnessvalidupto;
  DateTime? taxvalidupto;
  DateTime? permitvalidupto;
  DateTime? metervalidupto;
  DateTime? puccvalidupto;
  DateTime? gas1validupto;
  DateTime? gas2validupto;
  DateTime? dateOfValidity;
  DateTime? reminderDate;

  dynamic selectedvehiclemodel;
  dynamic selectedvehicleBrands;
  dynamic selectedvehiclecategory;
  dynamic selectedvehicleDriver;
  dynamic selecteddocumenttype;
  PlatformFile? attachment;

  List<dynamic> data = [];

  Map<String, String> statusMap = {
    'A': 'Active',
    'D': 'Decommissioned',
    'R': 'Repairs',
  };

  Map<String, Color> statusColorMap = {
    'A': Colors.green,
    'D': Colors.amber,
    'R': Colors.red,
  };

  List<Map<String, dynamic>> vehiclestatus = [
    {'id': 'A', 'name': 'Active'},
    {'id': 'D', 'name': 'Decommissioned '},
    {'id': 'R', 'name': 'Repairs '},
  ];

  dynamic selectedvehiclestatus = {'id': 'A', 'name': 'Active'};

  bool loading = false;

  BranchModel? selectedbranch = BranchModel.fromJson({
    'id': LocalStorage.getLoggedUserdata()['branchid'].toString(),
    'name': LocalStorage.getLoggedUserdata()['branchname'].toString()
  });

  void setVehicleStatus(dynamic value) {
    selectedvehiclestatus = value;
    update();
  }

  setAttachment(PlatformFile? value) {
    attachment = value;
    update();
  }

  void setSelectedModel(dynamic val) {
    selectedvehiclemodel = val;
    update();
  }

  void setSelectedBrands(dynamic val) {
    selectedvehicleBrands = val;
    update();
  }

  void setSelectedVehicleCategory(dynamic val) {
    selectedvehiclecategory = val;
    update();
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

  void setSelecteddocumenttype(dynamic val) {
    selecteddocumenttype = val;
    update();
  }

  setValidity(DateTime? value) {
    dateOfValidity = value;
    reminderDate = dateOfValidity?.subtract(Duration(
        days: int.parse(selecteddocumenttype["reminder_days"].toString())));
    update();
  }

  setReminder(DateTime? value) {
    reminderDate = value;
    update();
  }

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
      selectedvehiclemodel = data['model_id'].toString() == "0"
          ? null
          : {'id': data['model_id'], 'name': data['model_name']};
      selectedvehicleBrands = data['brand_id'].toString() == "0"
          ? null
          : {'id': data['brand_id'], 'name': data['brand_name']};
      selectedvehiclecategory = data['category_id'].toString() == "0"
          ? null
          : {'id': data['category_id'], 'name': data['category_name']};
      registrationcontroller.text = data['registration'].toString();
      chassiscontroller.text = data['chasis_number'].toString();
      enginenocontroller.text = data['engine_number'].toString();
      dateofreg = data['date_of_reg'].toString() == '0000-00-00'
          ? null
          : DateTime.parse(data['date_of_reg'].toString());
      selectedvehicleDriver = data['assigned_to'].toString() == "0"
          ? null
          : {
              'id': data['assigned_to'].toString(),
              'name': data['assigned_to_name'].toString()
            };
      insurancevalidupto =
          data['insurance_valid_upto'].toString() == '0000-00-00'
              ? null
              : DateTime.parse(data['insurance_valid_upto'].toString());
      fitnessvalidupto = data['fitness_valid_upto'].toString() == '0000-00-00'
          ? null
          : DateTime.parse(data['fitness_valid_upto'].toString());
      taxvalidupto = data['tax_valid_upto'].toString() == '0000-00-00'
          ? null
          : DateTime.parse(data['tax_valid_upto'].toString());
      permitvalidupto = data['permit_valid_upto'].toString() == '0000-00-00'
          ? null
          : DateTime.parse(data['permit_valid_upto'].toString());
      metervalidupto = data['meter_valid_upto'].toString() == '0000-00-00'
          ? null
          : DateTime.parse(data['meter_valid_upto'].toString());
      puccvalidupto = data['pucc_valid_upto'].toString() == '0000-00-00'
          ? null
          : DateTime.parse(data['pucc_valid_upto'].toString());
      gas1validupto = data['gas1_valid_upto'].toString() == '0000-00-00'
          ? null
          : DateTime.parse(data['gas1_valid_upto'].toString());
      gas2validupto = data['gas2_valid_upto'].toString() == '0000-00-00'
          ? null
          : DateTime.parse(data['gas2_valid_upto'].toString());
      gpsimeicontroller.text = data['gps_imei'].toString();
      gpssimnumbercontroller.text = data['gps_sim_number'].toString();
      gpsimsinumbercontroller.text = data['gps_imsi_number'].toString();
      attachment = data == null
          ? null
          : data['photo_of_vehicle'].toString().isEmpty
              ? null
              : PlatformFile(name: data['photo_of_vehicle'], size: 0);
      selectedvehiclestatus = data == null
          ? null
          : (data["vehicle_status"].toString() == "A"
              ? vehiclestatus[0]
              : data["vehicle_status"].toString() == "D"
                  ? vehiclestatus[1]
                  : vehiclestatus[2]);
    }
  }

  void setDocumentData(dynamic data) {
    if (data != null) {
      selecteddocumenttype = data['document_type_id'].toString() == "0"
          ? null
          : {
              'id': data['document_type_id'].toString(),
              'name': data['document_type_name'].toString(),
              "reminder_days": data["reminder_days"].toString(),
              "is_mandatory": data["is_mandatory"].toString()
            };
      dateOfValidity = data['validity_date'].toString() == '0000-00-00'
          ? null
          : DateTime.parse(data['validity_date'].toString());
      reminderDate = data['reminder_date'].toString() == '0000-00-00'
          ? null
          : DateTime.parse(data['reminder_date'].toString());
      attachment = data == null
          ? null
          : data['attachment'].toString().isEmpty
              ? null
              : PlatformFile(name: data['attachment'], size: 0);
    }
  }

  void setSelectedVehicleDriver(dynamic val) {
    selectedvehicleDriver = val;
    update();
  }

  void setLoading(bool value) {
    loading = value;
    update();
  }

  @override
  void onInit() {
    super.onInit();
  }

  void clearDocumentForm() {
    selecteddocumenttype = null;
    dateOfValidity = null;
    reminderDate = null;
    attachment = null;
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
}
