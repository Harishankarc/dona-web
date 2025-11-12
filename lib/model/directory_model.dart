import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class DirectoryModel {
  final int id;
  final String name;

  DirectoryModel({
    required this.id,
    required this.name,
  });

  factory DirectoryModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return DirectoryModel(
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

  static List<DirectoryModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => DirectoryModel.fromJson(json)).toList();
  }
}
