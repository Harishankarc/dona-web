class SubledgerByBranchModel {
  String? id;
  String? name;
  String? phone;
  String? mobile;
  String? usergroupName;

  SubledgerByBranchModel(
      {this.id, this.name, this.phone, this.mobile, this.usergroupName});

  SubledgerByBranchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    phone = json['phone'].toString();
    mobile = json['mobile'].toString();
    usergroupName = json['usergroup_name'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['mobile'] = mobile;
    data['usergroup_name'] = usergroupName;
    return data;
  }
}
