class StockIssueBatchwiseQuantityModel {
  String? id;
  String? fileId;
  String? voucherType;
  String? batchId;
  String? productId;
  String? itemCode;
  String? itemName;
  String? quantity;
  String? availableQuantity;
  String? unitId;
  String? unitName;
  String? unitFactor;
  String? cost;
  num? neededQuantity;
  int? selected;

  StockIssueBatchwiseQuantityModel(
      {required this.id,
      this.fileId,
      this.voucherType,
      this.batchId,
      this.productId,
      this.itemCode,
      this.itemName,
      this.quantity,
      this.availableQuantity,
      this.unitId,
      this.unitName,
      this.unitFactor,
      this.cost,
      this.neededQuantity,
      this.selected});

  StockIssueBatchwiseQuantityModel.fromJson(Map<String, dynamic> json) {
    id = json["id"].toString();
    fileId = json['file_id'].toString();
    voucherType = json['voucher_type'].toString();
    batchId = json['batch_id'].toString();
    productId = json['product_id'].toString();
    itemCode = json['item_code'].toString();
    itemName = json['item_name'].toString();
    quantity = json['quantity'].toString();
    availableQuantity = json['current_available_quantity'].toString();
    unitId = json['unit_id'].toString();
    unitName = json['unit_name'].toString();
    unitFactor = json['unit_factor'].toString();
    cost = json['cost'].toString();
    neededQuantity = json['needed_quantity'];
    selected = json['selected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['file_id'] = fileId;
    data['voucher_type'] = voucherType;
    data['batch_id'] = batchId;
    data['product_id'] = productId;
    data['item_code'] = itemCode;
    data['item_name'] = itemName;
    data['quantity'] = quantity;
    data['available_quantity'] = availableQuantity;
    data['unit_id'] = unitId;
    data['unit_name'] = unitName;
    data['unit_factor'] = unitFactor;
    data['cost'] = cost;
    data['needed_quantity'] = neededQuantity;
    data['selected'] = selected;
    return data;
  }
}
