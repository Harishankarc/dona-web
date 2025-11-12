class TaxModeModel {
  int? id;
  String? taxMode;

  TaxModeModel({this.id, this.taxMode});

  TaxModeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taxMode = json['tax_mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['tax_mode'] = taxMode;
    return data;
  }
}
