class UserModel {
  String? id;
  String? name;
  String? groupname;
  String? groupid;

  UserModel({this.id, this.name});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    groupname = json['group_name'].toString();
    groupid = json['user_group_id'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
