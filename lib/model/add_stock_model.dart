class AddStockModel {
  String? productId;
  String? itemType;
  String? itemCode;
  String? itemName;
  String? brandId;
  String? categoryId;
  String? quantity;
  String? cost;
  String? updatedCost;
  String? unitId;
  String? unitName;
  String? unitSymbol;
  String? factor;

  AddStockModel(
      {this.productId,
      this.itemType,
      this.itemCode,
      this.itemName,
      this.brandId,
      this.categoryId,
      this.quantity,
      this.cost,
      this.updatedCost,
      this.unitId,
      this.unitName,
      this.unitSymbol,
      this.factor});

  AddStockModel.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    itemType = json['item_type'];
    itemCode = json['item_code'];
    itemName = json['item_name'];
    brandId = json['brand_id'];
    categoryId = json['category_id'];
    quantity = json['quantity'];
    cost = json['cost'];
    updatedCost = json['updated_cost'];
    unitId = json['unit_id'];
    unitName = json['unit_name'];
    unitSymbol = json['unit_symbol'];
    factor = json['factor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['item_type'] = itemType;
    data['item_code'] = itemCode;
    data['item_name'] = itemName;
    data['brand_id'] = brandId;
    data['category_id'] = categoryId;
    data['quantity'] = quantity;
    data['cost'] = cost;
    data['updated_cost'] = updatedCost;
    data['unit_id'] = unitId;
    data['unit_name'] = unitName;
    data['unit_symbol'] = unitSymbol;
    data['factor'] = factor;
    return data;
  }
}
