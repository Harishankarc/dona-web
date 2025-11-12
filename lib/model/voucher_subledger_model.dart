class VoucherSubledgerModel {
  int? id;
  String? name;
  int? subledgerType;
  String? phone;
  String? mobile;
  String? email;
  String? address;
  int? attributeId;
  int? ledgerId;
  String? valueType;

  VoucherSubledgerModel(
      {this.id,
      this.name,
      this.subledgerType,
      this.phone,
      this.mobile,
      this.email,
      this.address,
      this.attributeId,
      this.ledgerId,
      this.valueType});

  VoucherSubledgerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    subledgerType = json['subledger_type'];
    phone = json['phone'];
    mobile = json['mobile'];
    email = json['email'];
    address = json['address'];
    attributeId = json['attribute_id'];
    ledgerId = json['ledger_id'];
    valueType = json['value_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['subledger_type'] = subledgerType;
    data['phone'] = phone;
    data['mobile'] = mobile;
    data['email'] = email;
    data['address'] = address;
    data['attribute_id'] = attributeId;
    data['ledger_id'] = ledgerId;
    data['value_type'] = valueType;
    return data;
  }
}
