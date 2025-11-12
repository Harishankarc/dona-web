class SubledgerModel {
  String? id;
  String? name;
  String? phone;
  String? secondaryPhone;
  String? subledgerType;
  String? userGroupId;
  String? username;
  String? password;
  String? address;
  String? latitude;
  String? longitude;
  String? branchId;
  String? createdBy;
  String? isActive;
  String? branchName;
  String? userGroupName;

  SubledgerModel({
    this.id,
    this.name,
    this.phone,
    this.secondaryPhone,
    this.subledgerType,
    this.userGroupId,
    this.username,
    this.password,
    this.address,
    this.latitude,
    this.longitude,
    this.branchId,
    this.createdBy,
    this.isActive,
    this.branchName,
    this.userGroupName,
  });

  SubledgerModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString() ?? '';
    phone = json['phone']?.toString() ?? '';
    secondaryPhone = json['secondary_phone']?.toString() ?? '';
    subledgerType = json['subledger_type']?.toString();
    userGroupId = json['user_group_id']?.toString();
    username = json['username']?.toString() ?? '';
    password = json['password']?.toString() ?? '';
    address = json['address']?.toString() ?? '';
    latitude = json['latitude']?.toString() ?? '';
    longitude = json['longitude']?.toString() ?? '';
    branchId = json['branch_id']?.toString();
    createdBy = json['created_by']?.toString();
    isActive = json['is_active']?.toString() ?? '';
    branchName = json['branch_name']?.toString() ?? '';
    userGroupName = json['usergroup_name']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['secondary_phone'] = secondaryPhone;
    data['subledger_type'] = subledgerType;
    data['user_group_id'] = userGroupId;
    data['username'] = username;
    data['password'] = password;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['branch_id'] = branchId;
    data['created_by'] = createdBy;
    data['is_active'] = isActive;
    data['branch_name'] = branchName;
    data['usergroup_name'] = userGroupName;
    return data;
  }
}
