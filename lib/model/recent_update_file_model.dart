import 'package:LeLaundrette/helpers/services/json_decoder.dart';
import 'package:file_picker/file_picker.dart';

class RecentUpdateFileModel {
  final int id;
  final String comment;
  final PlatformFile file;

  RecentUpdateFileModel(
      {required this.id, required this.comment, required this.file});

  factory RecentUpdateFileModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return RecentUpdateFileModel(
        id: decoder.getInt('id'),
        comment: decoder.getString('comment'),
        file: PlatformFile(name: decoder.getString('name'), size: 0));
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': file.name, 'comment': comment};
  }

  static List<RecentUpdateFileModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => RecentUpdateFileModel.fromJson(json))
        .toList();
  }
}
