class StockAdjustmentModel {
  int? id;
  String? description;
  String? type;
  int? ledgerId;
  String? active;
  String? ledgerAccName;

  StockAdjustmentModel(
      {this.id,
      this.description,
      this.type,
      this.ledgerId,
      this.active,
      this.ledgerAccName});

  StockAdjustmentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    type = json['type'];
    ledgerId = json['ledger_id'];
    active = json['active'];
    ledgerAccName = json['ledger_acc_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['description'] = description;
    data['type'] = type;
    data['ledger_id'] = ledgerId;
    data['active'] = active;
    data['ledger_acc_name'] = ledgerAccName;
    return data;
  }
}
