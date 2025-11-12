class MainLedgerModel {
  String? id;
  String? ledgerAccName;

  MainLedgerModel({
    this.id,
    this.ledgerAccName,
  });

  MainLedgerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    ledgerAccName = json['ledger_acc_name'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ledger_acc_name'] = ledgerAccName;
    return data;
  }
}
