import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class WareHouseModel {
  int? id;
  String? name;
  bool? isdefault;
  WareHouseModel({this.id, this.name, this.isdefault});

  WareHouseModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    id = decoder.getInt('id');
    name = decoder.getString('name');
    isdefault = decoder.getString('is_default') == 'Y';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;

    return data;
  }
}
