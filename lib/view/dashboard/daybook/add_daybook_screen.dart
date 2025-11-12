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
import 'package:LeLaundrette/view/ui/data_table_inbuild_changed.dart' as table;
import 'package:LeLaundrette/helpers/widgets/my_flex.dart';
import 'package:LeLaundrette/helpers/widgets/my_flex_item.dart';
import 'package:LeLaundrette/helpers/widgets/my_list_extension.dart';
import 'package:LeLaundrette/helpers/widgets/my_spacing.dart';
import 'package:LeLaundrette/helpers/widgets/my_text.dart';
import 'package:LeLaundrette/model/paymenttype_model.dart';
import 'package:LeLaundrette/view/layouts/delete_view.dart';
import 'package:LeLaundrette/view/layouts/layout.dart';
import 'package:LeLaundrette/view/ui/input_output_utils.dart';
import 'package:LeLaundrette/view/ui/permission_handler.dart';
import 'package:LeLaundrette/view/ui/toast_message_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_pagination/flutter_custom_pagination.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    _outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    );
    toastcontroller = ToastMessageController(this);
    super.initState();
    controller = AddDayBookController();
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
          tag: 'collection_list_controller',
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
                            "DayBook",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Dashboard'),
                              MyBreadcrumbItem(name: 'Daybook'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MySpacing.height(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IOUtils.dateField(
                  "Voucher Date",
                  "Select Voucher Date",
                  context,
                  controller.setVoucherDate,
                  APIService.formatDate,
                  controller.voucherdate,
                ),
              ],
            ),
            MySpacing.height(20),
            _editableDayBookTable()
          ],
        ),
      );
    });
  }

