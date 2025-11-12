import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class RecentUpdateCommentModel {
  final int id;
  final int userid;
  final int recentId;
  final String name;
  final String message;
  final DateTime date;
  RecentUpdateCommentModel(
      {required this.id,
      required this.userid,
      required this.recentId,
      required this.name,
      required this.message,
      required this.date});

  factory RecentUpdateCommentModel.fromJson(Map<String, dynamic> j) {
    JSONDecoder decoder = JSONDecoder(j);
    return RecentUpdateCommentModel(
        id: decoder.getInt('id'),
        userid: decoder.getInt('user_id'),
        recentId: decoder.getInt('recent_id'),
        name: decoder.getString('user_name'),
        message: decoder.getString('comment'),
        date: DateTime.parse(decoder.getString('created_datetime').toString()));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': id,
      'recent_id': recentId,
      'username': name,
      'comment': message
    };
  }

  static List<RecentUpdateCommentModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => RecentUpdateCommentModel.fromJson(json))
        .toList();
  }
}
