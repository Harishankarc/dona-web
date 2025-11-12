class BranchByUserModel {
  String? id;
  String? branch;
  String? address;
  String? warehouse;
  String? footer;

  BranchByUserModel({
    this.id,
    this.branch,
    this.address,
    this.warehouse,
    this.footer,
  });

  BranchByUserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    branch = json['name'];
    address = json['address'];
    warehouse = json['warehouse'];
    footer = json['footer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['branch'] = branch;
    data['address'] = address;
    data['warehouse'] = warehouse;
    data['footer'] = footer;
    return data;
  }
}
