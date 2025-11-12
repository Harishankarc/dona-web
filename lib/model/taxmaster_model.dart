import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class TaxMasterModel {
  final int id;
  final String taxCode;
  final double taxPercentage;
  final bool? isdefault;

  TaxMasterModel(
      {required this.id,
      required this.taxCode,
      required this.taxPercentage,
      this.isdefault});

  factory TaxMasterModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return TaxMasterModel(
        id: decoder.getInt('id'),
        taxCode: decoder.getString('tax_code'),
        taxPercentage: decoder.getDouble('tax_percentage'),
        isdefault: decoder.getString('is_default') == 'Y');
  }
  factory TaxMasterModel.dummy() {
    return TaxMasterModel(
        id: 0, taxCode: "", taxPercentage: 0, isdefault: false);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': taxCode,
    };
  }

  static List<TaxMasterModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => TaxMasterModel.fromJson(json)).toList();
  }
}
