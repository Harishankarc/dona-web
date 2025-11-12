import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class StatusModel {
  final int id;
  final String name;

  StatusModel({
    required this.id,
    required this.name,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return StatusModel(
      id: decoder.getInt('id'),
      name: decoder.getString('name'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  static List<StatusModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => StatusModel.fromJson(json)).toList();
  }
}
