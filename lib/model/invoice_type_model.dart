class InvoiceTypeModel {
  int? id;
  String? invoiceTypeName;

  InvoiceTypeModel({this.id, this.invoiceTypeName});

  InvoiceTypeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceTypeName = json['invoice_type_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['invoice_type_name'] = invoiceTypeName;
    return data;
  }
}
