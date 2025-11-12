import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class RackModel {
  int? id;
  String? name;

  RackModel({this.id, this.name});

  RackModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    id = decoder.getInt('id');
    name = decoder.getString('rack_name');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;

    return data;
  }
}
