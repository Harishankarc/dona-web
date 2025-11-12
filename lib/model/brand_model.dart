import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class BrandModel {
  int id;
  String name;
  bool isdefault;

  BrandModel({required this.id, required this.name, required this.isdefault});

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return BrandModel(
        id: decoder.getInt('id'),
        name: decoder.getString('brand_name'),
        isdefault: decoder.getString('is_default') == 'Y');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;

    return data;
  }
}
