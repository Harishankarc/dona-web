
import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class VehicleModelTypeModel {
  String id;
  String name;

  VehicleModelTypeModel({
    required this.id,
    required this.name,
  });

  factory VehicleModelTypeModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    return VehicleModelTypeModel(
      id: decoder.getString('id'),
      name: decoder.getString('name'),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;

    return data;
  }
}
