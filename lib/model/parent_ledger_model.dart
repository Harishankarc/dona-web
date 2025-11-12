class ParentLedgerModel {
  int? id;
  String? ledgerAccNo;
  String? ledgerAccName;
  String? root;

  ParentLedgerModel({this.id, this.ledgerAccNo, this.ledgerAccName, this.root});

  ParentLedgerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ledgerAccNo = json['ledger_acc_no'];
    ledgerAccName = json['ledger_acc_name'];
    root = json['root'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['ledger_acc_no'] = ledgerAccNo;
    data['ledger_acc_name'] = ledgerAccName;
    data['root'] = root;
    return data;
  }
}
