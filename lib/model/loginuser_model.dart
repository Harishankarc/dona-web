import 'dart:convert'; // Add this to handle JSON decoding

import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class LoginUserModel {
  final int? id;
  final String? name;
  final String? phone;
  final String? mobile;
  final int? locationId;
  final int? stateId;
  final int? countryId;
  final int? barcodeVisibility;
  final int? userGroupId;
  final String? isSalesman;
  final String? isUser;
  final String? branch;
  final String? username;
  final String? password;
  final String? usergroupName;
  final Map<String, bool>? permissions;
  final String? apiToken;
  final int? defaultCurrencyId;
  final String? defaultCurrency;
  final int? defaultExchangeRate;
  final int? defaultBranchId;
  final String? defaultBranchName;
  final int? defaultWarehouseId;
  final String? defaultWarehouseName;
  final int? rounding;
  final int? purchaseratetype;
  final String? companylogo;
  final String? companyname;
  final String? trn;
  final String? address;
  final String? telephone;

  LoginUserModel(
      {this.id,
      this.name,
      this.phone,
      this.mobile,
      this.locationId,
      this.stateId,
      this.countryId,
      this.barcodeVisibility,
      this.userGroupId,
      this.isSalesman,
      this.isUser,
      this.branch,
      this.username,
      this.password,
      this.usergroupName,
      this.permissions,
      this.apiToken,
      this.defaultCurrencyId,
      this.defaultCurrency,
      this.defaultExchangeRate,
      this.defaultBranchId,
      this.defaultBranchName,
      this.defaultWarehouseId,
      this.defaultWarehouseName,
      this.rounding,
      this.purchaseratetype,
      this.companylogo,
      this.companyname,
      this.trn,
      this.address,
      this.telephone});

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return LoginUserModel(
        id: decoder.getInt('id'),
        name: decoder.getString('name'),
        phone: decoder.getString('phone'),
        mobile: decoder.getString('mobile'),
        locationId: decoder.getInt('location_id'),
        stateId: decoder.getInt('state_id'),
        countryId: decoder.getInt('country_id'),
        barcodeVisibility: decoder.getInt('barcode_visibility'),
        userGroupId: decoder.getInt('user_group_id'),
        isSalesman: decoder.getString('is_salesman'),
        isUser: decoder.getString('is_user'),
        branch: decoder.getString('branch'),
        username: decoder.getString('username'),
        password: decoder.getString('password'),
        usergroupName: decoder.getString('usergroup_name'),
        permissions:
            jsonDecode(decoder.getString('permission')).cast<String, bool>(),
        apiToken: decoder.getString('api_token'),
        defaultCurrencyId: decoder.getInt('default_currency_id'),
        defaultCurrency: decoder.getString('default_currency'),
        defaultExchangeRate: decoder.getInt('default_exchange_rate'),
        defaultBranchId: decoder.getInt('default_branch_id'),
        defaultBranchName: decoder.getString('default_branch_name'),
        defaultWarehouseId: decoder.getInt('default_warehouse_id'),
        defaultWarehouseName: decoder.getString('default_warehouse_name'),
        rounding: decoder.getInt('rounding'),
        purchaseratetype: decoder.getInt('purchase_rate_type'),
        companylogo: decoder.getString('company_logo'),
        companyname: decoder.getString('company_name'),
        trn: decoder.getString('trn'),
        address: decoder.getString('address'),
        telephone: decoder.getString('telephone'));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'mobile': mobile,
      'location_id': locationId,
      'state_id': stateId,
      'country_id': countryId,
      'barcode_visibility': barcodeVisibility,
      'user_group_id': userGroupId,
      'is_salesman': isSalesman,
      'is_user': isUser,
      'branch': branch,
      'username': username,
      'password': password,
      'usergroup_name': usergroupName,
      'permissions': permissions,
      'api_token': apiToken,
      'default_currency_id': defaultCurrencyId,
      'default_currency': defaultCurrency,
      'default_exchange_rate': defaultExchangeRate,
      'default_branch_id': defaultBranchId,
      'default_branch_name': defaultBranchName,
      'default_warehouse_id': defaultWarehouseId,
      'default_warehouse_name': defaultWarehouseName,
      'rounding': rounding,
      'purchase_rate_type': purchaseratetype,
      'company_logo': companylogo,
      'company_name': companyname,
      'trn': trn,
      'address': address,
      'telephone': telephone
    };
  }

  static List<LoginUserModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => LoginUserModel.fromJson(json)).toList();
  }
}
