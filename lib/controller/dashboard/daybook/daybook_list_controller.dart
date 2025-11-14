import 'dart:async';

import 'package:flutter/material.dart';
import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';

class DaybookListController extends MyController {
  TextEditingController searchcontroller = TextEditingController();

  List<dynamic> data = [];

  bool loading = false;

  int page = 1;
  int limit = 20;

  

  int totalPages = 0;

  DateTime? startDate;
  DateTime? endDate;

  Future<void> loadData() async {
    loading = true;
    final response = await APIService.getVouchersListAPI(
      '1',
      APIService.formatDate(startDate, true),
      APIService.formatDate(endDate, true),
      searchcontroller.text,  LocalStorage.getLoggedUserdata()['branchid'].toString()
   ,
    );
    data = response['data'];
    loading = false;
    update();
  }

  void setLoading(bool value) {
    loading = value;
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

 
  @override
  void onInit() {
    // loadData();
    super.onInit();
  }

 
}
