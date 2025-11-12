class DocumentModel {
  int id;
  int subledgerId;
  int documentTypeId;
  String documentReference;
  DateTime dateOfValidity;
  DateTime reminderDate;
  String attachment;
  int createdBy;
  DateTime createdDatetime;
  bool isActive;
  bool isExpired;
  String documentTypeName;

  DocumentModel({
    required this.id,
    required this.subledgerId,
    required this.documentTypeId,
    required this.documentReference,
    required this.dateOfValidity,
    required this.reminderDate,
    required this.attachment,
    required this.createdBy,
    required this.createdDatetime,
    required this.isActive,
    required this.isExpired,
    required this.documentTypeName,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      subledgerId: json['subledger_id'],
      documentTypeId: json['document_type_id'],
      documentReference: json['document_referrence'],
      dateOfValidity: DateTime.parse(json['date_of_validity']),
      reminderDate: DateTime.parse(json['reminder_date']),
      attachment: json['attachment'],
      createdBy: json['created_by'],
      createdDatetime: DateTime.parse(json['created_datetime']),
      isActive: json['is_active'] == 'Y',
      isExpired: json['is_expired'] == 'Y',
      documentTypeName: json['document_type_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subledger_id': subledgerId,
      'document_type_id': documentTypeId,
      'document_referrence': documentReference,
      'date_of_validity': dateOfValidity.toIso8601String(),
      'reminder_date': reminderDate.toIso8601String(),
      'attachment': attachment,
      'created_by': createdBy,
      'created_datetime': createdDatetime.toIso8601String(),
      'is_active': isActive.toString(),
      'is_expired': isExpired.toString(),
      'document_type_name': documentTypeName,
    };
  }
}
