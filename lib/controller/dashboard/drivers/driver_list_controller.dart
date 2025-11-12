import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/branch_model.dart';
import 'package:LeLaundrette/model/subledger_model.dart';

class CustomersListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();

  TextEditingController namecontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController secondaryphonecontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController latitudecontroller = TextEditingController();
  TextEditingController longitudecontroller = TextEditingController();
  LatLng customercurrentlocation = const LatLng(27.7172, 85.3240);

  SubledgerModel? selecteddata;

  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final mobileController = TextEditingController();
  final aadharController = TextEditingController();
  final licenseController = TextEditingController();
  final adharController = TextEditingController();
  final emergencyNameController = TextEditingController();
  final emergencyNumberController = TextEditingController();
  final emergencyRelationController = TextEditingController();
  final addressController = TextEditingController();
  final referralController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final remainingAmountController = TextEditingController();
  final advanceAmountController = TextEditingController();

  PlatformFile? attachment;
  dynamic selecteddriverrelationship;
  dynamic selecteddocumenttype;

  DateTime? dateOfBirth;
  DateTime? licenseExpiry;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? dateOfValidity;
  DateTime? reminderDate;

  String subledgertype = "1";
  String branchid = "1";

  void setDateOfBirth(DateTime? value) {
    dateOfBirth = value;
    update();
  }

  void setLicenseExpiry(DateTime? value) {
    licenseExpiry = value;
    update();
  }

  void setSelectedDriverRelationship(dynamic val) {
    selecteddriverrelationship = val;
    update();
  }

  @override
  void onInit() {
    loadData();
    super.onInit();
  }

  List<dynamic> data = [];

  bool loading = false;

  BranchModel? selectedbranch = BranchModel.fromJson({
    'id': LocalStorage.getLoggedUserdata()['branchid'].toString(),
    'name': LocalStorage.getLoggedUserdata()['branchname'].toString()
  });

  Future<void> loadData([bool load = true]) async {
    setLoading(load);
    final response =
        await APIService.getDriverListAPI(searchcontroller.text, subledgertype);
    data = response['data'];

    setLoading(false);
  }

  void setLoading(bool value) {
    loading = value;
    update();
  }

  void clearForm() {
    nameController.clear();
    dobController.clear();
    mobileController.clear();
    aadharController.clear();
    licenseController.clear();
    adharController.clear();
    emergencyNameController.clear();
    emergencyNumberController.clear();
    emergencyRelationController.clear();
    addressController.clear();
    referralController.clear();
    startDateController.clear();
    endDateController.clear();
    remainingAmountController.clear();
    advanceAmountController.clear();
    selecteddriverrelationship = null;
    dateOfBirth = null;
    licenseExpiry = null;
    startDate = null;
    endDate = null;
    update();
  }

  setStartDate(DateTime? value) {
    startDate = value;

    update();
  }

  setEndDate(DateTime? value) {
    endDate = value;

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

  setAttachment(PlatformFile? value) {
    attachment = value;
    update();
  }

  void setData(dynamic value) {
    nameController.text = value['name'];
    dateOfBirth = value['date_of_birth'] == '0000-00-00'
        ? null
        : DateTime.parse(value['date_of_birth'].toString());
    mobileController.text = value['phone'];
    aadharController.text = value['adhar_card_number'];
    licenseController.text = value['license_number'];
    licenseExpiry = value['license_expiry'] == '0000-00-00'
        ? null
        : DateTime.parse(value['license_expiry']);
    emergencyNameController.text = value['emergency_contact_name'];
    emergencyNumberController.text = value['emergency_contact_number'];
    selecteddriverrelationship =
        value['emergency_contact_relationship_id'].toString() == "0"
            ? null
            : {
                'id': value['emergency_contact_relationship_id'],
                'name': value['emergency_contact_relationship_name'] ?? ''
              };
    addressController.text = value['address'];

    referralController.text = value['referral_name'];
    startDate = value['start_date_of_business'] == '0000-00-00'
        ? null
        : DateTime.parse(value['start_date_of_business']);
    endDate = value['end_date_of_business'] == '0000-00-00'
        ? null
        : DateTime.parse(value['end_date_of_business']);
    remainingAmountController.text =
        value['remaining_balance_amount'].toString();
    advanceAmountController.text = value['advance_amount'].toString();
    update();
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
    print("This is the selected document");
    print(selecteddocumenttype);
  }

  void clearDocumentForm() {
    selecteddocumenttype = null;
    dateOfValidity = null;
    reminderDate = null;
    attachment = null;
    update();
  }
}
