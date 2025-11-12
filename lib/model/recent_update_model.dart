import 'dart:convert';

import 'package:LeLaundrette/helpers/services/json_decoder.dart';
import 'package:LeLaundrette/model/recent_update_file_model.dart';

class RecentUpdateModel {
  final int id;
  final String projectId;
  final String description;
  final List<RecentUpdateFileModel> files;

  RecentUpdateModel(
      {required this.id,
      required this.projectId,
      required this.description,
      required this.files});

  factory RecentUpdateModel.fromJson(Map<String, dynamic> j) {
    JSONDecoder decoder = JSONDecoder(j);
    return RecentUpdateModel(
        id: decoder.getInt('id'),
        projectId: decoder.getString('projectId'),
        description: decoder.getString('description'),
        files: RecentUpdateFileModel.listFromJson(
            json.decode(j['document_name_list'].toString())));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'description': description,
      'document_name_list': files
          .map(
            (e) => e.toJson(),
          )
          .toList()
    };
  }

  static List<RecentUpdateModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => RecentUpdateModel.fromJson(json)).toList();
  }
}
