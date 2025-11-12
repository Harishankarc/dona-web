import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/usergroupmodel.dart';

class UserGroupController extends MyController {
  TextEditingController searchcontroller = TextEditingController();
  UserGroupModel? selectedgroup;
  int page = 1;
  int limit = 20;

  int totalPages = 0;

  List<UserGroupModel> usersgroup = [];

  bool loading = false;

  Future<Map<String, dynamic>> updatePermission() async {
    final response = await APIService.editUserGroup(
      selectedgroup!.id.toString(),
      json.encode(selectedgroup!.permissions),
      LocalStorage.getLoggedUserdata()['userid'].toString(),
    );
    return response;
  }

  Future<void> usersList() async {
    loading = true;
    update();
    final response = await APIService.getUserGroupsList();

    usersgroup = response.where((e) => e.id.toString() != '1').toList();

    loading = false;
    update();
  }

  void setUserGroupValue(UserGroupModel? value) {
    selectedgroup = value;
    update();
  }

  void setValue(String key, bool value) {
    selectedgroup!.permissions![key] = value;
    update();
  }

  void setForAllValue(String key, bool value) {
    selectedgroup!.permissions!.forEach(
      (k, v) {
        if (k.contains('${key}_')) {
          selectedgroup!.permissions![k] = value;
        }
      },
    );
    update();
  }

  void onPreviousPage(int cpage) {
    page = cpage;
    usersList();
  }

  void onNextPage(int cpage) {
    page = cpage;
    usersList();
  }

  void gotoLastPage(int? p) {
    page = p ?? 1;
    usersList();
  }

  void gotoFirstPage(int? p) {
    page = p ?? 1;
    usersList();
  }

  void setLoading(bool value) {
    loading = value;
    update();
  }
}
