class CurrencyModel {
  int? id;
  String? currencyCode;
  String? currencyName;
  double? exchangeRate;
  bool? isdefault;

  CurrencyModel(
      {this.id,
      this.currencyCode,
      this.currencyName,
      this.exchangeRate,
      this.isdefault});

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currencyCode = json['currency_code'];
    currencyName = json['currency_name'];
    exchangeRate = double.parse(json['exchange_rate'].toString());
    isdefault = json['is_default'].toString() == 'Y';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['currency_code'] = currencyCode;
    data['exchange_rate'] = exchangeRate;
    return data;
  }
}
