import 'package:LeLaundrette/helpers/services/json_decoder.dart';
import 'package:LeLaundrette/model/unitmaster_model.dart';

class ProductUOMModel {
  int id;
  int productId;
  UnitMasterModel unit;
  double factor;
  double price;
  bool isBase;

  ProductUOMModel({
    required this.id,
    required this.productId,
    required this.unit,
    required this.factor,
    required this.price,
    required this.isBase,
  });

  factory ProductUOMModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return ProductUOMModel(
        id: decoder.getInt('id'),
        productId: decoder.getInt('product_id'),
        unit: UnitMasterModel(
            id: decoder.getInt('unit_id'),
            name: decoder.getString('unit_name'),
            symbol: decoder.getString('unit_symbol')),
        factor: decoder.getDouble('factor'),
        price: decoder.getDouble('price'),
        isBase: decoder.getString('is_base') == 'Y');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = unit.name;

    return data;
  }
}
