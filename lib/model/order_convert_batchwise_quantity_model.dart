import 'package:LeLaundrette/model/batchwise_quantity_model.dart';

class OrderConvertBatchwiseQuantityModel {
  String? orderdetailid;
  String? productid;
  String? itemtype;
  String? itemcode;
  String? itemname;
  String? brandid;
  String? categoryid;
  String? quantity;
  String? unitid;
  String? unitfactor;
  String? unitname;
  String? rate;
  String? currencyid;
  String? exchangerate;
  String? taxtype;
  String? taxpercentage;
  String? calculatedquantity;
  String? selected;
  List<BatchwiseQuantityModel>? voucherdetails;

  OrderConvertBatchwiseQuantityModel(
      {this.orderdetailid,
      this.productid,
      this.itemtype,
      this.itemcode,
      this.itemname,
      this.brandid,
      this.categoryid,
      this.quantity,
      this.unitid,
      this.unitfactor,
      this.unitname,
      this.rate,
      this.currencyid,
      this.exchangerate,
      this.taxtype,
      this.taxpercentage,
      this.calculatedquantity,
      this.selected,
      this.voucherdetails});

  OrderConvertBatchwiseQuantityModel.fromJson(Map<String, dynamic> json) {
    orderdetailid = json["order_detail_id"].toString();
    productid = json["product_id"].toString();
    itemtype = json["item_type"].toString();
    itemcode = json['item_code'].toString();
    itemname = json['item_name'].toString();
    brandid = json["brand_id"].toString();
    categoryid = json["category_id"].toString();
    quantity = json['needed_quantity'].toString();
    unitid = json['unit_id'].toString();
    unitfactor = json['unit_factor'].toString();
    unitname = json['unit_name'].toString();
    rate = json["rate"].toString();
    currencyid = json["currency_id"].toString();
    exchangerate = json["exchange_rate"].toString();
    taxtype = json["tax_type"].toString();
    taxpercentage = json["tax_percentage"].toString();
    calculatedquantity = json['calculated_quantity'].toString();
    selected = json['selected'].toString();
    voucherdetails = (json['voucher_details'] as List<dynamic>)
        .map((value) => BatchwiseQuantityModel.fromJson(value))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_detail_id'] = orderdetailid;
    data['product_id'] = productid;
    data['item_type'] = itemtype;
    data['item_code'] = itemcode;
    data['item_name'] = itemname;
    data['brand_id'] = brandid;
    data['category_id'] = categoryid;
    data['needed_quantity'] = quantity;
    data['unit_id'] = unitid;
    data['unit_factor'] = unitfactor;
    data['unit_name'] = unitname;
    data['rate'] = rate;
    data['currency_id'] = currencyid;
    data['exchange_rate'] = exchangerate;
    data['tax_type'] = taxtype;
    data['tax_percentage'] = taxpercentage;
    data['calculated_quantity'] = calculatedquantity;
    data['selected'] = selected;
    data['voucher_details'] =
        voucherdetails!.map((value) => value.toJson()).toList();
    return data;
  }
}
