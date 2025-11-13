// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
// import 'dart:html' as html;
import 'dart:io';

import 'package:LeLaundrette/helpers/services/auth_service.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/model/attribute_model.dart';
import 'package:LeLaundrette/model/branch_by_user_model.dart';
import 'package:LeLaundrette/model/branch_model.dart';
import 'package:LeLaundrette/model/inventory_model.dart';
import 'package:LeLaundrette/model/invoice_type_model.dart';
import 'package:LeLaundrette/model/ledger_model.dart';
import 'package:LeLaundrette/model/main_ledger_model.dart';
import 'package:LeLaundrette/model/main_subledger_model.dart';
import 'package:LeLaundrette/model/pagination_model.dart';
import 'package:LeLaundrette/model/parent_ledger_model.dart';
import 'package:LeLaundrette/model/paymenttype_model.dart';
import 'package:LeLaundrette/model/salesman_by_branch_model.dart';
import 'package:LeLaundrette/model/subledger_model.dart';
import 'package:LeLaundrette/model/subledgertype_model.dart';
import 'package:LeLaundrette/model/unitmodel.dart';
import 'package:LeLaundrette/model/usergroupmodel.dart';
import 'package:LeLaundrette/model/usermodel.dart';
import 'package:LeLaundrette/model/voucher_subledger_model.dart';
import 'package:LeLaundrette/model/voucher_type_model.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getmod;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class APIService {
  static Color mainappcolor = const Color(0xFF008f9d);
  static Color subappcolor = const Color(0xFF05324f);
  static Color backcolor = const Color(0xfff6f7fe);
  static Color textcolor = Colors.black;
  static Color whitetextcolor = Colors.white;
  static Color bordercolor = Colors.black;
  static Color buttoncolor = Colors.black;
  static Color cardbg = const Color.fromARGB(255, 230, 230, 230);
  static Color cardcolor = Colors.white;
  static String appfont = 'Poppins';

  static String drivecode = "NARAYANATRAVELS";
  static String baseurl = 'https://donaapi.kernalscapeserver.in/dona/';
  static Dio dio = initializeDio();

  static Dio initializeDio() {
    Dio dio = Dio(BaseOptions(
      baseUrl: baseurl,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },
      validateStatus: (status) => true,
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        print(response.realUri.toString());
        print(response.data);

        if (response.statusCode == 401) {
          await AuthService.logout();
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        print(error.message);
        if (error.response?.statusCode == 401) {
          await AuthService.logout();
        }
        return handler.next(error);
      },
    ));
    return dio;
  }

  static Future<Map<String, dynamic>> loginAPI(
      String username, String password) async {
    try {
      final response = await dio.post('subledger/userlogin', data: {
        'username': username,
        'password': password,
      });

      return response.data;
    } catch (e) {
      return {
        'status': 'error',
        'message': "Please check your internet connection and try again"
      };
    }
  }

  static Future<List<SubledgerModel>>
      subledgersListByBranchIdsBySubledgerTypeByModelAPI(
          String term, String subledgertype, String branchid) async {
    try {
      print("This is the customer list");
      print({
        "searchTerm": term,
        "subledger_type": subledgertype,
        "branch_id": branchid
      });
      final data = {
        "searchTerm": term,
        "subledger_type": subledgertype,
        "branch_id": branchid
      };
      final response = await dio.get(
        'subledger/listsubledgersbybranchidsbysubledgertype',
        queryParameters: data,
      );
      print(response.data);
      if (response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];
        return data.map((e) => SubledgerModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      print(e);
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<BranchModel>> getBranchesBytermByUserid(
      String term, String userid) async {
    try {
      final data = {"term": term, "user_id": userid};
      final response = await dio.get(
        'masters/listbranchesbyuserid',
        queryParameters: data,
      );
      print(response.data);
      if (response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];
        return data.map((e) => BranchModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getBranchesBytermByUseridByList(
      String term, String userid) async {
    try {
      final data = {"term": term, "user_id": userid};
      final response = await dio.get(
        'masters/listbranchesbyuserid',
        queryParameters: data,
      );
      print(response.data);
      if (response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];
        return data;
      } else {
        return [];
      }
    } on DioException catch (e) {
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> subledgersListByBranchIdsAPI(
      String term, String subledgertype, String branchid) async {
    try {
      final data = {
        "searchTerm": term,
        "subledger_type": subledgertype,
        "branch_id": branchid
      };
      final response = await dio.get(
        'subledger/listsubledgersbybranchids',
        queryParameters: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<List<dynamic>> getUnitListByTerm(String term) async {
    try {
      final data = {
        "term": term,
      };
      final response = await dio.get(
        'masters/unitlist',
        queryParameters: data,
      );
      print(response.data);
      return response.data["status"] == "success" ? response.data["data"] : [];
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<List<InventoryModel>> getInventoryListByBranchByterm(
      String term, String branchid, String itemtype) async {
    try {
      final data = {
        "searchTerm": term,
        "branch_id": branchid,
        "item_type": itemtype
      };
      final response = await dio.get(
        'inventory/listinventorybybranches',
        queryParameters: data,
      );
      print(response.data);
      if (response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];
        return data.map((e) => InventoryModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<List<dynamic>> getCurrencyListAPI() async {
    try {
      final response = await dio.get(
        'masters/currencylist',
      );
      print(response.data);
      return response.data["status"] == "success" ? response.data["data"] : [];
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<List<dynamic>> getTaxMasterByTerm(
      String isdefault, String term) async {
    try {
      final response = await dio.post('masters/taxlist',
          data: {"is_default": isdefault, "term": term});
      print(response.data);
      return response.data["status"] == "success" ? response.data["data"] : [];
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> addLeaveVoucherAPI(
      String serialcode,
      String vehicleid,
      String vehiclename,
      String subledgerid,
      String subledgername,
      String voucherdate,
      String currencyid,
      String currency,
      String exchangerate,
      String vouchervalue,
      String amount,
      String leavedays,
      String remarks,
      String branchid,
      String userid,
      String referrenceid) async {
    try {
      print({
        "serial_code": serialcode,
        "vehicle_id": vehicleid,
        "vehicle_name": vehiclename,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "voucher_value": vouchervalue,
        "amount": amount,
        "leave_days": leavedays,
        "remarks": remarks,
        "created_by": userid,
        "branch_id": branchid,
        "referrence_id": referrenceid
      });
      final data = {
        "serial_code": serialcode,
        "vehicle_id": vehicleid,
        "vehicle_name": vehiclename,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "voucher_value": vouchervalue,
        "amount": amount,
        "leave_days": leavedays,
        "remarks": remarks,
        "created_by": userid,
        "branch_id": branchid,
        "referrence_id": referrenceid
      };
      final response = await dio.post(
        'voucher/createleavevoucher',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> getLeaveVoucherByReferrenceIDAPI(
    String referrenceid,
  ) async {
    try {
      final data = {
        "referrence_id": referrenceid,
      };
      final response = await dio.post(
        'voucher/getleavevoucherbyreferenceid',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> editLeaveVoucherByReferrenceIDAPI(
      String referrenceid,
      String vehicleid,
      String vehiclename,
      String subledgerid,
      String subledgername,
      String voucherdate,
      String currencyid,
      String currency,
      String exchangerate,
      String vouchervalue,
      String amount,
      String leavedays,
      String remarks,
      String branchid,
      String userid) async {
    try {
      print({
        "referrence_id": referrenceid,
        "vehicle_id": vehicleid,
        "vehicle_name": vehiclename,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "voucher_value": vouchervalue,
        "amount": amount,
        "leave_days": leavedays,
        "remarks": remarks,
        "updated_by": userid,
        "branch_id": branchid,
      });
      final data = {
        "referrence_id": referrenceid,
        "vehicle_id": vehicleid,
        "vehicle_name": vehiclename,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "voucher_value": vouchervalue,
        "amount": amount,
        "leave_days": leavedays,
        "remarks": remarks,
        "updated_by": userid,
        "branch_id": branchid,
      };
      final response = await dio.post(
        'voucher/editleavevoucherbyreferenceid',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> editLeaveVoucherAPI(
      String id,
      String vehicleid,
      String vehiclename,
      String subledgerid,
      String subledgername,
      String voucherdate,
      String currencyid,
      String currency,
      String exchangerate,
      String vouchervalue,
      String amount,
      String leavedays,
      String remarks,
      String branchid,
      String userid) async {
    try {
      print({
        "id": id,
        "vehicle_id": vehicleid,
        "vehicle_name": vehiclename,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "voucher_value": vouchervalue,
        "amount": amount,
        "leave_days": leavedays,
        "remarks": remarks,
        "updated_by": userid,
        "branch_id": branchid,
      });
      final data = {
        "id": id,
        "vehicle_id": vehicleid,
        "vehicle_name": vehiclename,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "voucher_value": vouchervalue,
        "amount": amount,
        "leave_days": leavedays,
        "remarks": remarks,
        "updated_by": userid,
        "branch_id": branchid,
      };
      final response = await dio.post(
        'voucher/editleavevoucher',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> editPaymentCollectionVoucherAPI(
      String id,
      String vehicleid,
      String vehiclename,
      String subledgerid,
      String subledgername,
      String voucherdate,
      String currencyid,
      String currency,
      String exchangerate,
      String vouchervalue,
      String paymenttypeid,
      String remarks,
      String branchid,
      String userid) async {
    try {
      print({
        "id": id,
        "vehicle_id": vehicleid,
        "vehicle_name": vehiclename,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "voucher_value": vouchervalue,
        "payment_type_id": paymenttypeid,
        "remarks": remarks,
        "created_by": userid,
        "branch_id": branchid,
      });
      final data = {
        "id": id,
        "vehicle_id": vehicleid,
        "vehicle_name": vehiclename,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "voucher_value": vouchervalue,
        "payment_type_id": paymenttypeid,
        "remarks": remarks,
        "created_by": userid,
        "branch_id": branchid,
      };
      final response = await dio.post(
        'voucher/editpaymentcollectionvoucher',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> addPaymentCollectionVoucherAPI(
      String serialcode,
      String vehicleid,
      String vehiclename,
      String subledgerid,
      String subledgername,
      String voucherdate,
      String currencyid,
      String currency,
      String exchangerate,
      String vouchervalue,
      String paymenttypeid,
      String remarks,
      String branchid,
      String userid) async {
    try {
      print({
        "serial_code": serialcode,
        "vehicle_id": vehicleid,
        "vehicle_name": vehiclename,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "voucher_value": vouchervalue,
        "payment_type_id": paymenttypeid,
        "remarks": remarks,
        "created_by": userid,
        "branch_id": branchid,
      });
      final data = {
        "serial_code": serialcode,
        "vehicle_id": vehicleid,
        "vehicle_name": vehiclename,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "voucher_value": vouchervalue,
        "payment_type_id": paymenttypeid,
        "remarks": remarks,
        "created_by": userid,
        "branch_id": branchid,
      };
      final response = await dio.post(
        'voucher/createpaymentcollectionvoucher',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> getVehicleAndDriverBalanceAPI(
    String subledgerid,
    String vehicleid,
  ) async {
    try {
      final data = {
        "subledger_id": subledgerid,
        "vehicle_id": vehicleid,
      };
      final response = await dio.post(
        'voucher/getvehicleanddriverbalance',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> editCollectionVoucherAPI(
      String fileId,
      String serialcode,
      String subledgerid,
      String subledgername,
      String voucherdate,
      String currencyid,
      String currency,
      String exchangerate,
      String remarks,
      String createdby,
      List<dynamic> items,
      String branchid,
      List<dynamic> unusedids) async {
    try {
      final data = {
        "file_id": fileId,
        "serial_code": serialcode,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "remarks": remarks,
        "created_by": createdby,
        "items": items,
        "branch_id": branchid,
        "unusedids": unusedids,
      };
      final response = await dio.put(
        'voucher/editcollectionvoucher',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> editSalesVoucherAPI(
      String fileId,
      String subledgerid,
      String subledgername,
      String voucherdate,
      String deliverydate,
      String currencyid,
      String currency,
      String exchangerate,
      String remarks,
      String updatedby,
      List<dynamic> items,
      String branchid,
      List<dynamic> unusedids) async {
    try {
      final data = {
        "file_id": fileId,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "delivery_date": deliverydate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "remarks": remarks,
        "updated_by": updatedby,
        "items": items,
        "branch_id": branchid,
        "unusedIds": unusedids,
      };
      final response = await dio.post(
        'voucher/editsalesvoucher',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> getSalesDetailsByFileIdAPI(
    String fileId,
    String branchId,
  ) async {
    try {
      final response = await dio.post('voucher/getsalesdetailsbyfileid', data: {
        "file_id": fileId,
        "branch_id": branchId,
      });
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> getSalesDetailsByFileIdAPINew(
    String fileId,
    String branchId,
  ) async {
    try {
      final response =
          await dio.post('voucher/getsalesdetailslistbyfileid', data: {
        "file_id": fileId,
        "branch_id": branchId,
      });
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> postVoucherListByPaginationByLimit(
    String term,
    String vouchertypeid,
    String branchids,
    String pagenumber,
    String pagelimit,
    String userid,
  ) async {
    try {
      final data = {
        "term": term,
        "voucher_type_id": vouchertypeid,
        "branch_id": branchids,
        "page": pagenumber,
        "limit": pagelimit
      };

      final response = await dio.post(
        'voucher/listvouchersbypagination',
        data: jsonEncode(data),
      );
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> createVehicleAPI(
    String name,
    String registration,
    String chargeperhour,
    String minimumcharge,
    String needshifting,
    String shiftingcharge,
    String assignedto,
    String createdby,
  ) async {
    try {
      final data = {
        "name": name,
        "registration": registration,
        "charge_per_hour": chargeperhour,
        "minimum_charge": minimumcharge,
        "need_shifting": needshifting,
        "shifting_charge": shiftingcharge,
        "assigned_to": assignedto,
        "created_by": createdby
      };

      print(data);

      final response = await dio.post(
        'vehicle/createvehicle',
        data: jsonEncode(data),
      );
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> editVehicleAPI(
    String id,
    String name,
    String registration,
    String chargeperhour,
    String minimumcharge,
    String needshifting,
    String shiftingcharge,
    String assignedto,
    String updatedby,
  ) async {
    try {
      final data = {
        "id": id,
        "name": name,
        "registration": registration,
        "charge_per_hour": chargeperhour,
        "minimum_charge": minimumcharge,
        "need_shifting": needshifting,
        "shifting_charge": shiftingcharge,
        "assigned_to": assignedto,
        "updated_by": updatedby
      };

      print(data);

      final response = await dio.post(
        'vehicle/editvehicle',
        data: jsonEncode(data),
      );
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> createDriverAPI(
      String name,
      String phone,
      String subledgerType,
      String dateOfBirth,
      String licenseNumber,
      String licenseExpiry,
      String adharCardNumber,
      String emergencyContactNumber,
      String emergencyContactName,
      String emergencyContactRelationshipId,
      String referralName,
      String address,
      String startDateOfBusiness,
      String endDateOfBusiness,
      String remainingBalanceAmount,
      String advanceAmount,
      String branchId,
      String createdBy) async {
    try {
      final data = {
        "name": name,
        "phone": phone,
        "subledger_type": subledgerType,
        "date_of_birth": dateOfBirth,
        "license_number": licenseNumber,
        "license_expiry": licenseExpiry,
        "adhar_card_number": adharCardNumber,
        "emergency_contact_number": emergencyContactNumber,
        "emergency_contact_name": emergencyContactName,
        "emergency_contact_relationship_id": emergencyContactRelationshipId,
        "referral_name": referralName,
        "address": address,
        "start_date_of_business": startDateOfBusiness,
        "end_date_of_business": endDateOfBusiness,
        "remaining_balance_amount": remainingBalanceAmount,
        "advance_amount": advanceAmount,
        "branch_id": branchId,
        "created_by": createdBy,
      };

      print(data);

      final response = await dio.post(
        'driver/createdriver',
        data: jsonEncode(data),
      );
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> editDriverListAPI(
      String id,
      String name,
      String phone,
      String subledgerType,
      String dateOfBirth,
      String licenseNumber,
      String licenseExpiry,
      String adharCardNumber,
      String emergencyContactNumber,
      String emergencyContactName,
      String emergencyContactRelationshipId,
      String referralName,
      String address,
      String startDateOfBusiness,
      String endDateOfBusiness,
      String remainingBalanceAmount,
      String advanceAmount,
      String branchId,
      String createdBy) async {
    try {
      final data = {
        "name": name,
        "phone": phone,
        "subledger_type": subledgerType,
        "date_of_birth": dateOfBirth,
        "license_number": licenseNumber,
        "license_expiry": licenseExpiry,
        "adhar_card_number": adharCardNumber,
        "emergency_contact_number": emergencyContactNumber,
        "emergency_contact_name": emergencyContactName,
        "emergency_contact_relationship_id": emergencyContactRelationshipId,
        "referral_name": referralName,
        "address": address,
        "start_date_of_business": startDateOfBusiness,
        "end_date_of_business": endDateOfBusiness,
        "remaining_balance_amount": remainingBalanceAmount,
        "advance_amount": advanceAmount,
        "branch_id": branchId,
        "created_by": createdBy,
      };

      print(data);

      final response = await dio.put(
        'driver/editdriver/$id',
        data: jsonEncode(data),
      );
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> addDocument(
      String vehicleId,
      String subledgerId,
      String documentId,
      String attachment,
      String validitydate,
      String reminderdate,
      String createdBy,
      String extension) async {
    try {
      final data = {
        "vehicle_id": vehicleId,
        "subledger_id": subledgerId,
        "document_type_id": documentId,
        "attachment": attachment,
        "validity_date": validitydate,
        "reminder_date": reminderdate,
        "created_by": createdBy,
        "document_format": extension
      };

      print(data);

      final response = await dio.post(
        'vehicle/createvehicledocument',
        data: jsonEncode(data),
      );
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> editDocument(
      String id,
      String vehicleId,
      String subledgerId,
      String documentId,
      String attachment,
      String validitydate,
      String reminderdate,
      String updatedBy,
      String extention) async {
    try {
      final data = {
        "id": id,
        "vehicle_id": vehicleId,
        "subledger_id": subledgerId,
        "document_type_id": documentId,
        "attachment": attachment,
        "validity_date": validitydate,
        "reminder_date": reminderdate,
        "updated_by": updatedBy,
        "document_format": extention
      };

      print(data);

      final response = await dio.post(
        'vehicle/editvehicledocument',
        data: jsonEncode(data),
      );
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> getVehicleListAPI(
    String term,
  ) async {
    try {
      final response = await dio
          .get('vehicle/listvehicles', queryParameters: {"search": term});
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<List<dynamic>> getVehicleListByModelAPI(
    String term,
  ) async {
    try {
      final response = await dio
          .get('vehicle/listvehicles', queryParameters: {"search": term});
      if (response.data['status'] == 'success') {
        return response.data['data'] as List;
      } else {
        return [];
      }
    } on DioException catch (e) {
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getVehicleTrackingListAPI(
      String term, String filterdate) async {
    try {
      final response = await dio.get('vehicle/listgpsdata',
          queryParameters: {"term": term, "filter_date": filterdate});
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> getSyncDataAPI() async {
    try {
      final response = await dio.get(
        'vehicle/fetchgpsdata',
      );
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> getVehicleListByAssignedToAPI(
      String term, String assignedto) async {
    try {
      final response = await dio.get('vehicle/listvehiclesbyassignedto',
          queryParameters: {"search": term, "assigned_to": assignedto});
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> getDocumentListAPI(
    String vehicleid,
    String subledgerid,
    String term,
  ) async {
    try {
      final response = await dio.get('vehicle/listvehicledocuments',
          queryParameters: {
            "vehicle_id": vehicleid,
            "subledger_id": subledgerid,
            "search": term
          });
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> getDocumentListByTypeAPI(
    String listtype,
    String term,
  ) async {
    try {
      final response = await dio.get('vehicle/listvehicledocumentsbytype',
          queryParameters: {"list_type": listtype, "search": term});
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> getDocumentListByReminderAPI(
    String listtype,
    String term,
  ) async {
    try {
      final response = await dio.get('vehicle/listvehicledocumentsbyreminder',
          queryParameters: {"list_type": listtype, "search": term});
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> getSubledgerListAPI(
    String term,
    String subledgertype,
  ) async {
    try {
      final response = await dio.get('driver/listdrivers',
          queryParameters: {"subledger_type": subledgertype, "search": term});
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<List<dynamic>> getSubledgerListByModelAPI(
    String term,
    String subledgertype,
  ) async {
    try {
      final response = await dio.get('driver/listdrivers',
          queryParameters: {"subledger_type": subledgertype, "search": term});
      if (response.data['status'] == 'success') {
        return response.data['data'] as List;
      } else {
        return [];
      }
    } on DioException catch (e) {
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<String> salesInvoicePDFAPI({required dynamic payload}) async {
    const String apiUrl = "reports/generatesalesvoucherinvoice";

    final response = await dio.post(
      apiUrl,
      data: jsonEncode(payload),
    );

    if (response.data is Map<String, dynamic>) {
      return response.data['filename'];
    } else {
      return '';
    }
  }

  static Future<String> collectionInvoicePDFAPI(
      {required dynamic payload}) async {
    const String apiUrl = "reports/generatecollectionvoucher";

    final response = await dio.post(
      apiUrl,
      data: jsonEncode(payload),
    );

    if (response.data is Map<String, dynamic>) {
      return response.data['filename'];
    } else {
      return '';
    }
  }

  static Future<Map<String, dynamic>> deleteVoucherByFileIDByRef(
    String fileid,
  ) async {
    try {
      final data = {
        "file_id": fileid,
      };
      final response = await dio.post(
        'voucher/deletevoucherbyfileidbyreferrenceid',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> deleteVoucher(
    String fileid,
  ) async {
    try {
      final data = {
        "file_id": fileid,
      };
      final response = await dio.post(
        'voucher/deletevoucherbyfileid',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> getvoucherDetailsByFileID(
    String fileid,
  ) async {
    try {
      final response = await dio.post('voucher/getvouchersbyfileid',
          data: jsonEncode({"file_id": fileid}));
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<List<dynamic>> getVehicleModelTypes(String? term) async {
    try {
      final response = await dio.get(
        'masters/listmodels',
        queryParameters: {'search': term},
      );

      // Ensure response.data is not null
      if (response.data == null) return [];

      // Ensure data exists
      if (response.data['status'] == 'success' &&
          response.data['data'] is List) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      print('Exception in getVehicleModelTypes: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getVehicleBrandsTypes(String term) async {
    try {
      final response = await dio.get(
        'masters/listbrands',
        queryParameters: {'search': term},
      );

      // Ensure response.data is not null
      if (response.data == null) return [];

      // Ensure data exists
      if (response.data['status'] == 'success' &&
          response.data['data'] is List) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      print('Exception in getVehicleModelTypes: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getVehicleCategoryTypes(String term) async {
    try {
      final response = await dio.get(
        'masters/listcategory',
        queryParameters: {'search': term},
      );

      // Ensure response.data is not null
      if (response.data == null) return [];

      // Ensure data exists
      if (response.data['status'] == 'success' &&
          response.data['data'] is List) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      print('Exception in getVehicleModelTypes: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getVehicleDriverTypes(
      String term, String subledgertype) async {
    try {
      final response = await dio.get(
        'driver/listdrivers',
        queryParameters: {'search': term, "subledger_type": subledgertype},
      );

      if (response.data == null) return [];

      if (response.data['status'] == 'success' &&
          response.data['data'] is List) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      print('Exception in getVehicleModelTypes: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getPaymentTypes() async {
    try {
      final response = await dio.get(
        'masters/listpaymenttypes',
      );
      if (response.data['status'] == 'success') {
        return response.data['data'] as List;
      } else {
        return [];
      }
    } on DioException catch (e) {
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<Map<String, dynamic>> getAvailableBalanceByDateAPI(
    String subledgerid,
  ) async {
    try {
      final response = await dio.post('voucher/listavailablebalancebydate',
          data: jsonEncode({"subledger_id": subledgerid}));
      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e};
    } catch (e) {
      return {"status": "failed", "message": e};
    }
  }

  static Future<Map<String, dynamic>> getCollectionReport(String startDate,
      String endDate, String branchId, String subledgerId) async {
    try {
      final response =
          await dio.post('reports/getcollectionreport', queryParameters: {
        'startdate': startDate,
        'enddate': endDate,
        'branch_id': branchId,
        'subledger_id': subledgerId,
      });

      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e.toString()};
    } catch (e) {
      return {"status": "failed", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createSalesVoucherAPI(
      String serialcode,
      String subledgerid,
      String subledgername,
      String voucherdate,
      String deliverydate,
      String currencyid,
      String currency,
      String exchangerate,
      String remarks,
      String createdby,
      List<dynamic> items,
      String branchid) async {
    try {
      final data = {
        "serial_code": serialcode,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "voucher_date": voucherdate,
        "delivery_date": deliverydate,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "remarks": remarks,
        "created_by": createdby,
        "items": items,
        "branch_id": branchid,
      };

      final response = await dio.post(
        'voucher/createsalesvoucher',
        data: data,
      );

      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e.toString()};
    } catch (e) {
      return {"status": "failed", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateSalesVoucherAPI(
      String fileId, String branchId, String status, String updatedBy) async {
    try {
      final data = {
        "file_id": fileId,
        "branch_id": branchId,
        "status": status,
        "updated_by": updatedBy,
      };

      final response = await dio.post(
        'voucher/updatesalesvoucher',
        data: data,
      );

      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e.toString()};
    } catch (e) {
      return {"status": "failed", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteSalesVoucherAPI(
      String fileId, String branchId, String updatedBy) async {
    try {
      final data = {
        "file_id": fileId,
        "branch_id": branchId,
        "updated_by": updatedBy,
      };

      final response = await dio.post(
        'voucher/deletesalesvoucher',
        data: data,
      );

      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e.toString()};
    } catch (e) {
      return {"status": "failed", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateLossAPI(
      String id,
      String balanceQuantity,
      String damageQuantity,
      String missingQuantity,
      String updatedBy) async {
    try {
      final data = {
        "id": id,
        "balance_quantity": balanceQuantity,
        "damage_quantity": damageQuantity,
        "missing_quantity": missingQuantity,
        "updated_by": updatedBy,
      };

      final response = await dio.post(
        'voucher/updateloss',
        data: data,
      );

      return response.data;
    } on DioException catch (e) {
      return {"status": "failed", "message": e.toString()};
    } catch (e) {
      return {"status": "failed", "message": e.toString()};
    }
  }

  //old apis

  static Future<Map<String, dynamic>> editUserGroup(
      String id, String permissions, String userid) async {
    final data = {"id": id, "permission": permissions, "modified_by": userid};
    try {
      final response = await dio.post(
        '/users/updatepermission',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to Update UserGroup');
      }
    } on DioException catch (e) {
      throw Exception('Failed to Update UserGroup $e');
    } catch (e) {
      throw Exception('Failed to Update UserGroup $e');
    }
  }

  static Future<Map<String, dynamic>> postGenerateFinanceVoucherPDF(
    String title,
    String companyname,
    String logourl,
    String address,
    String mobile,
    String trn,
    String voucherno,
    String voucherdate,
    String reference,
    String createdby,
    String currency,
    String branch,
    String paymenttype,
    List<dynamic> accounts,
    String grandtotal,
    String subledgertitle,
  ) async {
    try {
      final data = jsonEncode({
        "title": title,
        "companyname": companyname,
        "logourl": logourl,
        "address": address,
        "mobile": mobile,
        "trn": trn,
        "voucherno": voucherno,
        "voucherdate": voucherdate,
        "reference": reference,
        "createdby": createdby,
        "currency": currency,
        "branch": branch,
        "paymenttype": paymenttype,
        "accounts": accounts,
        "grandtotal": grandtotal,
        "subledgertitle": subledgertitle
      });

      final response = await dio.post(
        '/reports/generatefinancevoucher',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> uploadImageWeb(PlatformFile file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${baseurl}uploadfile/upload"),
      );
      Map<String, String> headers = {
        "Content-type": "multipart/form-data",
      };
      request.fields.addAll({'companyname': drivecode});
      request.files.add(http.MultipartFile.fromBytes('document', file.bytes!,
          filename: file.name));
      request.headers.addAll(headers);
      var res = await request.send();

      var responsed = await http.Response.fromStream(res);
      print(responsed.body);
      if (res.statusCode == 200) {
        return json.decode(responsed.body);
      } else {
        return {'success': 0, 'message': 'Not Uploaded'};
      }
    } catch (err) {
      return {'success': 0, 'message': err.toString()};
    }
  }

  static Future<bool> isLogged() async {
    SharedPreferences barakathcache = await SharedPreferences.getInstance();
    return (barakathcache.getBool("islogged")) ?? false;
  }

  static Future<Map<String, dynamic>> autoLogin() async {
    try {
      final userdata = LocalStorage.getLoggedUserdata();
      final response = await dio.post(
        'users/autologin',
        data: {
          "userid": userdata['userid'].toString(),
        },
      );
      print("This is the response");
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getVouchersListAPI(
      String vouchertypeid,
      String attributeid,
      String status,
      String createdby,
      String startdate,
      String enddate,
      String type,
      String term,
      String branchId,
      String isTransferedOnly) async {
    try {
      final response = await dio.post('voucher/voucherslist', data: {
        "voucher_type_id": vouchertypeid,
        "attribute_id": attributeid,
        "status": status,
        "created_by": createdby,
        "start_date": startdate,
        "end_date": enddate,
        "type": type,
        "term": term,
        "branch_id": branchId,
        "is_transfered_only": isTransferedOnly
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<List<InvoiceTypeModel>> getInvoiceTypesList(
      String isdefault) async {
    try {
      final response = await dio.get(
        '/masters/listinvoicetypes',
        queryParameters: {'is_default': isdefault},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];
        return data.map((e) => InvoiceTypeModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to get invoice types');
      }
    } catch (e) {
      throw Exception('Failed to get invoice types: $e');
    }
  }

  static Future<Map<String, dynamic>> getVouchersListAPIForDelivery(
      String status,
      String createdby,
      String deliverydate,
      String term,
      String branchId) async {
    try {
      final response = await dio.post('voucher/voucherslistfordelivery', data: {
        "status": status,
        "created_by": createdby,
        "delivery_date": deliverydate,
        "term": term,
        "branch_id": branchId
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getVouchersListAPIForReturn(
      String status,
      String createdby,
      String deliverydate,
      String term,
      String branchId) async {
    try {
      final response = await dio.post('voucher/voucherslistforreturn', data: {
        "status": status,
        "created_by": createdby,
        "return_date": deliverydate,
        "term": term,
        "branch_id": branchId
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getVoucherAllocationDetailsAPI(
    String fileid,
    String startdate,
    String enddate,
    String createdby,
  ) async {
    try {
      final response =
          await dio.post('voucher/getvoucherallocationdetails', data: {
        "file_id": fileid,
        "start_date": startdate,
        "end_date": enddate,
        "created_by": createdby,
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateVoucherStatusAPI(
      String fileid, String status) async {
    try {
      final response = await dio.post('voucher/updatevoucherstatus', data: {
        "file_id": fileid,
        "status": status,
        "userid": LocalStorage.getLoggedUserdata()['userid'].toString()
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> transferVoucherAPI(
    String fileId,
    String branchFrom,
    String branchTo,
    String createdBy,
  ) async {
    try {
      final response = await dio.post('voucher/transfervoucher', data: {
        "file_id": fileId,
        "branch_from": branchFrom,
        "branch_to": branchTo,
        "created_by": createdBy,
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUsersListAPI(
      String usergroupid, String term, String branchid) async {
    try {
      print({"usergroupid": usergroupid, "term": term, "branch_id": branchid});
      final response = await dio.post('users/userslist', data: {
        "usergroupid": usergroupid,
        "term": term,
        "branch_id": branchid
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<List<UserModel>> getUsersListByModelAPI(
      String usergroupid, String term) async {
    try {
      final response = await dio.post('users/userslist',
          data: {"usergroupid": usergroupid, "term": term});

      if (response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];
        return data.map((e) => UserModel.fromJson(e)).toList();
      } else {
        throw Exception();
      }
    } catch (e) {
      throw Exception();
    }
  }

  static Future<Map<String, dynamic>> getMasterDetails(
      String term, String tablename) async {
    try {
      final response =
          await dio.get('masters/listmasterdetails', queryParameters: {
        "term": term,
        "tablename": tablename,
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getMasterDetailsAsList(
      String term, String tablename) async {
    try {
      final response =
          await dio.get('masters/listmasterdetails', queryParameters: {
        "term": term,
        "tablename": tablename,
      });
      print(response.data);
      if (response.data['status'] == 'success') {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> addMasterDetails(
      String tablename, String name, String createdby) async {
    try {
      final response = await dio.post('masters/addmasterdetails', data: {
        "tablename": tablename,
        "name": name,
        "created_by": createdby
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> editMasterDetails(
      String tablename, String id, String name) async {
    try {
      final response = await dio.put('masters/editmasterdetails', data: {
        "tablename": tablename,
        "id": id,
        "name": name,
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addUserAPI(
      String name,
      String branchid,
      String phone,
      String username,
      String password,
      String groupid,
      String createdby) async {
    try {
      final response = await dio.post('users/adduser', data: {
        "name": name,
        "branch_id": branchid,
        "phone": phone,
        "username": username,
        "password": password,
        "user_group_id": groupid,
        "created_by": createdby
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addMasterAPI(
      String table, String name, String createdby) async {
    try {
      final response = await dio.post('masters/createmaster',
          data: {"table": table, "name": name, "created_by": createdby});
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addDocumentTypeAPI(
      String name,
      String reminderdays,
      String documentfor,
      String ismandatory,
      String createdby) async {
    try {
      final response = await dio.post('masters/adddocumenttype', data: {
        "name": name,
        "reminder_days": reminderdays,
        "document_for": documentfor,
        "is_mandatory": ismandatory,
        "created_by": createdby
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> editDocumentTypeAPI(
    String id,
    String name,
    String reminderdays,
    String documentfor,
    String ismandatory,
  ) async {
    try {
      final response = await dio.post('masters/editdocumenttype', data: {
        "id": id,
        "name": name,
        "reminder_days": reminderdays,
        "document_for": documentfor,
        "is_mandatory": ismandatory,
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addVoucherAllocationAPI(
      String voucherid,
      String vouchertype,
      String vouchervalue,
      String allocatedvalue,
      String narration,
      String createdby) async {
    try {
      final response = await dio.post('voucher/addvoucherallocation', data: {
        "voucher_id": voucherid,
        "voucher_type": vouchertype,
        "voucher_value": vouchervalue,
        "allocated_value": allocatedvalue,
        "narration": narration,
        "created_by": createdby
      });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> editUserAPI(
    String id,
    String name,
    String branchid,
    String phone,
    String username,
    String password,
    String groupid,
  ) async {
    try {
      final response = await dio.post('users/edituser', data: {
        'id': id,
        "name": name,
        "branch_id": branchid,
        "phone": phone,
        "username": username,
        "password": password,
        "user_group_id": groupid
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> editMasterAPI(
      String id, String name, String table, String createdby) async {
    try {
      final response = await dio.put('masters/editmaster/$id',
          data: {'table': table, "name": name, "created_by": createdby});
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<List<UserGroupModel>> getUserGroupsList() async {
    try {
      final response = await dio.get('users/listusergroups');
      print(response.data);

      if (response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];
        return data.map((e) => UserGroupModel.fromJson(e)).toList();
      } else {
        throw Exception();
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<List<UnitModel>> getUnitListAPI(
      String term, BuildContext context) async {
    try {
      final response =
          await dio.get('masters/unitlist', queryParameters: {'term': term});
      print(response.data);

      if (response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];
        return data.map((e) => UnitModel.fromJson(e)).toList();
      } else {
        throw Exception();
      }
    } catch (e) {
      throw Exception();
    }
  }

  static Future<Map<String, dynamic>> customersListAPI(
      String subledgertypeid, String term, String branchid) async {
    try {
      final response = await dio.get('subledger/listsubledgers',
          queryParameters: {
            'subledger_type': subledgertypeid,
            'searchTerm': term,
            'branch_id': branchid
          });
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e};
    }
  }

  static Widget loadingScreen(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 1,
          color: Colors.black,
        ),
      ),
    );
  }

  static Widget emptyScreen(String message, BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width / 1.1,
            child: Lottie.asset(
              "assets/images/empty.json",
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: APIService.appfont,
                  fontSize: 13,
                  fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }

  static String formatDate(DateTime? date, [bool forApi = false]) {
    if (date == null) return '';
    String formattedDate = forApi
        ? DateFormat('yyyy-MM-dd').format(date)
        : DateFormat('dd / MM / yyyy').format(date);
    return formattedDate;
  }

  static String formatDatefromDate(DateTime date, [bool forApi = false]) {
    String formattedDate =
        DateFormat(forApi ? 'yyyy-MM-dd' : 'dd / MM / yyyy').format(date);
    return formattedDate;
  }

  static void showSnackBar(String status, String message) {
    if (status == "success") {
      getmod.Get.snackbar("Great", message,
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      getmod.Get.snackbar("Note", message,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  static Future<List<dynamic>> getSubledgerListByTerm(
      String term, String subledgerType, String branchid) async {
    try {
      final response = await dio.get('subledger/listsubledgers',
          queryParameters: {
            'searchTerm': term,
            'subledger_type': subledgerType,
            'branch_id': branchid
          });

      if (response.data['status'] == 'success') {
        return response.data['data'] as List;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getCompanyDetails() async {
    try {
      final response = await dio.get('users/getcompanysettings');
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getVoucherReportAPI(
      String title,
      String companyname,
      String logourl,
      String address,
      String mobile,
      String fromdate,
      String todate,
      List<dynamic> items) async {
    try {
      final response = await dio.post('reports/generatevoucherreport', data: {
        "title": title,
        "companyname": companyname,
        "logourl": logourl,
        "address": address,
        "mobile": mobile,
        "items": items,
        "fromdate": fromdate,
        "todate": todate
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getVoucherAllocationReportAPI(
      String title,
      String companyname,
      String logourl,
      String address,
      String mobile,
      String fromdate,
      String todate,
      List<dynamic> items) async {
    try {
      final response =
          await dio.post('reports/generatevoucherallocationreport', data: {
        "title": title,
        "companyname": companyname,
        "logourl": logourl,
        "address": address,
        "mobile": mobile,
        "items": items,
        "fromdate": fromdate,
        "todate": todate
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getVoucherAllocationDetailsReportAPI(
      String title,
      String companyname,
      String logourl,
      String address,
      String mobile,
      String fromdate,
      String todate,
      List<dynamic> items) async {
    try {
      final response = await dio
          .post('reports/generatevoucherallocationdetailsreport', data: {
        "title": title,
        "companyname": companyname,
        "logourl": logourl,
        "address": address,
        "mobile": mobile,
        "items": items,
        "fromdate": fromdate,
        "todate": todate
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getInvetoryByDateTerm(
      DateTime startDate, DateTime endDate, String term,
      [String fileId = '']) async {
    try {
      final response =
          await dio.get('inventory/getinventorybydate', queryParameters: {
        'start_date': formatDatefromDate(startDate, true),
        'end_date': formatDatefromDate(endDate, true),
        'term': term,
        'file_id': fileId
      });
      print(response.data);

      if (response.data['status'] == 'success') {
        return response.data['data'] as List;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getUntisByTerm(String term) async {
    try {
      final response =
          await dio.get('masters/unitlist', queryParameters: {'term': term});
      print(response.data);

      if (response.data['status'] == 'success') {
        return response.data['data'] as List;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addVoucher(
      String bookingNo,
      String branchId,
      String serialcode,
      String referrenceid,
      String voucherdate,
      String subledgerid,
      String subledgername,
      String cautiondeposit,
      String currencyid,
      String currency,
      String exchangerate,
      String taxformat,
      String discount,
      String ispaid,
      String paidamount,
      String narration,
      List<dynamic> items,
      String voucherdeliverydate,
      String voucherissuedate,
      String voucherreturndate,
      String vouchernextavailabledate,
      String remarks,
      String invoiceType,
      String createdby) async {
    try {
      final data = {
        "booking_no": bookingNo,
        "branch_id": branchId,
        "user_id": createdby,
        "serial_code": serialcode,
        "referrence_id": referrenceid,
        "voucher_date": voucherdate,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "caution_deposit": cautiondeposit,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "tax_format": taxformat,
        "discount": discount,
        "is_paid": ispaid,
        "paid_amount": paidamount,
        "narration": narration,
        "items": items,
        "voucher_delivery_date": voucherdeliverydate,
        "voucher_issue_date": voucherissuedate,
        "voucher_return_date": voucherreturndate,
        "voucher_next_available_date": vouchernextavailabledate,
        "remarks": remarks,
        "invoice_type": invoiceType
      };

      print(data);

      final response = await dio.post('voucher/addvoucher', data: data);
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addPurchase(
      String branchId,
      String serialcode,
      String referrenceid,
      String voucherdate,
      String subledgerid,
      String subledgername,
      String currencyid,
      String currency,
      String exchangerate,
      String taxformat,
      String discount,
      String ispaid,
      String paidamount,
      String narration,
      List<dynamic> items,
      String voucherdeliverydate,
      String voucherissuedate,
      String voucherreturndate,
      String vouchernextavailabledate,
      String remarks,
      String invoiceType,
      String createdby) async {
    try {
      final data = {
        "branch_id": branchId,
        "user_id": createdby,
        "serial_code": serialcode,
        "referrence_id": referrenceid,
        "voucher_date": voucherdate,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "tax_format": taxformat,
        "discount": discount,
        "is_paid": ispaid,
        "paid_amount": paidamount,
        "narration": narration,
        "items": items,
        "voucher_delivery_date": voucherdeliverydate,
        "voucher_issue_date": voucherissuedate,
        "voucher_return_date": voucherreturndate,
        "voucher_next_available_date": vouchernextavailabledate,
        "remarks": remarks,
        "invoice_type": invoiceType
      };

      print(data);

      final response = await dio.post('voucher/addpurchase', data: data);
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> editVoucher(
      String bookingNo,
      String branchId,
      String serialCode,
      String fileId,
      String referrenceid,
      String voucherdate,
      String subledgerid,
      String subledgername,
      String cautiondeposit,
      String currencyid,
      String currency,
      String exchangerate,
      String discount,
      String taxformat,
      String ispaid,
      String paidamount,
      String narration,
      List<dynamic> items,
      List<String> unUsedIds,
      String voucherdeliverydate,
      String voucherissuedate,
      String voucherreturndate,
      String vouchernextavailabledate,
      String remarks,
      String invoiceType,
      String createdby) async {
    try {
      final data = {
        "booking_no": bookingNo,
        "branch_id": branchId,
        "user_id": createdby,
        "file_id": fileId,
        "serial_code": serialCode,
        "referrence_id": referrenceid,
        "voucher_date": voucherdate,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "caution_deposit": cautiondeposit,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "tax_format": taxformat,
        "discount": discount,
        "is_paid": ispaid,
        "paid_amount": paidamount,
        "narration": narration,
        "items": items,
        "un_used_ids": unUsedIds,
        "voucher_delivery_date": voucherdeliverydate,
        "voucher_issue_date": voucherissuedate,
        "voucher_return_date": voucherreturndate,
        "voucher_next_available_date": vouchernextavailabledate,
        "remarks": remarks,
        "invoice_type": invoiceType
      };

      print(data);

      final response = await dio.post('voucher/editvoucher', data: data);
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> editPurchase(
      String branchId,
      String serialCode,
      String fileId,
      String referrenceid,
      String voucherdate,
      String subledgerid,
      String subledgername,
      String currencyid,
      String currency,
      String exchangerate,
      String discount,
      String taxformat,
      String ispaid,
      String paidamount,
      String narration,
      List<dynamic> items,
      List<String> unUsedIds,
      String voucherdeliverydate,
      String voucherissuedate,
      String voucherreturndate,
      String vouchernextavailabledate,
      String remarks,
      String invoiceType,
      String createdby) async {
    try {
      final data = {
        "branch_id": branchId,
        "user_id": createdby,
        "file_id": fileId,
        "serial_code": serialCode,
        "referrence_id": referrenceid,
        "voucher_date": voucherdate,
        "subledger_id": subledgerid,
        "subledger_name": subledgername,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "tax_format": taxformat,
        "discount": discount,
        "is_paid": ispaid,
        "paid_amount": paidamount,
        "narration": narration,
        "items": items,
        "un_used_ids": unUsedIds,
        "voucher_delivery_date": voucherdeliverydate,
        "voucher_issue_date": voucherissuedate,
        "voucher_return_date": voucherreturndate,
        "voucher_next_available_date": vouchernextavailabledate,
        "remarks": remarks,
        "invoice_type": invoiceType
      };

      print(data);

      final response = await dio.post('voucher/editpurchase', data: data);
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> generateVoucherInvoiceAPI(
      String title,
      String companyname,
      String logourl,
      String address,
      String mobile,
      List<dynamic> items,
      String fileId,
      String customerName,
      String customerPhone,
      String voucherDate,
      String deliveryDate,
      String functionDate,
      String returnDate,
      String totalAmount,
      String totalTax,
      String netAmount,
      String discount,
      String amountPaid,
      String balanceAmount) async {
    try {
      final data = {
        "title": title,
        "companyname": companyname,
        "logourl": logourl,
        "address": address,
        "mobile": mobile,
        "items": items,
        "file_id": fileId,
        "customer_name": customerName,
        "customer_phone": customerPhone,
        "voucher_date": voucherDate,
        "delivery_date": deliveryDate,
        "function_date": functionDate,
        "return_date": returnDate,
        "total_amount": totalAmount,
        "total_tax": totalTax,
        "net": netAmount,
        "discount": discount,
        "amount_paid": amountPaid,
        "balance_amount": balanceAmount
      };

      final response = await dio.post(
        '/reports/generatevoucherinvoice',
        data: data,
      );
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<void> openPDF(String url) async {
    try {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      throw 'Could not launch $url';
    }
  }

  static Future<void> sharePDF(String uri, String phone, bool islink) async {
    final url = "${baseurl}uploads/static/reports/$uri";

    try {
      if (islink) {
        Future<String> shortenUrlUsingTinyUrl(String longUrl) async {
          final response = await Dio()
              .get("https://tinyurl.com/api-create.php?url=$longUrl");

          if (response.statusCode == 200) {
            return response.data; // The shortened URL
          } else {
            throw Exception("Failed to shorten URL: ${response.statusMessage}");
          }
        }

        void shareFile() async {
          final uri = Uri.parse(
              "https://wa.me/$phone?text=${Uri.encodeComponent(await shortenUrlUsingTinyUrl(url))}");

          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            print("Could not launch WhatsApp");
          }
        }

        shareFile();
        return;
      }

      Directory directory =
          await getDownloadsDirectory() ?? await getTemporaryDirectory();
      // Create a file path for the document
      final filePath = '${directory.path}/${url.split('/').last}';
      print(filePath);

      // Download the document
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        // Write the file to the path
        final file = File(filePath);
        await file.writeAsBytes(response.data);
        await Share.shareXFiles([XFile(filePath)]);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      throw 'Could not launch $e';
    }
  }

  static Future<Map<String, dynamic>> deleteRecord(
      String tableName, String id) async {
    try {
      final response = await dio.post('masters/deleterecord', data: {
        "table_name": tableName,
        "id": id,
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteModelRecord(
      String tableName, String id) async {
    try {
      final response = await dio.put('masters/deletemaster/$id', data: {
        "table": tableName,
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> editSubledger(
      String id,
      String name,
      String phone,
      String branchid,
      String secondaryphone,
      String address,
      String subledgerType,
      String userGroupId,
      String username,
      String password,
      String updatedBy,
      String salaryperday) async {
    try {
      final response = await dio.put('subledger/editsubledger', data: {
        "id": id,
        "name": name,
        "phone": phone,
        "branch_id": branchid,
        "secondary_phone": secondaryphone,
        "address": address,
        "subledger_type": subledgerType,
        "user_group_id": userGroupId,
        "username": username,
        "password": password,
        "updated_by": updatedBy,
        "salary_per_day": salaryperday
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addSubledger(
      String name,
      String phone,
      String branchid,
      String secondaryphone,
      String address,
      String subledgerType,
      String userGroupId,
      String username,
      String password,
      String createdBy,
      String salaryperday) async {
    try {
      final response = await dio.post('subledger/addsubledger', data: {
        "name": name,
        "branch_id": branchid,
        "phone": phone,
        "secondary_phone": secondaryphone,
        "address": address,
        "subledger_type": subledgerType,
        "user_group_id": userGroupId,
        "username": username,
        "password": password,
        "created_by": createdBy,
        "salary_per_day": salaryperday
      });
      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getInventoryList(
      String searchTerm, String warehouse, String branchId) async {
    try {
      final response = await dio.get('inventory/listinventory',
          queryParameters: {
            'searchTerm': searchTerm,
            'warehouse': warehouse,
            'branch_id': branchId
          });
      print(response.data);

      if (response.data['status'] == 'success') {
        return response.data['data'] as List;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> uploadImage(File file) async {
    try {
      String fileName = file.path.split('/').last;
      final formData = {
        "document": await MultipartFile.fromFile(file.path, filename: fileName),
      };

      final response = await dio.post(
        'uploadfile/upload',
        data: formData,
      );

      print(response.data);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {'success': 0, 'message': 'Not Uploaded'};
      }
    } catch (err) {
      return {'success': 0, 'message': err.toString()};
    }
  }

  static Future<Map<String, dynamic>> addInventory(
      String itemCode,
      String itemName,
      String unitId,
      String unitName,
      String unitSymbol,
      String unitFactor,
      String itemType,
      String price,
      String branchId,
      String createdBy) async {
    try {
      final data = {
        "item_code": itemCode,
        "item_name": itemName,
        "unit_id": unitId,
        "unit_name": unitName,
        "unit_symbol": unitSymbol,
        "unit_factor": unitFactor,
        "item_type": itemType,
        "price": price,
        "branch_id": branchId,
        "created_by": createdBy
      };

      print(data);

      final response = await dio.post(
        'inventory/addinventory',
        data: data,
      );

      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> editInventory(
      String id,
      String itemCode,
      String itemName,
      String unitId,
      String unitName,
      String unitSymbol,
      String unitFactor,
      String itemType,
      String price,
      String branchId,
      String createdBy) async {
    try {
      final data = {
        "item_code": itemCode,
        "item_name": itemName,
        "unit_id": unitId,
        "unit_name": unitName,
        "unit_symbol": unitSymbol,
        "unit_factor": unitFactor,
        "item_type": itemType,
        "price": price,
        "branch_id": branchId,
        "created_by": createdBy
      };

      print(data);

      final response = await dio.put(
        'inventory/editinventory/$id',
        data: data,
      );

      print(response.data);
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static String imageUrl(String docname) {
    print("${baseurl}proxy-image?url=$docname");
    return "${baseurl}proxy-image?url=${Uri.encodeComponent(docname)}";
  }

  static Future<Map<String, dynamic>> getVoucherDetails(String fileId) async {
    try {
      final formData = {
        'file_id': fileId,
      };

      final response = await dio.post(
        'voucher/voucherdetailslist',
        data: formData,
      );
      dynamic httpresponse = response.data;
      print(httpresponse);
      return httpresponse;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getVoucherAllocationDetailsByFileID(
      String fileId) async {
    try {
      final formData = {
        'file_id': fileId,
      };

      final response = await dio.post(
        'voucher/voucherallocationlist',
        data: formData,
      );
      dynamic httpresponse = response.data;
      print(httpresponse);
      return httpresponse;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getOccupiedItemsByDate(DateTime startDate,
      DateTime endDate, String fileId, bool offRestriction) async {
    try {
      final response = await dio.get(
        '${baseurl}inventory/getoccupieditembydate',
        queryParameters: {
          'start_date': formatDatefromDate(startDate, true),
          'end_date': formatDatefromDate(endDate, true),
          'file_id': fileId,
          'off_restriction': offRestriction,
        },
      );
      dynamic httpresponse = response.data;
      if (httpresponse['status'] == 'success') {
        return httpresponse['data'] as List;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getOccupiedExportItems(
      String invoicetype, String fileId) async {
    try {
      final response = await dio.get(
        '${baseurl}inventory/getoccupiedexportitem',
        queryParameters: {'invoicetype': invoicetype, 'file_id': fileId},
      );
      dynamic httpresponse = response.data;
      if (httpresponse['status'] == 'success') {
        return httpresponse['data'] as List;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> isVoucherallocatedAPI(
      String fileid) async {
    try {
      final response = await dio.get(
        '${baseurl}voucher/isvoucherallocated',
        queryParameters: {
          'voucher_id': fileid,
        },
      );
      dynamic httpresponse = response.data;
      return httpresponse;
    } catch (e) {
      return {"status": "failed"};
    }
  }

  static Future<Map<String, dynamic>> isReferrenceAvailableAPI(
      String fileid) async {
    try {
      final response = await dio.get(
        '${baseurl}voucher/isrefnumberexist',
        queryParameters: {
          'file_id': fileid,
        },
      );
      dynamic httpresponse = response.data;
      return httpresponse;
    } catch (e) {
      return {"status": "failed"};
    }
  }

  static Future<Map<String, dynamic>> postGenerateBalanceSheetReport(
      String title,
      String companyname,
      String logourl,
      String address,
      String mobile,
      String trn,
      String todate,
      String currency,
      String branch,
      List<dynamic> items,
      String totaldebit,
      String totalcredit) async {
    try {
      final data = jsonEncode({
        "title": title,
        "companyname": companyname,
        "logourl": logourl,
        "address": address,
        "mobile": mobile,
        "trn": trn,
        "todate": todate,
        "currency": currency,
        "branch": branch,
        "items": items,
        "totaldebit": totaldebit,
        "totalcredit": totalcredit
      });

      final response = await dio.post(
        '/reports/generatebalancesheet',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> postGenerateProfitAndLossReport(
    String title,
    String companyname,
    String logourl,
    String address,
    String mobile,
    String trn,
    String fromdate,
    String todate,
    String currency,
    String branch,
    List<dynamic> items,
  ) async {
    try {
      final data = jsonEncode({
        "title": title,
        "companyname": companyname,
        "logourl": logourl,
        "address": address,
        "mobile": mobile,
        "trn": trn,
        "fromdate": fromdate,
        "todate": todate,
        "currency": currency,
        "branch": branch,
        "items": items,
      });

      final response = await dio.post(
        '/reports/generateprofitandloss',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> postGenerateStatementReport(
      String title,
      String companyname,
      String logourl,
      String address,
      String mobile,
      String trn,
      String fromdate,
      String todate,
      String subledgertitle,
      String subledgername,
      String branch,
      List<dynamic> items,
      String totalvouchervalue,
      String totalallocatedvalue,
      String totalbalancevalue) async {
    try {
      final data = jsonEncode({
        "title": title,
        "companyname": companyname,
        "logourl": logourl,
        "address": address,
        "mobile": mobile,
        "trn": trn,
        "items": items,
        "fromdate": fromdate,
        "todate": todate,
        "subledgertitle": subledgertitle,
        "subledgername": subledgername,
        "branch": branch,
        "totalvouchervalue": totalvouchervalue,
        "totalallocatedvalue": totalallocatedvalue,
        "totalbalancevalue": totalbalancevalue
      });

      final response = await dio.post(
        '/reports/generatestatement',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> postGenerateGeneralLedgerReport(
      String title,
      String companyname,
      String logourl,
      String address,
      String mobile,
      String trn,
      String fromdate,
      String todate,
      String currency,
      String branch,
      List<dynamic> items,
      String ledger) async {
    try {
      final data = jsonEncode({
        "title": title,
        "companyname": companyname,
        "logourl": logourl,
        "address": address,
        "mobile": mobile,
        "trn": trn,
        "fromdate": fromdate,
        "todate": todate,
        "currency": currency,
        "branch": branch,
        "items": items,
        "ledger": ledger
      });

      final response = await dio.post(
        '/reports/generategeneralledger',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> postGenerateTrialBalanceReport(
    String title,
    String companyname,
    String logourl,
    String address,
    String mobile,
    String trn,
    String fromdate,
    String todate,
    String currency,
    String branch,
    List<dynamic> items,
  ) async {
    try {
      final data = jsonEncode({
        "title": title,
        "companyname": companyname,
        "logourl": logourl,
        "address": address,
        "mobile": mobile,
        "trn": trn,
        "fromdate": fromdate,
        "todate": todate,
        "currency": currency,
        "branch": branch,
        "items": items,
      });

      final response = await dio.post(
        '/reports/generatetrialbalance',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static DateTime stringToDate(String string) {
    return DateFormat('yyyy-MM-dd').parse(string);
  }

  static String formatDateTimeString(String inputDate) {
    DateTime parsedDate = DateTime.parse(inputDate);
    return DateFormat('dd MMMM yyyy hh : mm a').format(parsedDate);
  }

  static String formatDateString(String inputDate) {
    DateTime parsedDate = DateTime.parse(inputDate);
    return DateFormat('dd MMMM yyyy').format(parsedDate);
  }

  static Future<Map<String, dynamic>> dashboard() async {
    try {
      final response = await dio.get(
        '/reports/dashboard',
      );
      dynamic httpresponse = response.data;
      print(httpresponse);
      return httpresponse;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> dashboardDriverBalances() async {
    try {
      final response = await dio.get(
        '/reports/dashboarddriverbalances',
      );
      dynamic httpresponse = response.data;
      print(httpresponse);
      return httpresponse;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

//////////////////////////////////

  static Future<Map<String, dynamic>> getLedgerByAttribute(
    String attribute,
  ) async {
    try {
      final response = await dio
          .post('/ledger/getledgerbyattribute', data: {"attribute": attribute});
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<List<VoucherSubledgerModel>>
      getDebtorSubledgerByVoucherTypeQueryList(
    String term,
    String vouchertype,
    String attributeid,
  ) async {
    try {
      final data = {
        "term": term,
        "vouchertype": vouchertype,
        "attributeid": attributeid
      };
      final response = await dio.get(
        '/subledger/getDebtorSubledgerByVoucherType',
        queryParameters: data,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        print("This is the response");
        print(data);
        return data
            .map((responsejson) => VoucherSubledgerModel.fromJson(responsejson))
            .toList();
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<List<PaymentTypeModel>> getPaymentTypeQueryList(
      String term) async {
    try {
      final response = await dio.get(
        '/masters/listpaymenttypes',
        queryParameters: {'term': term},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        print("This is the response");
        print(data);
        return data
            .map((responsejson) => PaymentTypeModel.fromJson(responsejson))
            .toList();
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<List<VoucherSubledgerModel>>
      getSubledgerForReceiptByAttributeIDQueryList(
    String term,
    String serialcode,
    String attributeid,
  ) async {
    try {
      print({
        "term": term,
        "serial_code": serialcode,
        "attribute_id": attributeid
      });
      final data = {
        "term": term,
        "serial_code": serialcode,
        "attribute_id": attributeid
      };
      final response = await dio.get(
        '/subledger/listsubledgersforreceiptbyattribute',
        queryParameters: data,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        print("This is the response");
        print(data);
        return data
            .map((responsejson) => VoucherSubledgerModel.fromJson(responsejson))
            .toList();
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<List<BranchByUserModel>> getBranchesListByUserId(
      String term, String userid) async {
    try {
      final response = await dio.post('/masters/listbranchbyuserid',
          data: {"user_id": userid, "search_term": term});
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((responsejson) => BranchByUserModel.fromJson(responsejson))
            .toList();
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<List<SalesmanByBranchModel>> getSalesmanListByBranchId(
      String term, String branchid) async {
    try {
      final response = await dio.post('/subledger/subledgerbybranchid',
          data: {"branch_id": branchid, "search_term": term});

      final data = (response.data?['data'] ?? []) as List;
      return data
          .map((responsejson) => SalesmanByBranchModel.fromJson(responsejson))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<Map<String, dynamic>?> addPaymentAPI(
    String serialcode,
    String vouchervalue,
    String narration,
    String allocationtype,
    String branchid,
    String warehouseid,
    String salesman,
    String paymentmethod,
    List<dynamic> voucherhead,
    List<dynamic> allocationdetails,
    String callback,
    String userid,
  ) async {
    try {
      final data = {
        'voucherhead': voucherhead,
        "serial_code": serialcode,
        "allocationdetails": allocationdetails,
        "vouchervalue": vouchervalue,
        "narration": narration,
        "allocation_type": allocationtype,
        "createdby": userid,
        "branch_id": branchid,
        "warehouse_id": warehouseid,
        "salesman_id": salesman,
        "callback": callback,
        "payment_method": paymentmethod
      };
      final response = await dio.post(
        '/voucher/addpaymentvoucher',
        data: data,
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<Map<String, dynamic>?>
      getSubledgerQueryListBySubledgertypeBySubledgerId(
    String subledgerid,
    String attributeid,
    String vouchertype,
    String term,
  ) async {
    try {
      final data = {
        "attributeid": attributeid,
        "vouchertype": vouchertype,
        "term": term,
        "subledger_id": subledgerid
      };
      final response = await dio.get(
        '/subledger/getDebtorSubledgerByVoucherTypeBySubledgerId',
        queryParameters: data,
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<Map<String, dynamic>?> getVoucherTypeDetailsByAttributeIDAPI(
    String attributeid,
    String vouchertypeid,
  ) async {
    try {
      final data = {
        'attribute_id': attributeid,
        'voucher_type_id': vouchertypeid
      };
      final response = await dio.get(
        '/vouchertype/getvouchertypedetailsbyattributeid',
        queryParameters: data,
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<Map<String, dynamic>> getBalanceVouchersListByAll(
    String vouchertype,
    String attributeid,
    String subledgerid,
  ) async {
    try {
      print({
        "voucher_type": vouchertype,
        "attribute_id": attributeid,
        "subledger_id": subledgerid
      });
      final data = {
        "voucher_type": vouchertype,
        "attribute_id": attributeid,
        "subledger_id": subledgerid
      };
      final response = await dio.post(
        '/voucher/getBalanceVoucherByVoucherType',
        data: data,
      );
      print(response.data);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<Map<String, dynamic>?> addReceiptAPI(
    String serialcode,
    String vouchervalue,
    String narration,
    String allocationtype,
    String branchid,
    String warehouseid,
    String salesman,
    String paymentmethod,
    List<dynamic> voucherhead,
    List<dynamic> allocationdetails,
    String callback,
    String userid,
  ) async {
    try {
      final data = {
        'voucherhead': voucherhead,
        "serial_code": serialcode,
        "allocationdetails": allocationdetails,
        "vouchervalue": vouchervalue,
        "narration": narration,
        "allocation_type": allocationtype,
        "createdby": userid,
        "branch_id": branchid,
        "warehouse_id": warehouseid,
        "salesman_id": salesman,
        "payment_method": paymentmethod,
        "callback": callback
      };
      final response = await dio.post(
        '/voucher/addreceiptvoucher',
        data: data,
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<List<VoucherTypeModel>> getVoucherTypesListByTerm(
    String term,
  ) async {
    try {
      final data = {"term": term};
      final response = await dio.get(
        '/vouchertype/vouchertypeslistbyterm',
        queryParameters: data,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((responsejson) => VoucherTypeModel.fromJson(responsejson))
            .toList();
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<Map<String, dynamic>> getVoucherTypeDetails(
      String vouchertypeid) async {
    try {
      final response = await dio.post('/vouchertype/getvouchertypedetails',
          data: {"voucher_type_id": vouchertypeid});
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<Map<String, dynamic>> postAddVoucherAPI(
      String serialcode,
      String vouchertype,
      String voucherdate,
      String refnumber,
      String paymentmethod,
      String bankname,
      String cardno,
      String chequeno,
      String chequedate,
      List<dynamic> entries,
      String currencyid,
      String currency,
      String exchangerate,
      String branchid,
      String costcenter,
      String createdby,
      String callback) async {
    print({
      "serial_code": serialcode,
      "voucher_type": vouchertype,
      "voucher_date": voucherdate,
      "ref_number": refnumber,
      "paymentmethod": paymentmethod,
      "bankname": bankname,
      "cardno": cardno,
      "chequeno": chequeno,
      "chequedate": chequedate,
      "voucherslist": entries,
      "currency_id": currencyid,
      "currency": currency,
      "exchange_rate": exchangerate,
      "branch_id": branchid,
      "cost_center": costcenter,
      "created_by": createdby,
      "callback": callback
    });
    try {
      final response = await dio.post('/voucher/addjournalvoucher', data: {
        "serial_code": serialcode,
        "voucher_type": vouchertype,
        "voucher_date": voucherdate,
        "ref_number": refnumber,
        "paymentmethod": paymentmethod,
        "bankname": bankname,
        "cardno": cardno,
        "chequeno": chequeno,
        "chequedate": chequedate,
        "voucherslist": entries,
        "currency_id": currencyid,
        "currency": currency,
        "exchange_rate": exchangerate,
        "branch_id": branchid,
        "cost_center": costcenter,
        "created_by": createdby,
        "callback": callback
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<PaginationModel<AttributeModel>> getAttriutesByPagination(
      String term, String limit, String page) async {
    try {
      final response = await dio.get('/vouchertype/attributeslist',
          queryParameters: {"term": term, 'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return PaginationModel<AttributeModel>.fromJson(
            response.data, AttributeModel.fromJson);
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<Map<String, dynamic>> addAttribute(
    String attribute,
    String description,
  ) async {
    final data = {
      "attribute": attribute,
      "description": description,
      "created_by": LocalStorage.getLoggedUserdata()['userid'].toString()
    };
    try {
      final response = await dio.post('/vouchertype/addattribute', data: data);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to Add Attribute');
      }
    } on DioException catch (e) {
      throw Exception('Failed to Add Attribute $e');
    } catch (e) {
      throw Exception('Failed to Add Attribute $e');
    }
  }

  static Future<Map<String, dynamic>> editAttribute(
    String id,
    String attribute,
    String description,
  ) async {
    final data = {
      "attribute": attribute,
      "description": description,
      "modified_by": LocalStorage.getLoggedUserdata()['userid'].toString()
    };
    try {
      final response =
          await dio.put('/vouchertype/editattribute/$id', data: data);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to Add Attribute');
      }
    } on DioException catch (e) {
      throw Exception('Failed to Add Attribute $e');
    } catch (e) {
      throw Exception('Failed to Add Attribute $e');
    }
  }

  static Future<PaginationModel<LedgerModel>> getLedgerListByPagination(
      String term, String limit, String page) async {
    try {
      final response = await dio.post('/ledger/listledgerbypagination',
          data: {"term": term, 'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return PaginationModel<LedgerModel>.fromJson(
            response.data, LedgerModel.fromJson);
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<PaginationModel<dynamic>> getSubLedgerListByPagination(
      String term, String limit, String page) async {
    try {
      final response = await dio.post('/subledger/listsubledgerbypagination',
          data: {"term": term, 'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return PaginationModel<dynamic>.fromJson(
            response.data, (value) => value);
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<List<ParentLedgerModel>> getParentLedgersList(
    String term,
  ) async {
    try {
      final data = {
        "term": term,
      };
      final response = await dio.post(
        '/ledger/getparentledgerslist',
        data: data,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        print("This is the response");
        print(data);
        return data
            .map((responsejson) => ParentLedgerModel.fromJson(responsejson))
            .toList();
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<Map<String, dynamic>?> getLedgerRootAccountAPI(
    String parentledgerid,
    String prefixval,
  ) async {
    try {
      final data = {
        'parent_ledger_id': parentledgerid,
        "prefix_val": prefixval
      };
      final response = await dio.post(
        '/ledger/getledgerrootaccount',
        data: data,
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<List<SubledgerTypeModel>> getSubledgerTypeQueryList(
      String term) async {
    try {
      final response = await dio.get(
        '/subledger/listsubledgertypes',
        queryParameters: {'term': term},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((responsejson) => SubledgerTypeModel.fromJson(responsejson))
            .toList();
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<Map<String, dynamic>> addLedger(
      String ledgerparentaccount,
      String root,
      String prefix,
      String ledgeraccountno,
      String ledgeraccountname,
      String isparent,
      String issystemgenerated,
      String havesubledger,
      List<dynamic> subledgertypes,
      String userid) async {
    print("This is the ledger body");
    print({
      "ledger_parent_acc": ledgerparentaccount,
      "root": root,
      "prefix_va": prefix,
      "ledger_acc_no": ledgeraccountno,
      "ledger_acc_name": ledgeraccountname,
      "is_parent": isparent,
      "system_generated": issystemgenerated,
      "have_subledger": havesubledger,
      "subledger_types": subledgertypes,
      "createdby": userid
    });
    final data = {
      "ledger_parent_acc": ledgerparentaccount,
      "root": root,
      "prefix_va": prefix,
      "ledger_acc_no": ledgeraccountno,
      "ledger_acc_name": ledgeraccountname,
      "is_parent": isparent,
      "system_generated": issystemgenerated,
      "have_subledger": havesubledger,
      "subledger_types": subledgertypes,
      "createdby": userid
    };
    try {
      final response = await dio.post('/ledger/addledger', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> activeBranchesListByUserIdAPI(
    String userid,
  ) async {
    try {
      final data = {
        "user_id": userid,
      };
      final response = await dio.post(
        '/masters/activeBranchesByUserId',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> postFinanceVoucherListByPaginationByLimit(
    String vouchertype,
    String term,
    String branchids,
    int pagenumber,
    int pagelimit,
  ) async {
    try {
      final data = {
        "voucher_type": vouchertype,
        "term": term,
        "branch_id": branchids,
        "page": pagenumber,
        "limit": pagelimit
      };

      final response = await dio.post(
        '/voucher/financevoucherlistbypagination',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> postDeleteVoucherByFileID(
    String fileid,
  ) async {
    try {
      final response = await dio.post(
        '/voucher/deletevoucherbyfileid/$fileid',
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> postDeleteVoucherAllocationByFileID(
    String fileid,
  ) async {
    try {
      final response = await dio.post(
        '/voucher/deletevoucherallocation',
        data: {"file_id": fileid},
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> getFinanceVoucherDetailsByFileID(
    String fileid,
  ) async {
    try {
      final response = await dio.post('/voucher/getfinancevoucherbyfileid',
          data: {"file_id": fileid});
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<PaginationModel<SubledgerTypeModel>>
      getSubLedgerTypesByPagination(
          String term, String limit, String page) async {
    try {
      final response = await dio.get('/subledgertypes/listsubledgertypes',
          queryParameters: {"term": term, 'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return PaginationModel<SubledgerTypeModel>.fromJson(
            response.data, SubledgerTypeModel.fromJson);
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<Map<String, dynamic>> addSubledgerType(
    String subledgertypename,
    String editable,
    String isgenerated,
  ) async {
    final data = {
      "subledger_type_name": subledgertypename,
      "is_editable": editable,
      "system_generated": isgenerated,
      "created_by": LocalStorage.getLoggedUserdata()['userid'].toString()
    };
    try {
      final response =
          await dio.post('/subledgertypes/addsubledgertype', data: data);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to Add Subledger');
      }
    } on DioException catch (e) {
      throw Exception('Failed to Add Subledger $e');
    } catch (e) {
      throw Exception('Failed to Add Subledger $e');
    }
  }

  static Future<Map<String, dynamic>> editSubledgerType(
    String id,
    String subledgertypename,
    String editable,
    String isgenerated,
  ) async {
    final data = {
      "subledger_type_name": subledgertypename,
      "is_editable": editable,
      "system_generated": isgenerated,
      "created_by": LocalStorage.getLoggedUserdata()['userid'].toString()
    };
    try {
      final response =
          await dio.put('/subledgertypes/editsubledgertype/$id', data: data);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to Edit Subledger');
      }
    } on DioException catch (e) {
      throw Exception('Failed to Edit Subledger $e');
    } catch (e) {
      throw Exception('Failed to Edit Subledger $e');
    }
  }

  static Future<List<MainSubLedgerModel>> getSubledgerByLedgerIdQueryList(
    String ledgerid,
    String term,
  ) async {
    try {
      final data = {"ledgerid": ledgerid, "term": term};
      final response = await dio.get(
        '/subledger/getSubledgersByledgerId',
        queryParameters: data,
      );
      print("This is the data");
      print(response.data);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((responsejson) => MainSubLedgerModel.fromJson(responsejson))
            .toList();
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      print("This is exception");
      print(e);
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<List<MainLedgerModel>> getLedgerListByTerm(String term) async {
    try {
      final response = await dio.get(
        '/ledger/listledger',
        queryParameters: {'term': term},
      );
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map(
              (e) => MainLedgerModel.fromJson(e),
            )
            .toList();
      } else {
        throw Exception();
      }
    } on DioException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> deleteAllocationsByIdsAPI(
    List<dynamic> ids,
  ) async {
    try {
      final response = await dio.post(
        '/voucher/deactivatevoucherallocations',
        data: {'ids': ids},
      );

      return response.data;
    } catch (e) {
      print(e);
      return {'status': 'error', 'message': e};
    }
  }

  static String formatDateView(DateTime date) {
    final DateFormat formatter = DateFormat('dd / MM / yyyy');
    return formatter.format(date);
  }

  static Future<Map<String, dynamic>> downloadFile(
      String url, String fileName) async {
    try {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile == null) {
        throw Exception("Cannot find USERPROFILE environment variable.");
      }

      final downloadsDir = path.join(userProfile, 'Downloads');
      final filePath = path.join(downloadsDir, fileName);

      final response = await http.get(Uri.parse(url));

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return {"status": "success", "message": "File downloaded to $filePath"};
    } catch (e) {
      return {"status": "failed", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getBalanceSheetReport(
    String todate,
    String branchid,
  ) async {
    try {
      final data = {"to_date": todate, "branch_id": branchid};

      final response = await dio.get(
        '/voucher/balancesheet',
        queryParameters: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> getProfitAndLossReport(
    String fromdate,
    String todate,
    String branchid,
  ) async {
    try {
      final data = {
        "from_date": fromdate,
        "to_date": todate,
        "branch_id": branchid
      };

      final response = await dio.get(
        '/voucher/profitandloss',
        queryParameters: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> getTrialBalanceReport(
    String fromdate,
    String todate,
    String branchid,
  ) async {
    try {
      final data = {
        "from_date": fromdate,
        "to_date": todate,
        "branch_id": branchid
      };

      final response = await dio.get(
        '/voucher/trialbalance',
        queryParameters: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<List<SubledgerModel>> getSubledgerQueryList(
    String serialcode,
    String term,
    String branchid,
    String userid,
  ) async {
    try {
      print({"serial_code": serialcode, "term": term, "branch_id": branchid});
      final data = {
        "serial_code": serialcode,
        "term": term,
        "branch_id": branchid
      };
      final response = await dio.post(
        '/subledger/getsubledgerlistbyvouchertype',
        data: data,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((responsejson) => SubledgerModel.fromJson(responsejson))
            .toList();
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }

  static Future<Map<String, dynamic>> statementReport(
      String startdate,
      String enddate,
      String subledgerid,
      String branchid,
      String attributeid) async {
    try {
      final data = {
        "start_date": startdate,
        "end_date": enddate,
        "subledger_id": subledgerid,
        "branch_id": branchid,
        "attribute_id": attributeid
      };

      final response = await dio.post(
        '/voucher/statementreport',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static String formatReportDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd / MM / yyyy');
    return formatter.format(date);
  }

  static Future<Map<String, dynamic>> getGenralLedgerReport(
    String ledgerid,
    String type,
    String fromdate,
    String todate,
    String subledgerid,
    String branchid,
  ) async {
    try {
      print({
        "ledger_id": ledgerid,
        "type": type,
        "start_date": fromdate,
        "end_date": todate,
        "subledger_id": subledgerid,
        "branch_id": branchid
      });
      final data = {
        "ledger_id": ledgerid,
        "type": type,
        "start_date": fromdate,
        "end_date": todate,
        "subledger_id": subledgerid,
        "branch_id": branchid
      };

      final response = await dio.post(
        '/voucher/generalledgerreport',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> postVoucherListByDateRangeReport(
    String vouchertype,
    String startdate,
    String enddate,
    String subledgerid,
    String branchid,
  ) async {
    print({
      "voucher_type": vouchertype,
      "start_date": startdate,
      "end_date": enddate,
      "subledger_id": subledgerid,
      "branch_id": branchid
    });
    try {
      final data = {
        "voucher_type": vouchertype,
        "start_date": startdate,
        "end_date": enddate,
        "subledger_id": subledgerid,
        "branch_id": branchid
      };

      final response = await dio.post(
        '/voucher/voucherlistbydaterangereport',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> postGenerateVoucherReport(
    String title,
    String companyname,
    String logourl,
    String address,
    String mobile,
    String trn,
    String fromdate,
    String todate,
    String currency,
    String branch,
    String salesman,
    String totalwithoutvat,
    String vatamount,
    String discount,
    String grandtotal,
    List<dynamic> items,
    String userid,
    String subledgertitle,
  ) async {
    print({
      "title": title,
      "companyname": companyname,
      "logourl": logourl,
      "address": address,
      "mobile": mobile,
      "trn": trn,
      "fromdate": fromdate,
      "todate": todate,
      "currency": currency,
      "branch": branch,
      "salesman": salesman,
      "items": items,
      "totalwithoutvat": totalwithoutvat,
      "vatamount": vatamount,
      "discount": discount,
      "grandtotal": grandtotal
    });
    try {
      final data = jsonEncode({
        "title": title,
        "companyname": companyname,
        "logourl": logourl,
        "address": address,
        "mobile": mobile,
        "trn": trn,
        "fromdate": fromdate,
        "todate": todate,
        "currency": currency,
        "branch": branch,
        "salesman": salesman,
        "items": items,
        "totalwithoutvat": totalwithoutvat,
        "vatamount": vatamount,
        "discount": discount,
        "grandtotal": grandtotal,
        "subledgertitle": subledgertitle
      });

      final response = await dio.post(
        '/reports/generatevoucherreport',
        data: data,
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(e);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  static String formatReverseDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }
}
