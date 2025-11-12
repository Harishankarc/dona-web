import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class UnitMasterModel {
  int id;
  String name;
  String symbol;

  UnitMasterModel({required this.id, required this.name, required this.symbol});

  factory UnitMasterModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return UnitMasterModel(
      id: decoder.getInt('id'),
      name: decoder.getString('unit_name'),
      symbol: decoder.getString('unit_symbol'),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;

    return data;
  }
}
