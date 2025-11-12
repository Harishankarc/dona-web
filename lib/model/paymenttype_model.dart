

import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class PaymentTypeModel {
  String id;
  String name;

  PaymentTypeModel({
    required this.id,
    required this.name,
  });

  factory PaymentTypeModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    return PaymentTypeModel(
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