class MISModel {
  String? day;
  String? totalAmount;
  String? totalNet;
  String? totalVat;

  MISModel({this.day, this.totalAmount, this.totalNet, this.totalVat});

  MISModel.fromJson(Map<String, dynamic> json) {
    day = json['day'].toString();
    totalAmount = json['totalAmount'].toString();
    totalNet = json['totalNet'].toString();
    totalVat = json['totalVat'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['day'] = day;
    data['totalAmount'] = totalAmount;
    data['totalNet'] = totalNet;
    data['totalVat'] = totalVat;
    return data;
  }
}