Widget _editableDayBookTable() {
    final List<String> headers = [
      'Id',
      'Driver Name',
      'Vehicle Name',
      'Location',
      'Time Work',
      'Amount',
      'Shifting Charge',
      'Driver Salary',
      'Driver Bata',
      'Payment Type',
      'Status',
    ];

    final List<String> paymentOptions = ['Cash', 'Credit'];
    final List<String> statusOptions = ['Completed', 'Pending'];

    void addRow() {
      String driverName = controller.driverController.text.trim();
      if (driverName.isEmpty ||
          controller.vehicleController.text.trim().isEmpty) return;

      var existingDriver = controller.addedRows.where(
        (row) => row['Driver Name'] == driverName,
      );

      String driverId;
      if (existingDriver.isEmpty) {
        driverId = controller.nextId.toString();
        controller.nextId++;
      } else {
        driverId = existingDriver.first['#'];
      }

      setState(() {
        controller.addedRows.add({
          '#': driverId,
          'Driver Name': driverName,
          'Vehicle Name': controller.vehicleController.text,
          'Location': controller.locationController.text,
          'Time Work': controller.timeWorkController.text,
          'Amount': controller.amountController.text,
          'Shifting Charge': controller.shiftingChargeController.text,
          'Driver Salary': controller.driverSalaryController.text,
          'Driver Bata': controller.driverBataController.text,
          'Payment Type': controller.selectedPayment,
          'Status': controller.selectedStatus,
        });

        // Clear input fields
        controller.driverController.clear();
        controller.vehicleController.clear();
        controller.locationController.clear();
        controller.timeWorkController.clear();
        controller.amountController.clear();
        controller.shiftingChargeController.clear();
        controller.driverSalaryController.clear();
        controller.driverBataController.clear();
        controller.selectedPayment = 'Cash';
        controller.selectedStatus = 'Pending';
      });
    }

    final entryRow = [
      {
        '#': const Text('#'),
        'Driver Name': IOUtils.fields("", "", controller.driverController,
            onlybox: true, borderless: true, height: 35, width: 120),
        'Vehicle Name': IOUtils.fields("", "", controller.vehicleController,
            onlybox: true, borderless: true, height: 35, width: 120),
        'Location': IOUtils.fields("", "", controller.locationController,
            onlybox: true, borderless: true, height: 35, width: 100),
        'Time Work': IOUtils.fields("", "", controller.timeWorkController,
            onlybox: true, borderless: true, height: 35, width: 90),
        'Amount': IOUtils.fields("", "", controller.amountController,
            onlybox: true,
            borderless: true,
            height: 35,
            width: 90,
            keyboardType: TextInputType.number),
        'Shifting Charge': IOUtils.fields(
            "", "", controller.shiftingChargeController,
            onlybox: true,
            borderless: true,
            height: 35,
            width: 100,
            keyboardType: TextInputType.number),
        'Driver Salary': IOUtils.fields(
            "", "", controller.driverSalaryController,
            onlybox: true,
            borderless: true,
            height: 35,
            width: 100,
            keyboardType: TextInputType.number),
        'Driver Bata': IOUtils.fields("", "", controller.driverBataController,
            onlybox: true,
            borderless: true,
            height: 35,
            width: 100,
            keyboardType: TextInputType.number),
        'Payment Type': IOUtils.typeAheadField<String>(
          "",
          "Select Payment Type",
          (term) async => paymentOptions
              .where((e) => e.toLowerCase().contains(term.toLowerCase()))
              .toList(),
          (value) => controller.updatePaymentType(value),
          (value) => value ?? '',
          controller.selectedPayment,
          onlybox: true,
          borderless: true,
          height: 35,
          width: 100,
        ),
        'Status': IOUtils.typeAheadField<String>(
          "",
          "",
          (value) async => statusOptions
              .where((e) => e.toLowerCase().contains(value.toLowerCase()))
              .toList(),
          controller.updateStatus,
          (value) => value ?? '',
          controller.selectedStatus,
          onlybox: true,
          borderless: true,
          height: 35,
          width: 100,
        ),
      }
    ];

    Widget entryTable() {
      return IOUtils.dataTable<Map<String, dynamic>>(
        headers,
        [
          (r) => r['#'],
          (r) => r['Driver Name'],
          (r) => r['Vehicle Name'],
          (r) => r['Location'],
          (r) => r['Time Work'],
          (r) => r['Amount'],
          (r) => r['Shifting Charge'],
          (r) => r['Driver Salary'],
          (r) => r['Driver Bata'],
          (r) => r['Payment Type'],
          (r) => r['Status'],
        ],
        entryRow,
        context,
        isaction: true,
        actionList: [
          TableAction(
            iconData: Icons.add_circle_outline,
            color: Colors.green,
            function: (_) => addRow(),
          ),
        ],
      );
    }

    Map<String, List<Map<String, dynamic>>> groupedByDriver = {};
    for (var row in controller.addedRows) {
      final driver = row['Driver Name'];
      groupedByDriver.putIfAbsent(driver, () => []);
      groupedByDriver[driver]!.add(row);
    }

    List<Map<String, dynamic>> allRows = [];
    groupedByDriver.forEach((driver, rows) {
      for (int i = 0; i < rows.length; i++) {
        final row = Map<String, dynamic>.from(rows[i]);
        if (i > 0) {
          row['#'] = '';
          row['Driver Name'] = '';
        }
        allRows.add(row);
      }

      double totalSalary = 0;
      double totalAmount = 0;
      double totalTime = 0;

      for (var r in rows) {
        totalSalary += double.tryParse(r['Driver Salary'] ?? '0') ?? 0;
        totalAmount += double.tryParse(r['Amount'] ?? '0') ?? 0;
        totalTime += double.tryParse(r['Time Work'] ?? '0') ?? 0;
      }

      allRows.add({
        '#': const MyText.bodyMedium('Total', fontWeight: 700),
        'Driver Name': MyText.bodyMedium(driver, fontWeight: 700),
        'Vehicle Name': const Text(''),
        'Location': const Text(''),
        'Time Work': MyText.bodyMedium('₹${totalTime.toStringAsFixed(2)}',
            fontWeight: 700),
        'Amount': MyText.bodyMedium('₹${totalAmount.toStringAsFixed(2)}',
            fontWeight: 700),
        'Shifting Charge': const Text(''),
        'Driver Salary': MyText.bodyMedium('₹${totalSalary.toStringAsFixed(2)}',
            fontWeight: 700),
        'Driver Bata': const Text(''),
        'Payment Type': const Text(''),
        'Status': const Text(''),
        '_isTotalRow': true,
      });
    });

    Widget displayTable() {
      if (controller.addedRows.isEmpty) {
        return Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Text(
            "No records added yet",
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return IOUtils.dataTable<Map<String, dynamic>>(
        headers,
        [
          (r) => r['#'],
          (r) => r['Driver Name'],
          (r) => r['Vehicle Name'],
          (r) => r['Location'],
          (r) => r['Time Work'],
          (r) => r['Amount'],
          (r) => r['Shifting Charge'],
          (r) => r['Driver Salary'],
          (r) => r['Driver Bata'],
          (r) => r['Payment Type'],
          (r) => r['Status'],
        ],
        allRows,
        context,
        showHeader: false,
        isdefault: (r) => r['_isTotalRow'] == true,
        isDefaultcolor: (r) => Colors.amber.shade200,
        isaction: true,
        actionList: [
          TableAction(
            iconData: Icons.delete_outline,
            color: Colors.redAccent,
            function: (row) {
              if (row['_isTotalRow'] == true) return;
              setState(() {
                controller.addedRows.remove(row);
              });
            },
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        entryTable(),
        const SizedBox(height: 16),
        displayTable(),
      ],
    );
  }



}
