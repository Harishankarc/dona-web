class SelectedItemModel {
  String? productId;
  String? itemType;
  String? itemCode;
  String? itemName;
  String? brandId;
  String? categoryId;
  String? quantity;
  String? unitName;
  String? unitId;
  String? unitFactor;
  String? rate;
  String? currencyId;
  String? exchangeRate;
  String? taxType;
  String? taxPercentage;
  String? amount;
  String? tax;
  String? netAmount;
  String? discountPercent;
  String? discountAmount;
  String? rackId;
  String? binId;
  String? batchId;
  String? serialNumber;
  String? expiryDate;
  String? mfDate;
  String? isFoc;

  SelectedItemModel(
      {this.productId,
      this.itemType,
      this.itemCode,
      this.itemName,
      this.brandId,
      this.categoryId,
      this.quantity,
      this.unitName,
      this.unitId,
      this.unitFactor,
      this.rate,
      this.currencyId,
      this.exchangeRate,
      this.taxType,
      this.taxPercentage,
      this.amount,
      this.tax,
      this.netAmount,
      this.discountPercent,
      this.discountAmount,
      this.rackId,
      this.binId,
      this.batchId,
      this.serialNumber,
      this.expiryDate,
      this.mfDate,
      this.isFoc});

  SelectedItemModel.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    itemType = json['item_type'];
    itemCode = json['item_code'];
    itemName = json['item_name'];
    brandId = json['brand_id'];
    categoryId = json['category_id'];
    quantity = json['quantity'];
    unitName = json['unit_name'];
    unitId = json['unit_id'];
    unitFactor = json['unit_factor'];
    rate = json['rate'];
    currencyId = json['currency_id'];
    exchangeRate = json['exchange_rate'];
    taxType = json['tax_type'];
    taxPercentage = json['tax_percentage'];
    amount = json['amount'];
    tax = json['tax'];
    netAmount = json['net_amount'];
    discountPercent = json['discount_percent'];
    discountAmount = json['discount_amount'];
    rackId = json['rack_id'];
    binId = json['bin_id'];
    batchId = json['batch_id'];
    serialNumber = json['serial_number'];
    expiryDate = json['expiry_date'];
    mfDate = json['mf_date'];
    isFoc = json['is_foc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['product_id'] = productId;
    data['item_type'] = itemType;
    data['item_code'] = itemCode;
    data['item_name'] = itemName;
    data['brand_id'] = brandId;
    data['category_id'] = categoryId;
    data['quantity'] = quantity;
    data['unit_name'] = unitName;
    data['unit_id'] = unitId;
    data['unit_factor'] = unitFactor;
    data['rate'] = rate;
    data['currency_id'] = currencyId;
    data['exchange_rate'] = exchangeRate;
    data['tax_type'] = taxType;
    data['tax_percentage'] = taxPercentage;
    data['amount'] = amount;
    data['tax'] = tax;
    data['net_amount'] = netAmount;
    data['discount_percent'] = discountPercent;
    data['discount_amount'] = discountAmount;
    data['rack_id'] = rackId;
    data['bin_id'] = binId;
    data['batch_id'] = batchId;
    data['serial_number'] = serialNumber;
    data['expiry_date'] = expiryDate;
    data['mf_date'] = mfDate;
    data['is_foc'] = isFoc;
    return data;
  }
}
