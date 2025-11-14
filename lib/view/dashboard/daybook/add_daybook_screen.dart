// ignore_for_file: non_constant_identifier_names

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _outlineInputBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      );
      toastcontroller = ToastMessageController(this);
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
          tag: 'add_daybook_controller',
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
            AddDayBookHeader(),
            MySpacing.height(3),
            AddDayBookRow(),
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
            "No data available",
            fontWeight: 500,
            color: Colors.grey,
          ),
        ),
      );
    }

    // List<Widget> allRows = [];

    // for (var vehicle in controller.data) {
    //   String vehicleName = vehicle["vehicle_name"];
    //   List<dynamic> items = vehicle["vehicles_data"];

    //   for (int i = 0; i < items.length; i++) {
    //     var item = items[i];

    //     allRows.add(
    //       Column(
    //         children: [
    //           MyContainer(
    //             width: double.infinity,
    //             borderRadiusAll: 3,
    //             height: 35,
    //             clipBehavior: Clip.antiAliasWithSaveLayer,
    //             borderColor: contentTheme.textBorder,
    //             paddingAll: 0,
    //             color: i.isEven
    //                 ? contentTheme.rowevencolor
    //                 : contentTheme.rowoddcolor,
    //             child: Row(
    //               children: [
    //                 _cell(i == 0 ? vehicle["vehicle_index"].toString() : '',
    //                     width: columnWidths[0]),
    //                 _divider(),
    //                 _cell(vehicleName, width: columnWidths[1]),
    //                 Column(
    //                     children: (item["vehicles_data"] as List).map((e) {
    //                   return Row(
    //                     children: [],
    //                   );
    //                 }).toList()),
    //               ],
    //             ),
    //           ),
    //           Divider(
    //             height: 1,
    //             thickness: 0.8,
    //             color: contentTheme.textBorder,
    //           )
    //         ],
    //       ),
    //     );
    //   }

    //   /// CALCULATE TOTALS FOR THIS VEHICLE
    //   Map<String, double> totals = _calculateDayBookTotals(items);

    //   allRows.add(
    //     Column(
    //       children: [
    //         MyContainer(
    //           width: double.infinity,
    //           height: 40,
    //           borderRadiusAll: 3,
    //           borderColor: contentTheme.textBorder,
    //           color: Colors.amber.shade200,
    //           paddingAll: 0,
    //           child: Row(
    //             children: [
    //               _totalCell("Total", width: columnWidths[0]),
    //               _divider(),
    //               _totalCell(vehicleName, width: columnWidths[1]),
    //               _divider(),
    //               _emptyCell(width: columnWidths[2]),
    //               _divider(),
    //               _emptyCell(flex: columnWidths[3].toInt()),
    //               _divider(),
    //               _totalCell(totals['hour']!.toStringAsFixed(2),
    //                   flex: columnWidths[4].toInt()),
    //               _divider(),
    //               _emptyCell(flex: columnWidths[5].toInt()),
    //               _divider(),
    //               _totalCell(totals['amount']!.toStringAsFixed(2),
    //                   flex: columnWidths[6].toInt()),
    //               _divider(),
    //               _totalCell(totals['shifting_charge']!.toStringAsFixed(2),
    //                   flex: columnWidths[7].toInt()),
    //               _divider(),
    //               _totalCell(totals['driver_salary']!.toStringAsFixed(2),
    //                   flex: columnWidths[8].toInt()),
    //               _divider(),
    //               _totalCell(totals['driver_bata']!.toStringAsFixed(2),
    //                   flex: columnWidths[9].toInt()),
    //               _divider(),
    //               _emptyCell(flex: columnWidths[10].toInt()),
    //               _divider(),
    //               _emptyCell(flex: columnWidths[11].toInt()),
    //               _divider(),
    //               SizedBox(width: columnWidths[12]),
    //             ],
    //           ),
    //         ),
    //         Divider(height: 1, thickness: 0.8, color: contentTheme.textBorder),
    //       ],
    //     ),
    //   );
    // }

    return MyContainer.bordered(
      width: double.infinity,
      borderRadiusAll: 3,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      borderColor: contentTheme.textBorder,
      paddingAll: 0,
      child: SingleChildScrollView(
        child: Column(
            children: controller.data.map((mainelement) {
          return MyContainer(
                         width: double.infinity,
                borderRadiusAll: 3,
                height: 35,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderColor: contentTheme.textBorder,
                paddingAll: 0,
                color: controller.data.indexOf(mainelement) .isEven
                    ? contentTheme.rowevencolor
                    : contentTheme.rowoddcolor,
            child: Row(
              children: [
                _cell(mainelement["vehicle_index"].toString(),
                    width: columnWidths[0]),
                _divider(),
                _cell(mainelement["vehicle_name"], width: columnWidths[1]),
                Column(
                  children:
                      (mainelement["vehicles_data"] as List).map((subelement) {
                    return Row(
                      children: [
                        _divider(),
                        _cell(subelement['driver_name'], width: columnWidths[2]),
                        _divider(),
                        _cell(subelement['location_name'],
                            flex: columnWidths[3].toInt()),
                        _divider(),
                        _cell(subelement['hour'], flex: columnWidths[4].toInt()),
                        _divider(),
                        _cell(subelement['rate'], flex: columnWidths[5].toInt()),
                        _divider(),
                        _cell(subelement['amount'],
                            flex: columnWidths[6].toInt()),
                        _divider(),
                        _cell(subelement['shifting_charge'],
                            flex: columnWidths[7].toInt()),
                        _divider(),
                        _cell(subelement['driver_salary'],
                            flex: columnWidths[8].toInt()),
                        _divider(),
                        _cell(subelement['driver_bata'],
                            flex: columnWidths[9].toInt()),
                        _divider(),
                        _cell(subelement['payment_type_name'],
                            flex: columnWidths[10].toInt()),
                        _divider(),
                        _cell(subelement['status_name'],
                            flex: columnWidths[11].toInt()),
                        _divider(),
                        SizedBox(
                          width: columnWidths[12],
                          height: 35,
                          child: IconButton(
                            icon: const Icon(LucideIcons.delete,
                                size: 20, color: Colors.black),
                            onPressed: () {
                              // controller.removeVehicleDataItem(
                              //   vehicle["vehicle_index"],
                              //   i,
                              // );
                              controller.update();
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                )
              ],
            ),
          );
        }).toList()),
      ),
    );
  }

  // Widget buildMainTables() {
  //   if (controller.data.isEmpty) {
  //     return MyContainer.bordered(
  //       width: double.infinity,
  //       borderRadiusAll: 3,
  //       clipBehavior: Clip.antiAliasWithSaveLayer,
  //       borderColor: contentTheme.textBorder,
  //       paddingAll: 0,
  //       child: Container(
  //         height: 200,
  //         alignment: Alignment.center,
  //         child: const MyText.bodyMedium(
  //           "No data available",
  //           fontWeight: 500,
  //           color: Colors.grey,
  //         ),
  //       ),
  //     );
  //   }

  //   Map<String, List<dynamic>> groupedData = _groupDataByCustomer();
  //   List<Widget> allRows = [];
  //   int globalIndex = 0;

  //   groupedData.forEach((driverName, items) {
  //     for (int i = 0; i < items.length; i++) {
  //       globalIndex++;
  //       dynamic item = items[i];

  //       allRows.add(
  //         Column(
  //           children: [
  //             MyContainer(
  //               width: double.infinity,
  //               borderRadiusAll: 3,
  //               height: 35,
  //               clipBehavior: Clip.antiAliasWithSaveLayer,
  //               borderColor: contentTheme.textBorder,
  //               paddingAll: 0,
  //               color: globalIndex.isEven
  //                   ? contentTheme.rowevencolor
  //                   : contentTheme.rowoddcolor,
  //               child: Row(
  //                 children: [
  //                   _cell(i == 0 ? item['id'].toString() : '',
  //                       width: columnWidths[0]),
  //                   _divider(),
  //                   _cell(item['vehicle_name'], width: columnWidths[1]),
  //                   _divider(),
  //                   _cell(i == 0 ? item['driver_name'].toString() : '',
  //                       width: columnWidths[2]),
  //                   _divider(),
  //                   _cell(item['location'], flex: columnWidths[3].toInt()),
  //                   _divider(),
  //                   _cell(item['time_work'], flex: columnWidths[4].toInt()),
  //                   _divider(),
  //                   _cell(item['rate'] ?? '', flex: columnWidths[5].toInt()),
  //                   _divider(),
  //                   _cell(item['amount'], flex: columnWidths[6].toInt()),
  //                   _divider(),
  //                   _cell(item['shifting_charge'],
  //                       flex: columnWidths[7].toInt()),
  //                   _divider(),
  //                   _cell(item['driver_salary'], flex: columnWidths[8].toInt()),
  //                   _divider(),
  //                   _cell(item['driver_bata'], flex: columnWidths[9].toInt()),
  //                   _divider(),
  //                   _cell(item['payment_type'], flex: columnWidths[10].toInt()),
  //                   _divider(),
  //                   _cell(item['status'], flex: columnWidths[11].toInt()),
  //                   _divider(),
  //                   SizedBox(
  //                     width: columnWidths[12],
  //                     height: 35,
  //                     child: IconButton(
  //                       icon: const Icon(LucideIcons.delete,
  //                           size: 20, color: Colors.black),
  //                       onPressed: () {
  //                         // controller.data.removeVehicleDataItem(item);
  //                         controller.update();
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Divider(
  //               height: 1,
  //               thickness: 0.8,
  //               color: contentTheme.textBorder,
  //             )
  //           ],
  //         ),
  //       );
  //     }

  //     Map<String, double> totals = _calculateDayBookTotals(items);

  //     allRows.add(
  //       Column(
  //         children: [
  //           MyContainer(
  //             width: double.infinity,
  //             height: 40,
  //             borderRadiusAll: 3,
  //             borderColor: contentTheme.textBorder,
  //             color: Colors.amber.shade200,
  //             paddingAll: 0,
  //             child: Row(
  //               children: [
  //                 _totalCell("Total", width: columnWidths[0]),
  //                 _divider(),
  //                 _emptyCell(width: columnWidths[1]),
  //                 _divider(),
  //                 _totalCell(driverName, width: columnWidths[2]),
  //                 _divider(),
  //                 _emptyCell(flex: columnWidths[3].toInt()),
  //                 _divider(),
  //                 _totalCell(totals['time_work']!.toStringAsFixed(2),
  //                     flex: columnWidths[4].toInt()),
  //                 _divider(),
  //                 _emptyCell(flex: columnWidths[5].toInt()),
  //                 _divider(),
  //                 _totalCell(totals['amount']!.toStringAsFixed(2),
  //                     flex: columnWidths[6].toInt()),
  //                 _divider(),
  //                 _totalCell(totals['shifting_charge']!.toStringAsFixed(2),
  //                     flex: columnWidths[7].toInt()),
  //                 _divider(),
  //                 _totalCell(totals['driver_salary']!.toStringAsFixed(2),
  //                     flex: columnWidths[8].toInt()),
  //                 _divider(),
  //                 _totalCell(totals['driver_bata']!.toStringAsFixed(2),
  //                     flex: columnWidths[9].toInt()),
  //                 _divider(),
  //                 _emptyCell(flex: columnWidths[10].toInt()),
  //                 _divider(),
  //                 _emptyCell(flex: columnWidths[11].toInt()),
  //                 _divider(),
  //                 SizedBox(width: columnWidths[12]),
  //               ],
  //             ),
  //           ),
  //           Divider(height: 1, thickness: 0.8, color: contentTheme.textBorder),
  //         ],
  //       ),
  //     );
  //   });

  //   return MyContainer.bordered(
  //     width: double.infinity,
  //     borderRadiusAll: 3,
  //     clipBehavior: Clip.antiAliasWithSaveLayer,
  //     borderColor: contentTheme.textBorder,
  //     paddingAll: 0,
  //     child: SingleChildScrollView(
  //       child: Column(
  //         children: allRows,
  //       ),
  //     ),
  //   );
  // }

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
                  onPressed: () async {},
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

  Widget AddDayBookHeader() {
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
          _divider(),
          _headerCell("", width: columnWidths[13]),
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

  Widget AddDayBookRow() {
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
          _dataField(
              IOUtils.typeAheadField<dynamic>(
                "",
                "",
                (term) async {
                  return await APIService.getVehicleListByModelAPI(term);
                },
                (value) => controller.updateVehicle(value),
                (value) => "${value["name"]}",
                controller.selectedVehicle,
                emptyFuntion: (val) => val == null || val.isEmpty || val == '',
                onlybox: true,
                borderless: true,
              ),
              width: columnWidths[1]),
          _divider(),
          _dataField(
              IOUtils.typeAheadField<dynamic>(
                "",
                "",
                (term) async {
                  return await APIService.getSubledgerListByModelAPI(term, "1");
                },
                (value) => controller.updateDriver(value),
                (value) => "${value["name"]}",
                controller.selectedDriver,
                emptyFuntion: (val) => val == null || val.isEmpty || val == '',
                onlybox: true,
                borderless: true,
              ),
              width: columnWidths[2]),
          _divider(),
          _dataField(
              IOUtils.typeAheadField<dynamic>(
                "",
                "",
                (term) async {
                  return await APIService.getSubledgerListByModelAPI(term, "3");
                },
                (value) => controller.updateCustomer(value),
                (value) => "${value["name"]}",
                controller.selectedCustomer,
                emptyFuntion: (val) => val == null || val.isEmpty || val == '',
                onlybox: true,
                borderless: true,
              ),
              width: columnWidths[3]),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.locationController,
                  onlybox: true, borderless: true),
              flex: columnWidths[4].toInt()),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.timeWorkController,
                  onChanged: (val) {
                controller.updateRate(controller.timeWorkController.text);
              }, onlybox: true, borderless: true),
              flex: columnWidths[5].toInt()),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.rateController,
                  onlybox: true, borderless: true, readOnly: true),
              flex: columnWidths[6].toInt()),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.amountController,
                  onlybox: true, borderless: true, readOnly: true),
              flex: columnWidths[7].toInt()),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.shiftingChargeController,
                  onlybox: true, borderless: true, readOnly: true),
              flex: columnWidths[8].toInt()),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.driverSalaryController,
                  onlybox: true, borderless: true, readOnly: true),
              flex: columnWidths[9].toInt()),
          _divider(),
          _dataField(
              IOUtils.fields("", "", controller.driverBataController,
                  onlybox: true, borderless: true),
              flex: columnWidths[10].toInt()),
          _divider(),
          _dataField(
              IOUtils.typeAheadField<dynamic>("", "", (term) async {
                return APIService.getPaymentTypes();
              }, (value) => controller.updatePaymentType(value),
                  (value) => "${value["name"]}", controller.selectedPayment,
                  emptyFuntion: (val) =>
                      val == null || val.isEmpty || val == '',
                  onlybox: true,
                  borderless: true),
              flex: columnWidths[11].toInt()),
          _divider(),
          _dataField(
              IOUtils.typeAheadField<dynamic>(
                "",
                "",
                (value) async {
                  return controller.statuslist;
                },
                controller.updateStatus,
                (value) => "${value["name"]}",
                controller.selectedStatus,
                onlybox: true,
                borderless: true,
                emptyFuntion: (val) => val == null || val.isEmpty || val == '',
              ),
              flex: columnWidths[12].toInt()),
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
        if (controller.selectedVehicle == null) {
          toastMessage("Please select a vehicle", contentTheme.danger);
          return;
        }
        if (controller.selectedDriver == null) {
          toastMessage("Please select a driver", contentTheme.danger);
          return;
        }

        if (controller.selectedCustomer == null) {
          toastMessage("Please select a customer", contentTheme.danger);
          return;
        }

        if (controller.timeWorkController.text.isEmpty) {
          toastMessage("Please enter hour", contentTheme.danger);
          return;
        }

        if (controller.selectedPayment == null) {
          toastMessage("Please select payment", contentTheme.danger);
          return;
        }

        if (controller.selectedStatus == null) {
          toastMessage("Please select status", contentTheme.danger);
          return;
        }

        controller.setLoading(true);
        await controller.addVehicleData({
          "subledger_id": controller.selectedCustomer["id"].toString(),
          "subledger_name": controller.selectedCustomer["name"].toString(),
          "vehicle_id": controller.selectedVehicle["id"].toString(),
          "vehicle_name": controller.selectedVehicle["name"].toString(),
          "driver_id": controller.selectedDriver["id"].toString(),
          "driver_name": controller.selectedDriver["name"].toString(),
          "location_name": controller.locationController.text,
          "hour": controller.timeWorkController.text,
          "rate": controller.rateController.text,
          "amount": controller.amountController.text,
          "need_shift": controller.selectedVehicle["need_shift"].toString(),
          "shifting_charge": controller.shiftingChargeController.text,
          "driver_salary": controller.driverSalaryController.text,
          "driver_bata": controller.driverBataController.text,
          "payment_type_id": controller.selectedPayment["id"].toString(),
          "payment_type_name": controller.selectedPayment["name"].toString(),
          "status": controller.selectedStatus["id"].toString(),
          "status_name": controller.selectedStatus["name"].toString()
        });
        controller.setLoading(false);
        print("-------------------------");
        print(controller.data);
        print("-------------------------");
      },
      child: const SizedBox(
        width: 60,
        height: 35,
        child: Center(
          child: Icon(LucideIcons.plusCircle, size: 20),
        ),
      ),
    );
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
