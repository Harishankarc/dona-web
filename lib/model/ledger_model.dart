import 'package:LeLaundrette/helpers/services/json_decoder.dart';

class LedgerModel {
  final int id;
  final String accNo;
  final String accName;
  final int accTypeId;
  final String accMain;
  final int accParentId;
  final int root;
  final int level;
  final bool isParent;
  final String parentLedgerName;
  final bool haveSubledger;
  final int subledgerTypes;
  final bool systemGenerated;
  final bool isEditable;

  LedgerModel({
    required this.id,
    required this.accNo,
    required this.accName,
    required this.accTypeId,
    required this.accMain,
    required this.accParentId,
    required this.root,
    required this.level,
    required this.isParent,
    required this.parentLedgerName,
    required this.haveSubledger,
    required this.subledgerTypes,
    required this.systemGenerated,
    required this.isEditable,
  });

  factory LedgerModel.fromJson(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    return LedgerModel(
      id: decoder.getInt('id'),
      accNo: decoder.getString('ledger_acc_no'),
      accName: decoder.getString('ledger_acc_name'),
      accTypeId: decoder.getInt('ledger_acc_type'),
      accMain: decoder.getString('ledger_acc_main'),
      accParentId: decoder.getInt('ledger_parent_acc'),
      root: decoder.getInt('root'),
      level: decoder.getInt('level'),
      isParent: decoder.getString('is_parent') == 'Y',
      parentLedgerName: decoder.getString('parent_ledger_name'),
      haveSubledger: decoder.getString('have_subledger') == 'Y',
      subledgerTypes: decoder.getInt('subledger_types'),
      systemGenerated: decoder.getString('system_generated') == 'Y',
      isEditable: decoder.getString('is_editable') == 'Y',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'acc_no': accNo,
      'acc_name': accName,
      'acc_type_id': accTypeId,
      'acc_main': accMain,
      'acc_parent_id': accParentId,
      'root': root,
      'level': level,
      'is_parent': isParent,
      'parent_ledger_name': parentLedgerName,
      'have_subledger': haveSubledger,
      'subledger_types': subledgerTypes,
      'system_generated': systemGenerated,
      'is_editable': isEditable,
    };
  }

  static List<LedgerModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => LedgerModel.fromJson(json)).toList();
  }
}
