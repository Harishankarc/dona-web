import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class AttributeModel {
  final int id;
  final String attribute;
  final String description;
  final int ledgerId;

  AttributeModel({
    required this.id,
    required this.attribute,
    required this.description,
    required this.ledgerId,
  });

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    return AttributeModel(
      id: decoder.getInt('id'),
      attribute: decoder.getString('attribute'),
      description: decoder.getString('description'),
      ledgerId: decoder.getInt('ledger_id'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attribute': attribute,
      'description': description,
      'ledger_id': ledgerId
    };
  }

  static List<AttributeModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => AttributeModel.fromJson(json)).toList();
  }
}
