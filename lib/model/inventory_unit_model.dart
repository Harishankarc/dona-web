class InventoryUnitModel {
  int? id;
  int? productId;
  int? unitId;
  String? unitName;
  String? unitSymbol;
  num? factor;
  double? price;
  String? isbase;

  InventoryUnitModel({
    this.id,
    this.productId,
    this.unitId,
    this.unitName,
    this.unitSymbol,
    this.factor,
    this.price,
    this.isbase,
  });

  InventoryUnitModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    unitId = json['unit_id'];
    unitName = json['unit_name'];
    unitSymbol = json['unit_symbol'];
    factor = json['factor'];
    price = double.parse(json['price'].toString());
    isbase = json['is_base'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['unit_id'] = unitId;
    data['unit_name'] = unitName;
    data['unit_symbol'] = unitSymbol;
    data['factor'] = factor;
    data['price'] = price;
    data['isbase'] = isbase;
    return data;
  }
}
