class VoucherTypeModel {
  int? id;
  int? code;
  String? description;
  String? prefix;
  String? serialCode;

  VoucherTypeModel({
    this.id,
    this.code,
    this.description,
    this.prefix,
    this.serialCode,
  });

  VoucherTypeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    description = json['description'];
    prefix = json['prefix'];
    serialCode = json['serial_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['description'] = description;
    data['prefix'] = prefix;
    data['serial_code'] = serialCode;

    return data;
  }
}
