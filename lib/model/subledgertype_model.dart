import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class SubledgerTypeModel {
  final int id;
  final String subledgerTypeName;

  SubledgerTypeModel({
    required this.id,
    required this.subledgerTypeName,
  });

  factory SubledgerTypeModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    return SubledgerTypeModel(
      id: decoder.getInt('id'),
      subledgerTypeName: decoder.getString('name'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': subledgerTypeName,
    };
  }

  static List<SubledgerTypeModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => SubledgerTypeModel.fromJson(json)).toList();
  }
}
