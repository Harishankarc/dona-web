import 'dart:async';

import 'package:flutter/material.dart';
import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/branch_model.dart';
import 'package:LeLaundrette/model/subledger_model.dart';
import 'package:LeLaundrette/model/usergroupmodel.dart';

class UsersListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();

  bool isdefault = false;

  Map<String, String> statusMap = {
    'O': 'Ordered',
    'D': 'Delivered',
    'R': 'Returned',
  };

  Map<String, Color> statusColorMap = {
    'O': Colors.blue,
    'D': Colors.green,
    'R': Colors.red,
  };

  List<SubledgerModel> data = [];

  dynamic selecteddata;

  bool loading = false;

  int page = 1;
  int limit = 20;

  int totalPages = 0;

  DateTime? startDate;
  DateTime? endDate;

  TextEditingController namecontroller = TextEditingController();

  TextEditingController phonecontroller = TextEditingController();

  UserGroupModel? selectedusergroup;

  TextEditingController usernamecontroller = TextEditingController();

  TextEditingController passwordcontroller = TextEditingController();

  BranchModel? selectedbranch;

  Future<void> loadData([bool load = true]) async {
    setLoading(load);
    final response =
        await APIService.subledgersListByBranchIdsBySubledgerTypeByModelAPI(
            searchcontroller.text,
            '2',
            LocalStorage.getLoggedUserdata()['branchid'].toString());
    data = response;
    setLoading(false);
  }

  void setLoading(bool value) {
    loading = value;
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

  setUserGroup(UserGroupModel? value) {
    selectedusergroup = value;
    update();
  }

  setData(SubledgerModel? value) {
    selecteddata = value;
    selectedusergroup = value == null
        ? null
        : UserGroupModel(
            id: int.parse(value.userGroupId!), groupname: value.userGroupName);
    selectedbranch = value == null
        ? BranchModel(
            id: LocalStorage.getLoggedUserdata()['branchid'],
            name: LocalStorage.getLoggedUserdata()['branchname'])
        : BranchModel.fromJson(
            {'id': value.branchId, 'name': value.branchName});
    namecontroller.text = value?.name ?? '';
    phonecontroller.text = value?.phone ?? '';
    usernamecontroller.text = value?.username ?? '';
    passwordcontroller.text = value?.password ?? '';
    update();
  }

  setBranch(value) {
    selectedbranch = value;
    update();
  }
}
