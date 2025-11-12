import 'package:LeLaundrette/helpers/services/json_decoder.dart';
import 'package:LeLaundrette/model/taxmaster_model.dart';

class LocationModel {
  final int id;
  final String name;
  final CountryModel country;
  final StateModel state;
  final bool isdefault;

  LocationModel(
      {required this.id,
      required this.name,
      required this.country,
      required this.state,
      this.isdefault = false});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return LocationModel(
        id: decoder.getInt('id'),
        name: decoder.getString('location_name'),
        country: CountryModel(
            id: decoder.getInt('country_id'),
            name: decoder.getString('country_name')),
        state: StateModel.fromJson(json),
        isdefault: decoder.getString('is_default') == 'Y');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  static List<LocationModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => LocationModel.fromJson(json)).toList();
  }
}

class StateModel {
  final int id;
  final String name;
  final CountryModel country;
  final TaxMasterModel taxMaster;

  StateModel(
      {required this.id,
      required this.name,
      required this.country,
      required this.taxMaster});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return StateModel(
        id: decoder.getInt('state_id'),
        name: decoder.getString('state_name'),
        country: CountryModel(
            id: decoder.getInt('country_id'),
            name: decoder.getString('country_name')),
        taxMaster: TaxMasterModel(
            id: decoder.getInt('taxcode_id'),
            taxPercentage: 0,
            taxCode: decoder.getString('tax_code')));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  static List<StateModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => StateModel.fromJson(json)).toList();
  }
}

class CountryModel {
  final int id;
  final String name;
  final bool? isdefault;

  CountryModel({required this.id, required this.name, this.isdefault});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return CountryModel(
        id: decoder.getInt('id'),
        name: decoder.getString('country_name'),
        isdefault: decoder.getString('is_default') == 'Y');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  static List<CountryModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => CountryModel.fromJson(json)).toList();
  }
}
