class UnitModel {
  String? id;
  String? unitName;
  String? unitSymbol;
  String? unitFactor;

  UnitModel({this.id, this.unitName, this.unitSymbol, this.unitFactor});

  UnitModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    unitName = json['unit_name'].toString();
    unitSymbol = json['unit_symbol'].toString();
    unitFactor = json['unit_factor'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['unit_name'] = unitName;
    data['unit_symbol'] = unitSymbol;
    data['unit_factor'] = unitFactor;
    return data;
  }
}
