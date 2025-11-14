import 'package:LeLaundrette/controller/dashboard/daybook/daybook_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/helpers/theme/app_theme.dart';
import 'package:LeLaundrette/helpers/utils/mixins/ui_mixin.dart';
import 'package:LeLaundrette/helpers/utils/my_shadow.dart';
import 'package:LeLaundrette/helpers/widgets/my_breadcrumb.dart';
import 'package:LeLaundrette/helpers/widgets/my_breadcrumb_item.dart';
import 'package:LeLaundrette/helpers/widgets/my_button.dart';
import 'package:LeLaundrette/helpers/widgets/my_card.dart';
import 'package:LeLaundrette/helpers/widgets/my_container.dart';
import 'package:LeLaundrette/helpers/widgets/my_flex.dart';
import 'package:LeLaundrette/helpers/widgets/my_flex_item.dart';
import 'package:LeLaundrette/helpers/widgets/my_spacing.dart';
import 'package:LeLaundrette/helpers/widgets/my_text.dart';
import 'package:LeLaundrette/view/layouts/delete_view.dart';
import 'package:LeLaundrette/view/layouts/layout.dart';
import 'package:LeLaundrette/view/ui/input_output_utils.dart';
import 'package:LeLaundrette/view/ui/toast_message_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DayBookListScreen extends StatefulWidget {
  const DayBookListScreen({
    super.key,
  });

  @override
  State<DayBookListScreen> createState() => _DayBookListScreenState();
}

