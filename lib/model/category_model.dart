import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class CategoryModel {
  int id;
  String name;
  bool isdefault;

  CategoryModel(
      {required this.id, required this.name, required this.isdefault});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return CategoryModel(
        id: decoder.getInt('id'),
        name: decoder.getString('category_name'),
        isdefault: decoder.getString('is_default') == 'Y');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;

    return data;
  }
}
