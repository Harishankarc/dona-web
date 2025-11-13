import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/dashboard/daybook/add_daybook_controller.dart';
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
import 'package:LeLaundrette/view/layouts/layout.dart';
import 'package:LeLaundrette/view/ui/input_output_utils.dart';
import 'package:LeLaundrette/view/ui/toast_message_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddDayBookScreen extends StatefulWidget {
  const AddDayBookScreen({super.key});

  @override
  State<AddDayBookScreen> createState() => _AddDayBookScreenState();
}

class _AddDayBookScreenState extends State<AddDayBookScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late AddDayBookController controller;
  late OutlineInputBorder _outlineInputBorder;
  late ToastMessageController toastcontroller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AddDayBookController());
    controller.setLoading(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _outlineInputBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      );
      toastcontroller = ToastMessageController(this);
      controller.loadData();
    });
  }

  final List<double> columnWidths = [
    60, // Id
    150, // Vehicle Name
    150, // Driver Name
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
          tag: 'add_sales_controller',
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
                            "Add DayBook",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Dashboard'),
                              MyBreadcrumbItem(name: 'Add Daybook'),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MySpacing.height(10),
            Wrap(alignment: WrapAlignment.start, children: [
              IOUtils.dateField(
                "Voucher Date",
                "Select Voucher Date",
                context,
                controller.setVoucherDate,
                APIService.formatDate,
                controller.voucherdate,
              ),
            ]),
            MySpacing.height(3),
            AddSalesHeader(),
            MySpacing.height(3),
            AddSalesRow(),
            MySpacing.height(3),
            Expanded(child: buildMainTables()),
            MySpacing.height(3),
            buildFooter(),
            MySpacing.height(10),
          ],
        ),
      );
    });
  }

  Map<String, List<dynamic>> _groupDataByCustomer() {
    Map<String, List<dynamic>> grouped = {};
    for (var item in controller.data) {
      String customerKey = item['customer_name']?.toString() ?? 'Unknown';
      grouped.putIfAbsent(customerKey, () => []);
      grouped[customerKey]!.add(item);
    }
    return grouped;
  }

  Map<String, double> _calculateDayBookTotals(List<dynamic> items) {
    double totalTimeWork = 0;
    double totalAmount = 0;
    double totalShiftingCharge = 0;
    double totalDriverSalary = 0;
    double totalDriverBata = 0;

    for (var item in items) {
      totalTimeWork +=
          double.tryParse(item['time_work']?.toString() ?? '0') ?? 0;
      totalAmount += double.tryParse(item['amount']?.toString() ?? '0') ?? 0;
      totalShiftingCharge +=
          double.tryParse(item['shifting_charge']?.toString() ?? '0') ?? 0;
      totalDriverSalary +=
          double.tryParse(item['driver_salary']?.toString() ?? '0') ?? 0;
      totalDriverBata +=
          double.tryParse(item['driver_bata']?.toString() ?? '0') ?? 0;
    }

    return {
      'time_work': totalTimeWork,
      'amount': totalAmount,
      'shifting_charge': totalShiftingCharge,
      'driver_salary': totalDriverSalary,
      'driver_bata': totalDriverBata,
    };
  }

  Widget buildMainTables() {
    if (controller.data.isEmpty) {
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
            "No records added yet",
            fontWeight: 500,
            color: Colors.grey,
          ),
        ),
      );
    }

    Map<String, List<dynamic>> groupedData = _groupDataByCustomer();
    List<Widget> allRows = [];
    int globalIndex = 0;

    groupedData.forEach((driverName, items) {
      for (int i = 0; i < items.length; i++) {
        globalIndex++;
        dynamic item = items[i];

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
                color: globalIndex.isEven
                    ? contentTheme.rowevencolor
                    : contentTheme.rowoddcolor,
                child: Row(
                  children: [
                    _cell(i == 0 ? item['id'].toString() : '',
                        width: columnWidths[0]),
                    _divider(),
                    _cell(item['vehicle_name'], width: columnWidths[1]),
                    _divider(),
                    _cell(i == 0 ? item['driver_name'].toString() : '',
                        width: columnWidths[2]),
                    _divider(),
                    _cell(item['location'], flex: columnWidths[3].toInt()),
                    _divider(),
                    _cell(item['time_work'], flex: columnWidths[4].toInt()),
                    _divider(),
                    _cell(item['rate'] ?? '', flex: columnWidths[5].toInt()),
                    _divider(),
                    _cell(item['amount'], flex: columnWidths[6].toInt()),
                    _divider(),
                    _cell(item['shifting_charge'],
                        flex: columnWidths[7].toInt()),
                    _divider(),
                    _cell(item['driver_salary'], flex: columnWidths[8].toInt()),
                    _divider(),
                    _cell(item['driver_bata'], flex: columnWidths[9].toInt()),
                    _divider(),
                    _cell(item['payment_type'], flex: columnWidths[10].toInt()),
                    _divider(),
                    _cell(item['status'], flex: columnWidths[11].toInt()),
                    _divider(),
                    SizedBox(
                      width: columnWidths[12],
                      height: 35,
                      child: IconButton(
                        icon: const Icon(LucideIcons.delete,
                            size: 20, color: Colors.black),
                        onPressed: () {
                          controller.data.remove(item);
                          controller.reassignIDs();
                          controller.update();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.8,
                color: contentTheme.textBorder,
              )
            ],
          ),
        );
      }

Map<String, double> totals = _calculateDayBookTotals(items);

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
            _emptyCell(width: columnWidths[1]),
            _divider(),
            _totalCell(driverName, width: columnWidths[2]),
            _divider(),
            _emptyCell(flex: columnWidths[3].toInt()),
            _divider(),
            _totalCell(totals['time_work']!.toStringAsFixed(2), flex: columnWidths[4].toInt()),
            _divider(),
            _emptyCell(flex: columnWidths[5].toInt()),
            _divider(),
            _totalCell(totals['amount']!.toStringAsFixed(2), flex: columnWidths[6].toInt()),
            _divider(),
            _totalCell(totals['shifting_charge']!.toStringAsFixed(2), flex: columnWidths[7].toInt()),
            _divider(),
            _totalCell(totals['driver_salary']!.toStringAsFixed(2), flex: columnWidths[8].toInt()),
            _divider(),
            _totalCell(totals['driver_bata']!.toStringAsFixed(2), flex: columnWidths[9].toInt()),
            _divider(),
            _emptyCell(flex: columnWidths[10].toInt()),
            _divider(),
            _emptyCell(flex: columnWidths[11].toInt()),
            _divider(),
            SizedBox(width: columnWidths[12]),
          ],
        ),
      ),
      Divider(height: 1, thickness: 0.8, color: contentTheme.textBorder),
    ],
  ),
);
    });

    return MyContainer.bordered(
      width: double.infinity,
      borderRadiusAll: 3,
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

  Widget _totalCell(String text, {double? width, int? flex}) {
    final child = Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: MyText.titleSmall(text, fontWeight: 700),
      ),
    );

    return width != null
        ? SizedBox(width: width, height: 40, child: child)
        : Expanded(flex: flex ?? 1, child: child);
  }

  Widget _emptyCell({double? width, int? flex}) {
    return width != null
        ? SizedBox(width: width, height: 40)
        : Expanded(flex: flex ?? 1, child: const SizedBox(height: 40));
  }

  Widget _cell(String text, {double? width, int? flex, bool bold = false}) {
    final child = Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          MySpacing.width(5),
          MyText.titleSmall(text, fontWeight: bold ? 700 : 600),
        ],
      ),
    );

    return width != null
        ? SizedBox(width: width, height: 35, child: child)
        : Expanded(flex: flex ?? 1, child: child);
  }

  Widget buildFooter() {
    return MyContainer.bordered(
      width: double.infinity,
      borderRadiusAll: 3,
      height: 270,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      borderColor: contentTheme.textBorder,
      paddingAll: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: SizedBox()),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                  width: 5,
                  thickness: 0.8,
                  color: contentTheme.textBorder,
                ),
                SizedBox(
                  width: 700,
                  height: 200,
                  child: Column(
                    children: [
                      Padding(
                        padding: MySpacing.x(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 200,
                              height: 35,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: MyText.bodyMedium(
                                  "Total Hours",
                                  fontWeight: 600,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              height: 35,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: MyText.bodyLarge(
                                  num.tryParse(controller
                                              .calculateTotal(controller.data))
                                          ?.toStringAsFixed(2) ??
                                      "0.00",
                                  fontWeight: 700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 5,
                        thickness: 0.8,
                        color: contentTheme.textBorder,
                      ),
                      Padding(
                        padding: MySpacing.x(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 200,
                              height: 35,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: MyText.bodyMedium(
                                  "Total Amount",
                                  fontWeight: 600,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              height: 35,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: MyText.bodyLarge(
                                  num.tryParse(controller
                                              .discountcontroller.text)
                                          ?.toStringAsFixed(2) ??
                                      '0.00',
                                  fontWeight: 700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 5,
                        thickness: 0.8,
                        color: contentTheme.textBorder,
                      ),
                      Padding(
                        padding: MySpacing.x(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 200,
                              height: 35,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: MyText.bodyMedium(
                                  "Total Salary",
                                  fontWeight: 600,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              height: 35,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: MyText.bodyLarge(
                                  num.tryParse(controller.calculateTotalTax(
                                              controller.data))
                                          ?.toStringAsFixed(2) ??
                                      '0.00',
                                  fontWeight: 700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 5,
                        thickness: 0.8,
                        color: contentTheme.textBorder,
                      ),
                      Padding(
                        padding: MySpacing.x(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 200,
                              height: 35,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: MyText.bodyMedium(
                                  "Total Bata",
                                  fontWeight: 600,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              height: 35,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: MyText.bodyLarge(
                                  num.tryParse(controller.calculateTotalTax(
                                              controller.data))
                                          ?.toStringAsFixed(2) ??
                                      '0.00',
                                  fontWeight: 700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 5,
                        thickness: 0.8,
                        color: contentTheme.textBorder,
                      ),
                      Padding(
                        padding: MySpacing.x(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 200,
                              height: 35,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: MyText.bodyMedium(
                                  "Net Total",
                                  fontWeight: 700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              height: 35,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: MyText.bodyLarge(
                                  ((num.tryParse(controller.calculateTotalNet(
                                                  controller.data)) ??
                                              0) -
                                          (num.tryParse(controller
                                                  .discountcontroller.text) ??
                                              0))
                                      .toStringAsFixed(2),
                                  fontWeight: 800,
                                  fontSize: 21,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(
            height: 5,
            thickness: 0.8,
            color: contentTheme.textBorder,
          ),
          Padding(
            padding: MySpacing.only(right: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyButton(
                  onPressed: () => Get.back(),
                  elevation: 0,
                  borderRadiusAll: 8,
                  padding: MySpacing.xy(20, 4),
                  backgroundColor: colorScheme.secondaryContainer,
                  child: MyText.labelMedium(
                    "Cancel",
                    fontWeight: 600,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                MySpacing.width(16),
                MyButton(
                  onPressed: () async {
                    if (controller.selectedcustomer.isEmpty) {
                      toastMessage(
                          "Please select customer", contentTheme.danger);
                    } else if (controller.currency.isEmpty) {
                      toastMessage(
                          "Please select currency", contentTheme.danger);
                    } else if (controller.data.isEmpty) {
                      toastMessage("Please add inventory", contentTheme.danger);
                    } else if (controller.selectedbranch == null) {
                      toastMessage("Please select branch", contentTheme.danger);
                    } else if (controller.selectedsalesman == null) {
                      toastMessage(
                          "Please select Salesman", contentTheme.danger);
                    } else if (controller.invoiceType == null) {
                      toastMessage(
                          "Please select invoice type", contentTheme.danger);
                    } else if (controller.selectedpaymenttype == null) {
                      toastMessage(
                          "Please select payment type", contentTheme.danger);
                    } else {
                      controller.setLoading(true);
                      // final resp = await APIService.addSale(
                      //     controller.selectedbranch['id'].toString(),
                      //     'SI',
                      //     '',
                      //     APIService.formatDatefromDate(
                      //         controller.voucherdate!, true),
                      //     controller.selectedcustomer['id'].toString(),
                      //     controller.selectedcustomer['name'].toString(),
                      //     controller.currency["id"].toString(),
                      //     controller.currency["currency"].toString(),
                      //     controller.currency["exchange_rate"].toString(),
                      //     'E',
                      //     (num.tryParse(controller.discountcontroller.text) ??
                      //             0)
                      //         .toString(),
                      //     controller.advancecontroller.text.isNotEmpty
                      //         ? "Y"
                      //         : "N",
                      //     controller.advancecontroller.text.isEmpty
                      //         ? "0"
                      //         : controller.advancecontroller.text,
                      //     '',
                      //     controller.data,
                      //     controller.remarkscontroller.text,
                      //     controller.invoiceType!.id.toString(),
                      //     controller.selectedpaymenttype!.id.toString(),
                      //     controller.selectedsalesman['id'].toString());
                      // controller.setLoading(false);
                      // if (resp['status'] == 'success') {
                      //   Get.offNamed('/sales/listsales');
                      //   toastMessage("Sales Invoice Created Successfully",
                      //       contentTheme.success);
                      // } else {
                      //   toastMessage(
                      //       resp['message'].toString(), contentTheme.danger);
                      // }
                    }
                  },
                  elevation: 0,
                  borderRadiusAll: 8,
                  padding: MySpacing.xy(20, 4),
                  backgroundColor: colorScheme.primary,
                  child: MyText.labelMedium(
                    "Submit",
                    fontWeight: 600,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget AddSalesHeader() {
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
          _headerCell("Site", flex: columnWidths[3].toInt()),
          _divider(),
          _headerCell("Hour", flex: columnWidths[4].toInt()),
          _divider(),
          _headerCell("Rate", flex: columnWidths[5].toInt()),
          _divider(),
          _headerCell("Amount", flex: columnWidths[6].toInt()),
          _divider(),
          _headerCell("Shift Charge", flex: columnWidths[7].toInt()),
          _divider(),
          _headerCell("Driver Salary", flex: columnWidths[8].toInt()),
          _divider(),
          _headerCell("Bata", flex: columnWidths[9].toInt()),
          _divider(),
          _headerCell("Payment Type", flex: columnWidths[10].toInt()),
          _divider(),
          _headerCell("Status", flex: columnWidths[11].toInt()),
          _divider(),
          _headerCell("", width: columnWidths[12]),
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

  Widget AddSalesRow() {
    return MyContainer.bordered(
      width: double.infinity,
      borderRadiusAll: 3,
      height: 35,
      borderColor: contentTheme.textBorder,
      paddingAll: 0,
      child: Row(
        children: [
          _dataCell("#", width: columnWidths[0]),
          _divider(),
          // Vehicle TypeAhead with sample data
          _dataField(
              IOUtils.typeAheadField<String>(
                "",
                "",
                (term) async => [
                  'Vehicle A',
                  'Vehicle B',
                  'Vehicle C',
                  'Vehicle D'
                ]
                    .where((e) => e.toLowerCase().contains(term.toLowerCase()))
                    .toList(),
                (value) => controller.updateVehicle(value),
                (value) => value ?? '',
                controller.selectedVehicle,
                emptyFuntion: (val) => val == null || val.isEmpty || val == '',
                onlybox: true,
                borderless: true,
              ),
              width: columnWidths[1]),
          _divider(),
          // Driver TypeAhead with sample data
          _dataField(
              IOUtils.typeAheadField<String>(
                "",
                "",
                (term) async => ['Driver A', 'Driver B', 'Driver C', 'Driver D']
                    .where((e) => e.toLowerCase().contains(term.toLowerCase()))
                    .toList(),
                (value) => controller.updateDriver(value),
                (value) => value ?? '',
                controller.selectedDriver,
                emptyFuntion: (val) => val == null || val.isEmpty || val == '',
                onlybox: true,
                borderless: true,
              ),
              width: columnWidths[2]),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.locationController,
                  onlybox: true, borderless: true),
              flex: columnWidths[3].toInt()),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.timeWorkController,
                  onlybox: true, borderless: true),
              flex: columnWidths[4].toInt()),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.rateController,
                  onlybox: true, borderless: true),
              flex: columnWidths[5].toInt()),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.amountController,
                  onlybox: true, borderless: true),
              flex: columnWidths[6].toInt()),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.shiftingChargeController,
                  onlybox: true, borderless: true),
              flex: columnWidths[7].toInt()),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.driverSalaryController,
                  onlybox: true, borderless: true),
              flex: columnWidths[8].toInt()),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.driverBataController,
                  onlybox: true, borderless: true),
              flex: columnWidths[9].toInt()),
          _divider(),
          _dataField(
              IOUtils.typeAheadField<String>(
                  "",
                  "",
                  (term) async => ['Cash', 'Credit']
                      .where(
                          (e) => e.toLowerCase().contains(term.toLowerCase()))
                      .toList(),
                  (value) => controller.updatePaymentType(value),
                  (value) => value ?? '',
                  controller.selectedPayment,
                  emptyFuntion: (val) =>
                      val == null || val.isEmpty || val == '',
                  onlybox: true,
                  borderless: true),
              flex: columnWidths[10].toInt()),
          _divider(),
          _dataField(
              IOUtils.typeAheadField<String>(
                "",
                "",
                (value) async => ['Completed', 'Pending']
                    .where((e) => e.toLowerCase().contains(value.toLowerCase()))
                    .toList(),
                controller.updateStatus,
                (value) => value ?? '',
                controller.selectedStatus,
                onlybox: true,
                borderless: true,
                emptyFuntion: (val) => val == null || val.isEmpty || val == '',
              ),
              flex: columnWidths[11].toInt()),
          _divider(),
          _addButtonCell(),
        ],
      ),
    );
  }


  Widget _dataCell(String text, {double? width, int? flex}) => width != null
      ? SizedBox(
          width: width,
          height: 35,
          child: Center(child: MyText.titleSmall(text, fontWeight: 600)))
      : Expanded(
          flex: flex ?? 1,
          child: Center(child: MyText.titleSmall(text, fontWeight: 600)));

  Widget _dataField(Widget child, {double? width, int? flex}) => width != null
      ? SizedBox(width: width, height: 35, child: child)
      : Expanded(flex: flex ?? 1, child: child);

  Widget _addButtonCell() {
    return GestureDetector(
      onTap: () async {
        if (controller.selectedDriver.isEmpty) {
          toastMessage("Please select a driver", contentTheme.danger);
          return;
        }
        if (controller.selectedVehicle.isEmpty) {
          toastMessage("Please select a vehicle", contentTheme.danger);
          return;
        }

        // Check if exists
        String driverName = controller.selectedDriver;
        var existingDriver = controller.data.where(
          (row) => row['driver_name'] == driverName,
        );

        String driverId;
        if (existingDriver.isEmpty) {
          driverId = controller.nextId.toString();
          controller.nextId++;
        } else {
          driverId = existingDriver.first['id'];
        }

        // Add row
        controller.data.add({
          'id': driverId,
          'driver_name': driverName,
          'vehicle_name': controller.selectedVehicle,
          'location': controller.locationController.text,
          'time_work': controller.timeWorkController.text,
          'rate': controller.rateController.text,
          'amount': controller.amountController.text,
          'shifting_charge': controller.shiftingChargeController.text,
          'driver_salary': controller.driverSalaryController.text,
          'driver_bata': controller.driverBataController.text,
          'payment_type': controller.selectedPayment,
          'status': controller.selectedStatus,
          'customer_name': driverName,
        });
        print("-------------------------");
        print(controller.data);
        print("-------------------------");

        controller.selectedDriver = '';
        controller.selectedVehicle = '';
        controller.locationController.clear();
        controller.timeWorkController.clear();
        controller.rateController.clear();
        controller.amountController.clear();
        controller.shiftingChargeController.clear();
        controller.driverSalaryController.clear();
        controller.driverBataController.clear();
        controller.selectedPayment = '';
        controller.selectedStatus = '';

        controller.reassignIDs();
      },
      child: SizedBox(
        width: 60,
        height: 35,
        child: const Center(
          child: Icon(LucideIcons.plusCircle, size: 20),
        ),
      ),
    );
  }

  void addCustomer() {
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
                          width: 600,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: MyText.labelLarge(
                                  'Add Customer',
                                  fontWeight: 600,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                  padding: MySpacing.xy(0, 0),
                                  child: MyContainer(
                                    child: Column(
                                      children: [
                                        Wrap(
                                            children: [
                                          IOUtils.fields(
                                            "Name",
                                            "Enter Name",
                                            controller.namecontroller,
                                          ),
                                          IOUtils.fields(
                                            "Phone",
                                            "Enter Phone",
                                            controller.phonecontroller,
                                          ),
                                          IOUtils.fields(
                                            "Secondary Phone",
                                            "Enter Secondary Phone",
                                            controller.secondaryphonecontroller,
                                          ),
                                          IOUtils.typeAheadField<dynamic>(
                                            "Branch",
                                            "Select Branch",
                                            (term) => APIService
                                                .getMasterDetailsAsList(
                                                    term, 'branches'),
                                            controller.setBranch,
                                            (value) =>
                                                value!['name'].toString(),
                                            controller.selectedbranch,
                                          ),
                                          IOUtils.fields(
                                            "Address",
                                            "Enter Address",
                                            controller.addresscontroller,
                                          ),
                                          IOUtils.fields(
                                            "Latitude",
                                            "Enter Latitude",
                                            controller.latitudecontroller,
                                          ),
                                          IOUtils.fields(
                                            "Longitude",
                                            "Enter Longitude",
                                            controller.longitudecontroller,
                                          ),
                                        ]
                                                .map((e) => Padding(
                                                    padding: MySpacing.all(5),
                                                    child: e))
                                                .toList()),
                                      ],
                                    ),
                                  )),
                              Padding(
                                padding: MySpacing.only(right: 20, bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
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
                                            color: colorScheme
                                                .onSecondaryContainer,
                                          ),
                                        ),
                                        MySpacing.width(16),
                                        MyButton(
                                          onPressed: () async {
                                            if (controller
                                                .namecontroller.text.isEmpty) {
                                              toastMessage(
                                                  "Name Field is Required",
                                                  contentTheme.danger);
                                              return;
                                            }
                                            if (controller
                                                .phonecontroller.text.isEmpty) {
                                              toastMessage(
                                                  "Phone Field is Required",
                                                  contentTheme.danger);
                                              return;
                                            }
                                            if (controller.selectedbranch ==
                                                null) {
                                              toastMessage(
                                                  "Branch Field is Required",
                                                  contentTheme.danger);
                                              return;
                                            }
                                            if (controller.addresscontroller
                                                .text.isEmpty) {
                                              toastMessage(
                                                  "Address Field is Required",
                                                  contentTheme.danger);
                                              return;
                                            }
                                            controller.setLoading(true);
                                            // final resp =
                                            //     await APIService.addSubledger(
                                            //         controller
                                            //             .namecontroller.text,
                                            //         controller
                                            //             .phonecontroller.text,
                                            //         controller
                                            //             .selectedbranch['id']
                                            //             .toString(),
                                            //         controller
                                            //             .secondaryphonecontroller
                                            //             .text,
                                            //         controller
                                            //             .addresscontroller.text,
                                            //         controller
                                            //             .latitudecontroller.text
                                            //             .toString(),
                                            //         controller
                                            //             .longitudecontroller
                                            //             .text
                                            //             .toString(),
                                            //         '1',
                                            //         LocalStorage.getLoggedUserdata()[
                                            //                 'userid']
                                            //             .toString());
                                            // controller.setLoading(false);
                                            // if (resp['status'] == 'success') {
                                            //   toastMessage(
                                            //       resp['message'].toString(),
                                            //       contentTheme.success);
                                            //   Get.back(
                                            //       result: resp['subledgerId']
                                            //           .toString());
                                            // } else {
                                            //   toastMessage(
                                            //       resp['message'].toString(),
                                            //       contentTheme.danger);
                                            // }
                                          },
                                          elevation: 0,
                                          borderRadiusAll: 8,
                                          padding: MySpacing.xy(20, 16),
                                          backgroundColor: colorScheme.primary,
                                          child: MyText.labelMedium(
                                            "Save",
                                            fontWeight: 600,
                                            color: colorScheme.onPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              });
        }).then((value) {
      if (value is String &&
          value != '' &&
          num.tryParse(value.toString()) is num) {
        controller.setCusotmer({
          'id': value.toString(),
          'name': controller.namecontroller.text.toString()
        });
      }
    });
  }

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
