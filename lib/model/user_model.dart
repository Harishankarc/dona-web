import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class UserModel {
  final int id;
  final String name;
  final Map<String, dynamic> data;

  UserModel({required this.id, required this.name, required this.data});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return UserModel(
        id: decoder.getInt('id'),
        name: decoder.getString('name'),
        data: decoder.jsonObject);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  static List<UserModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => UserModel.fromJson(json)).toList();
  }
}
