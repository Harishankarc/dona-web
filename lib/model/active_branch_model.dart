class ActiveBranchModel {
  String? id;
  String? branch;

  ActiveBranchModel({
    this.id,
    this.branch,
  });

  ActiveBranchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    branch = json['branch'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['branch'] = branch;
    return data;
  }
}
