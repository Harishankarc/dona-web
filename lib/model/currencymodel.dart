class CurrencyModel {
  int? id;
  String? currencyCode;
  String? currency;
  double? exchangeRate;
  bool? isdefault;

  CurrencyModel(
      {this.id,
      this.currencyCode,
      this.currency,
      this.exchangeRate,
      this.isdefault});

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currencyCode = json['currency'];
    currency = json['currency'];
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
