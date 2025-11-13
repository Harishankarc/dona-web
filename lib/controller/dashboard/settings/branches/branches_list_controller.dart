import 'dart:async';

import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:LeLaundrette/backend/apiservice.dart';

class BranchesListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();

  bool isdefault = false;

  List<dynamic> data = [];

  dynamic selecteddata;

  bool loading = false;

  int page = 1;
  int limit = 20;

  int totalPages = 0;

  DateTime? startDate;
  DateTime? endDate;

  TextEditingController namecontroller = TextEditingController();

  Future<void> loadData([bool load = true]) async {
    setLoading(load);
    final response =
        await APIService.getMasterDetails(searchcontroller.text, 'branch');
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

  setData(dynamic value) {
    selecteddata = value;

    namecontroller.text = value?['name'] ?? '';

    update();
  }
}
