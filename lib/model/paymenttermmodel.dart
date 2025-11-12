class PaymentTermModel {
  int? id;
  String? paymentTerm;

  PaymentTermModel({this.id, this.paymentTerm});

  PaymentTermModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paymentTerm = json['payment_term'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['payment_term'] = paymentTerm;
    return data;
  }
}
