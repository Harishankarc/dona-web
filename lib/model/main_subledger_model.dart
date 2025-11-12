class MainSubLedgerModel {
  String? id;
  String? name;

  MainSubLedgerModel({this.id, this.name});

  MainSubLedgerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
