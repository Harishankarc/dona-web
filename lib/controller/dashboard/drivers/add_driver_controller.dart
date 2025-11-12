import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/branch_model.dart';
import 'package:flutter/material.dart';

class AddDriverController extends MyController {
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController aadharController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  TextEditingController adharController = TextEditingController();
  TextEditingController emergencyNameController = TextEditingController();
  TextEditingController emergencyNumberController = TextEditingController();
  TextEditingController emergencyRelationController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController referralController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController remainingAmountController = TextEditingController();
  TextEditingController advanceAmountController = TextEditingController();

  String subledgertype = "1";
  String branchid = "1";

  dynamic selecteddriverrelationship;

  DateTime? dateOfBirth;
  DateTime? licenseExpiry;
  DateTime? startDate = DateTime.now();
  DateTime? endDate;

  void setDateOfBirth(DateTime? value) {
    dateOfBirth = value;
    update();
  }

  void setLicenseExpiry(DateTime? value) {
    licenseExpiry = value;
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

  void setSelectedDriverRelationship(dynamic val) {
    selecteddriverrelationship = val;
    update();
  }

  void setStartDate(DateTime? value) {
    startDate = value;
    update();
  }

  void setEndDate(DateTime? value) {
    endDate = value;
    update();
  }

  List<dynamic> data = [];

  bool loading = false;

  BranchModel? selectedbranch = BranchModel.fromJson({
    'id': LocalStorage.getLoggedUserdata()['branchid'].toString(),
    'name': LocalStorage.getLoggedUserdata()['branchname'].toString()
  });

  void setLoading(bool value) {
    loading = value;
    update();
  }

  @override
  void onInit() {
    super.onInit();
  }
}
