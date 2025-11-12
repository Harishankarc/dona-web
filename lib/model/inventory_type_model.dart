import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class InventoryTypeModel {
  int id;
  String name;

  InventoryTypeModel({required this.id, required this.name});

  factory InventoryTypeModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return InventoryTypeModel(
      id: decoder.getInt('id'),
      name: decoder.getString('item_type'),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;

    return data;
  }
}
