import 'dart:convert';

class UserGroupModel {
  int? id;
  String? groupname;
  Map<String, bool>? permissions;

  UserGroupModel({this.id, this.groupname, this.permissions});

  UserGroupModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    groupname = json['usergroup_name'];
    permissions = json['permission'] != null
        ? Map<String, bool>.from(jsonDecode(json['permission'].toString()))
        : {};
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['usergroup_name'] = groupname;
    return data;
  }
}
