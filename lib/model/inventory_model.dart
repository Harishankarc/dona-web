class InventoryModel {
  String? id;
  String? itemCode;
  String? itemName;
  String? unitId;
  String? unitName;
  String? unitSymbol;
  String? unitFactor;
  String? price;
  String? branchId;
  String? branchName;

  InventoryModel(
      {this.id,
      this.itemCode,
      this.itemName,
      this.unitId,
      this.unitName,
      this.unitSymbol,
      this.unitFactor,
      this.price,
      this.branchId,
      this.branchName});

  InventoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    itemCode = json['item_code'].toString();
    itemName = json['item_name'].toString();
    unitId = json['unit_id'].toString();
    unitName = json['unit_name'].toString();
    unitSymbol = json['unit_symbol'].toString();
    unitFactor = json['unit_factor'].toString();
    price = json['price'].toString();
    branchId = json['branch_id'].toString();
    branchName = json['branch_name'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_code'] = itemCode;
    data['item_name'] = itemName;
    data['unit_id'] = unitId;
    data['unit_name'] = unitName;
    data['unit_symbol'] = unitSymbol;
    data['unit_factor'] = unitFactor;
    data['price'] = price;
    data['branch_id'] = branchId;
    data['branch_name'] = branchName;
    return data;
  }
}
