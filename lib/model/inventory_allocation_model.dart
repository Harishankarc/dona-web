import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class InventoryAllocationModel {
  final int id;
  final String reference;
  final int productId;
  final String productName;
  final String batch;
  final int quantity;
  final int unitFactor;
  final int unitId;
  final String unitName;
  final int totalQuantity;
  final int branchId;
  final String branchName;
  final int warehosueId;
  final String warehouseName;
  final bool isActive;

  InventoryAllocationModel({
    required this.id,
    required this.reference,
    required this.productId,
    required this.productName,
    required this.batch,
    required this.quantity,
    required this.unitFactor,
    required this.unitId,
    required this.unitName,
    required this.totalQuantity,
    required this.branchId,
    required this.branchName,
    required this.warehosueId,
    required this.warehouseName,
    required this.isActive,
  });

  factory InventoryAllocationModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);
    return InventoryAllocationModel(
        id: decoder.getInt('id'),
        reference: decoder.getString('reference'),
        productId: decoder.getInt('product_id'),
        productName: decoder.getString('item_name'),
        batch: decoder.getString('batch_id'),
        quantity: decoder.getInt('quantity'),
        unitFactor: decoder.getInt('unit_factor'),
        unitId: decoder.getInt('unit_id'),
        unitName: decoder.getString('unit_name'),
        totalQuantity: decoder.getInt('total_quantity'),
        branchId: decoder.getInt('branch_id'),
        branchName: decoder.getString('branch'),
        warehosueId: decoder.getInt('warehouse_id'),
        warehouseName: decoder.getString('warehouse'),
        isActive: decoder.getString('is_active') == 'Y');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'product_id': productId,
      'item_name': productName,
      'batch_id': batch,
      'quantity': quantity,
      'unit_id': unitId,
      'unit_name': unitName,
      'total_quantity': totalQuantity,
      'branch_id': branchId,
      'branch': branchName,
      'warehouse_id': warehosueId,
      'warehouse': warehouseName,
      'is_active': isActive ? 'Y' : 'N',
    };
  }

  static List<InventoryAllocationModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => InventoryAllocationModel.fromJson(json))
        .toList();
  }
}
