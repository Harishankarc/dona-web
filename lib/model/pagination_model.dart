import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class PaginationModel<T> {
  final int totalPages;
  final List<T> data;

  PaginationModel({required this.totalPages, required this.data});

  factory PaginationModel.fromJson(
      Map<String, dynamic> j, T Function(Map<String, dynamic> json) fromJson) {
    JSONDecoder decoder = JSONDecoder(j);
    return PaginationModel(
      totalPages: decoder.getInt('totalPages'),
      data: (decoder.getMapListOrNull('data') ?? [])
          .map(
            (e) => fromJson(e),
          )
          .toList(),
    );
  }

  static List<PaginationModel> listFromJson<T>(
      List<dynamic> jsonList, T Function(Map<String, dynamic> json) fromJson) {
    return jsonList
        .map((json) => PaginationModel.fromJson(json, fromJson))
        .toList();
  }
}