class _DayBookListScreenState extends State<DayBookListScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late DaybookListController controller = Get.put(DaybookListController());
  late OutlineInputBorder _outlineInputBorder;
  late ToastMessageController toastcontroller;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _outlineInputBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      );
      toastcontroller = ToastMessageController(this);
    });
    super.initState();
    controller.loadData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
          init: controller,
          tag: 'daybook_list_controller',
          builder: (controller) {
            return controller.loading
                ? MyFlex(
                    children: [
                      MyFlexItem(
                        sizes: 'lg-12',
                        child: MyCard(
                          height: MediaQuery.of(context).size.height,
                          child: LoadingAnimationWidget.dotsTriangle(
                              color: contentTheme.primary, size: 40),
                        ),
                      ),
                    ],
                  )
                : Column(children: [
                    Padding(
                      padding: MySpacing.x(flexSpacing),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const MyText.titleMedium(
                            "Vouchers",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Dashboard'),
                              MyBreadcrumbItem(name: 'Vouchers'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    MySpacing.height(flexSpacing),
                    Padding(
                        padding: MySpacing.x(flexSpacing), child: buildList()),
                  ]);
          }),
    );
  }

  Widget buildList() {
    return LayoutBuilder(builder: (context, constrains) {
      return MyCard(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
        borderRadiusAll: 8,
        padding: MySpacing.xy(23, 5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MySpacing.height(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IOUtils.dateField(
                          "",
                          "Start Date",
                          context,
                          controller.setStartDate,
                          APIService.formatDate,
                          controller.startDate,
                          emptyOption: true),
                      MySpacing.width(10),
                      IOUtils.dateField(
                          "",
                          "End Date",
                          context,
                          controller.setEndDate,
                          APIService.formatDate,
                          controller.endDate,
                          emptyOption: true),
                      MySpacing.width(10),
                    ],
                  ),
                ],
              ),
              MySpacing.height(8),
              IOUtils.dataTable<dynamic>(
                [
                  "Voucher ID",
                  "Voucher Date",
                  "Total Hours",
                  "Total Amount",
                  "Total Shifting Charge",
                  "Total Salary",
                  "Total Bata",
                  "Net Total",
                  "Created by"
                ],
                [
                  (value) => value['file_id'].toString(),
                  (value) => APIService.formatDate(APIService.stringToDate(
                      value['voucher_date'].toString())),
                  (value) => value['total_hour'].toString(),
                  (value) => value['total_amount'].toString(),
                  (value) => value['total_shifting_charge'].toString(),
                  (value) => value['total_driver_salary'].toString(),
                  (value) => value['total_driver_bata'].toString(),
                  (value) => value['net_amount'].toString(),
                  (value) => value['created_by_name'].toString(),
                ],
                controller.data,
                context,
                isaction: true,
                actionwidth: 180,
                actionList: [
                  TableAction(
                    permission: '',
                    function: (data) async {
                      controller.setLoading(true);
                      await controller.getVoucherById(data['file_id'].toString());
                      controller.setLoading(false);
                      if(controller.voucherData.isEmpty){
                        toastMessage(
                            "No voucher data found", contentTheme.danger);
                        return;
                      }
                      viewVoucher(controller.voucherData);

                    },
                    iconData: IOUtils.viewIcon,
                    color: contentTheme.success,
                  ),
                  TableAction(
                      permission: 'rentals_rentals_edit',
                      function: (data) async {},
                      iconData: IOUtils.editIcon,
                      color: contentTheme.warning),
                  TableAction(
                      permission: 'rentals_rentals_delete',
                      function: (data) async {},
                      iconData: IOUtils.deleteIcon,
                      color: contentTheme.danger),
                ],
              ),
              MySpacing.height(10),
            ],
          ),
        ),
      );
    });
  }

  void viewVoucher(dynamic data) {
    showGeneralDialog(
        barrierColor: Colors.transparent,
        context: context,
        pageBuilder: (a, b, c) {
          return GetBuilder(
              init: controller,
              builder: (controller) {
                return Dialog(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                  child: controller.loading
                      ? SizedBox(
                          width: 400,
                          height: 300,
                          child: LoadingAnimationWidget.dotsTriangle(
                              color: contentTheme.primary, size: 40),
                        )
                      : SizedBox(
                          width: 1500,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: MyText.labelLarge(
                                  'Voucher ID  ${data[0]['file_id'].toString()}',
                                  fontWeight: 600,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                  padding: MySpacing.xy(0, 0),
                                  child: MyContainer(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      addDayBookHeader(),
                                      MySpacing.height(5),
                                      buildMainTables(data),
                                      MySpacing.height(5),
                                      buildFooter(data),
                                      MySpacing.height(10),
                                    ]
                                  ))),
                              Padding(
                                padding: MySpacing.only(right: 20, bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    MyButton(
                                      onPressed: () => Get.back(),
                                      elevation: 0,
                                      borderRadiusAll: 8,
                                      padding: MySpacing.xy(20, 16),
                                      backgroundColor:
                                          colorScheme.secondaryContainer,
                                      child: MyText.labelMedium(
                                        "Close",
                                        fontWeight: 600,
                                        color: colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                    MySpacing.width(16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              });
        });
  }

  final List<double> columnWidths = [
    60, // Id
    120, // Vehicle Name
    120, // Driver Name
    120, // Customer Name
    1, // Site/Location (flex)
    1, // Hour/Time Work (flex)
    1, // Rate (flex)
    1, // Amount (flex)
    1, // Shift Charge (flex)
    1, // Driver Salary (flex)
    1, // Bata (flex)
    1, // Payment Type (flex)
    1, // Status (flex)
    60, // Add Button
  ];

  Widget addDayBookHeader() {
    return MyContainer.bordered(
      width: double.infinity,
      borderRadiusAll: 3,
      height: 35,
      borderColor: contentTheme.textBorder,
      paddingAll: 0,
      child: Row(
        children: [
          _headerCell("Id", width: columnWidths[0]),
          _divider(),
          _headerCell("Vehicle", width: columnWidths[1]),
          _divider(),
          _headerCell("Driver", width: columnWidths[2]),
          _divider(),
          _headerCell("Customer", width: columnWidths[3]),
          _divider(),
          _headerCell("Site", flex: columnWidths[4].toInt()),
          _divider(),
          _headerCell("Hour", flex: columnWidths[5].toInt()),
          _divider(),
          _headerCell("Rate", flex: columnWidths[6].toInt()),
          _divider(),
          _headerCell("Amount", flex: columnWidths[7].toInt()),
          _divider(),
          _headerCell("Shf Charge", flex: columnWidths[8].toInt()),
          _divider(),
          _headerCell("Dvr Salary", flex: columnWidths[9].toInt()),
          _divider(),
          _headerCell("Bata", flex: columnWidths[10].toInt()),
          _divider(),
          _headerCell("Pay Type", flex: columnWidths[11].toInt()),
          _divider(),
          _headerCell("Status", flex: columnWidths[12].toInt()),
        ],
      ),
    );
  }

 Widget   buildFooter(dynamic voucherData) {
    Map<String, double> totals = {
      'total_hour': 0.0,
      'total_amount': 0.0,
      'total_shifting_charge': 0.0,
      'total_driver_salary': 0.0,
      'total_driver_bata': 0.0,
      'net_amount': 0.0,
    };

    List<dynamic> dataList = [];
    if (voucherData is List) {
      dataList = voucherData;
    } else if (voucherData is Map) {
      dataList = [voucherData];
    }

    for (var item in dataList) {
      try {
        totals['total_hour'] = (totals['total_hour'] ?? 0.0) +
            (double.tryParse(item['hour']?.toString() ?? '0') ?? 0.0);
        totals['total_amount'] = (totals['total_amount'] ?? 0.0) +
            (double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0);
        totals['total_shifting_charge'] =
            (totals['total_shifting_charge'] ?? 0.0) +
                (double.tryParse(item['shifting_charge']?.toString() ?? '0') ??
                    0.0);
        totals['total_driver_salary'] = (totals['total_driver_salary'] ?? 0.0) +
            (double.tryParse(item['driver_salary']?.toString() ?? '0') ?? 0.0);
        totals['total_driver_bata'] = (totals['total_driver_bata'] ?? 0.0) +
            (double.tryParse(item['driver_bata']?.toString() ?? '0') ?? 0.0);
        totals['net_amount'] = (totals['net_amount'] ?? 0.0) +
            (double.tryParse(item['net_amount']?.toString() ?? '0') ?? 0.0);
      } catch (e) {
        print('Error calculating totals: $e');
      }
    }

    return MyContainer.bordered(
      width: double.infinity,
      borderRadiusAll: 3,
      height: 240,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      borderColor: contentTheme.textBorder,
      paddingAll: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(),
                  ),
                ),
                VerticalDivider(
                  width: 5,
                  thickness: 0.8,
                  color: contentTheme.textBorder,
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          buildFooterRow(
                            "Total Hours",
                            totals['total_hour']!.toStringAsFixed(2),
                          ),
                          Divider(
                            height: 2,
                            thickness: 0.8,
                            color: contentTheme.textBorder,
                          ),
                          buildFooterRow(
                            "Total Amount",
                            totals['total_amount']!.toStringAsFixed(2),
                          ),
                          Divider(
                            height: 2,
                            thickness: 0.8,
                            color: contentTheme.textBorder,
                          ),
                          buildFooterRow(
                            "Total Shifting Charge",
                            totals['total_shifting_charge']!.toStringAsFixed(2),
                          ),
                          Divider(
                            height: 2,
                            thickness: 0.8,
                            color: contentTheme.textBorder,
                          ),
                          buildFooterRow(
                            "Total Salary",
                            totals['total_driver_salary']!.toStringAsFixed(2),
                          ),
                          Divider(
                            height: 2,
                            thickness: 0.8,
                            color: contentTheme.textBorder,
                          ),
                          buildFooterRow(
                            "Total Bata",
                            totals['total_driver_bata']!.toStringAsFixed(2),
                          ),
                          Divider(
                            height: 2,
                            thickness: 0.8,
                            color: contentTheme.textBorder,
                          ),
                          buildFooterRow(
                            "Net Total",
                            totals['net_amount']!.toStringAsFixed(2),
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMainTables(dynamic voucherData) {
    List<dynamic> dataList = [];
    if (voucherData is List) {
      dataList = voucherData;
    } else if (voucherData is Map) {
      dataList = [voucherData];
    }

    if (dataList.isEmpty) {
      return MyContainer.bordered(
        width: double.infinity,
        borderRadiusAll: 3,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        borderColor: contentTheme.textBorder,
        paddingAll: 0,
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: const MyText.bodyMedium(
            "No data available",
            fontWeight: 500,
            color: Colors.grey,
          ),
        ),
      );
    }

    Map<String, List<dynamic>> groupedData = {};
    for (var item in dataList) {
      String vehicleId = item['vehicle_id']?.toString() ?? 'unknown';
      if (!groupedData.containsKey(vehicleId)) {
        groupedData[vehicleId] = [];
      }
      groupedData[vehicleId]!.add(item);
    }

    List<Widget> allRows = [];
    int globalRowIndex = 0;
    int vehicleDisplayIndex = 1;

    groupedData.forEach((vehicleId, vehicleItems) {
      for (int subIndex = 0; subIndex < vehicleItems.length; subIndex++) {
        var item = vehicleItems[subIndex];
        bool isEven = globalRowIndex.isEven;
        globalRowIndex++;

        allRows.add(
          Column(
            children: [
              MyContainer(
                width: double.infinity,
                borderRadiusAll: 3,
                height: 35,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderColor: contentTheme.textBorder,
                paddingAll: 0,
                color: isEven
                    ? contentTheme.rowevencolor
                    : contentTheme.rowoddcolor,
                child: Row(
                  children: [
                    _cell(
                      subIndex == 0 ? vehicleDisplayIndex.toString() : '',
                      width: columnWidths[0],
                    ),
                    _divider(),
                    _cell(
                      subIndex == 0 ? (item['vehicle_name'] ?? '') : '',
                      width: columnWidths[1],
                    ),
                    _divider(),
                    _cell(item['driver_name'] ?? '', width: columnWidths[2]),
                    _divider(),
                    _cell(item['customer_name'] ?? '', width: columnWidths[3]),
                    _divider(),
                    _cell(item['location_name'] ?? '',
                        flex: columnWidths[4].toInt()),
                    _divider(),
                    _cell(item['hour']?.toString() ?? '',
                        flex: columnWidths[5].toInt()),
                    _divider(),
                    _cell(item['rate']?.toString() ?? '',
                        flex: columnWidths[6].toInt()),
                    _divider(),
                    _cell(item['amount']?.toString() ?? '',
                        flex: columnWidths[7].toInt()),
                    _divider(),
                    _cell(item['shifting_charge']?.toString() ?? '',
                        flex: columnWidths[8].toInt()),
                    _divider(),
                    _cell(item['driver_salary']?.toString() ?? '',
                        flex: columnWidths[9].toInt()),
                    _divider(),
                    _cell(item['driver_bata']?.toString() ?? '',
                        flex: columnWidths[10].toInt()),
                    _divider(),
                    _cell(item['payment_type_name'] ?? '',
                        flex: columnWidths[11].toInt()),
                    _divider(),
                    _cell(item['status_name'] ?? '',
                        flex: columnWidths[12].toInt()),
                  ],
                ),
              ),
              Row(
                children: [
                  SizedBox(width: columnWidths[0] + columnWidths[1] + 8),
                  Expanded(
                    child: Divider(
                      height: 1,
                      thickness: 0.8,
                      color: contentTheme.textBorder,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }

      if (vehicleItems.isNotEmpty) {
        Map<String, double> totals = _calculateVehicleTotals(vehicleItems);

        allRows.add(
          Column(
            children: [
              MyContainer(
                width: double.infinity,
                height: 40,
                borderRadiusAll: 3,
                borderColor: contentTheme.textBorder,
                color: Colors.amber.shade200,
                paddingAll: 0,
                child: Row(
                  children: [
                    _totalCell("Total", width: columnWidths[0]),
                    _divider(),
                    _totalCell(vehicleItems[0]['vehicle_name'] ?? '',
                        width: columnWidths[1]),
                    _divider(),
                    _emptyCell(width: columnWidths[2]),
                    _divider(),
                    _emptyCell(width: columnWidths[3]),
                    _divider(),
                    _emptyCell(flex: columnWidths[4].toInt()),
                    _divider(),
                    _totalCell(totals['hour']!.toStringAsFixed(2),
                        flex: columnWidths[5].toInt()),
                    _divider(),
                    _emptyCell(flex: columnWidths[6].toInt()),
                    _divider(),
                    _totalCell(totals['amount']!.toStringAsFixed(2),
                        flex: columnWidths[7].toInt()),
                    _divider(),
                    _totalCell(totals['shifting_charge']!.toStringAsFixed(2),
                        flex: columnWidths[8].toInt()),
                    _divider(),
                    _totalCell(totals['driver_salary']!.toStringAsFixed(2),
                        flex: columnWidths[9].toInt()),
                    _divider(),
                    _totalCell(totals['driver_bata']!.toStringAsFixed(2),
                        flex: columnWidths[10].toInt()),
                    _divider(),
                    _emptyCell(flex: columnWidths[11].toInt()),
                    _divider(),
                    _emptyCell(flex: columnWidths[12].toInt()),
                  ],
                ),
              ),
              Divider(
                  height: 1, thickness: 0.8, color: contentTheme.textBorder),
            ],
          ),
        );
      }

      vehicleDisplayIndex++;
    });

    return MyContainer.bordered(
      width: double.infinity,
      borderRadiusAll: 3,
      height: 400,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      borderColor: contentTheme.textBorder,
      paddingAll: 0,
      child: SingleChildScrollView(
        child: Column(
          children: allRows,
        ),
      ),
    );
  }

  Map<String, double> _calculateVehicleTotals(List<dynamic> vehicleItems) {
    Map<String, double> totals = {
      'hour': 0.0,
      'amount': 0.0,
      'shifting_charge': 0.0,
      'driver_salary': 0.0,
      'driver_bata': 0.0,
    };

    for (var item in vehicleItems) {
      try {
        totals['hour'] = (totals['hour'] ?? 0.0) +
            (double.tryParse(item['hour']?.toString() ?? '0') ?? 0.0);
        totals['amount'] = (totals['amount'] ?? 0.0) +
            (double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0);
        totals['shifting_charge'] = (totals['shifting_charge'] ?? 0.0) +
            (double.tryParse(item['shifting_charge']?.toString() ?? '0') ??
                0.0);
        totals['driver_salary'] = (totals['driver_salary'] ?? 0.0) +
            (double.tryParse(item['driver_salary']?.toString() ?? '0') ?? 0.0);
        totals['driver_bata'] = (totals['driver_bata'] ?? 0.0) +
            (double.tryParse(item['driver_bata']?.toString() ?? '0') ?? 0.0);
      } catch (e) {
        print('Error calculating vehicle totals: $e');
      }
    }

    return totals;
  }

  Widget _cell(String text, {double? width, int? flex}) {
    Widget content = Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: MySpacing.x(5),
        child: MyText.bodySmall(text, fontWeight: 500, fontSize: 13),
      ),
    );

    return width != null
        ? SizedBox(width: width, height: 35, child: content)
        : Expanded(flex: flex ?? 1, child: content);
  }

  Widget _totalCell(String text, {double? width, int? flex}) {
    Widget content = Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: MySpacing.x(5),
        child: MyText.bodySmall(text, fontWeight: 700, fontSize: 13),
      ),
    );

    return width != null
        ? SizedBox(width: width, height: 40, child: content)
        : Expanded(flex: flex ?? 1, child: content);
  }

  Widget _emptyCell({double? width, int? flex}) {
    return width != null
        ? SizedBox(width: width, height: 40)
        : Expanded(flex: flex ?? 1, child: const SizedBox(height: 40));
  }

  Widget buildFooterRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: MySpacing.xy(10, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: MyText.bodyMedium(
              label,
              fontWeight: isBold ? 800 : 600,
              fontSize: 15,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: MyText.bodyLarge(
                value,
                fontWeight: isBold ? 800 : 700,
                fontSize: isBold ? 17 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String title, {double? width, int? flex}) {
    Widget content = Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          MySpacing.width(5),
          MyText.titleSmall(title, fontWeight: 600),
        ],
      ),
    );
    return width != null
        ? SizedBox(width: width, height: 35, child: content)
        : Expanded(flex: flex ?? 1, child: content);
  }

  Widget _divider() => VerticalDivider(
        width: 5,
        thickness: 0.8,
        color: contentTheme.textBorder,
      );

  void toastMessage(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color)),
      width: 300,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1200),
      animation: Tween<double>(begin: 0, end: 300)
          .animate(toastcontroller.animationController),
      content: MyText.labelLarge(text, fontWeight: 600, color: color),
      backgroundColor: color.withAlpha(36),
    ));
  }
}
