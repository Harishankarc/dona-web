import 'dart:async';

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/branch_model.dart';
import 'package:LeLaundrette/model/usergroupmodel.dart';
import 'package:flutter/material.dart';

class UsersListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();

  List<dynamic> data = [];

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
    print(LocalStorage.getLoggedUserdata());
    final response = await APIService.getUsersListAPI('', searchcontroller.text,
        LocalStorage.getLoggedUserdata()['branchid'].toString());
    data = response['data'];
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

  setUserGroup(UserGroupModel? value) {
    selectedusergroup = value;
    update();
  }

  setData(dynamic value) {
    print("This is the user value");
    print(value);
    selecteddata = value;
    selectedusergroup = value == null
        ? null
        : UserGroupModel(
            id: value['user_group_id'], groupname: value['group_name']);
    selectedbranch = value == null
        ? null
        : BranchModel(
            id: value['branch_id'].toString(),
            name: value['branch_name'].toString());

    ;
    namecontroller.text = value?['name'] ?? '';
    phonecontroller.text = value?['phone'] ?? '';
    usernamecontroller.text = value?['username'] ?? '';
    passwordcontroller.text = value?['password'] ?? '';
    update();
  }

  setBranch(value) {
    selectedbranch = value;
    update();
  }
}
