import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/dashboard/hr/leaves_list_controller.dart';
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
import 'package:LeLaundrette/helpers/widgets/my_list_extension.dart';
import 'package:LeLaundrette/helpers/widgets/my_spacing.dart';
import 'package:LeLaundrette/helpers/widgets/my_text.dart';
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

class LeavesListScreen extends StatefulWidget {
  const LeavesListScreen({super.key});

  @override
  State<LeavesListScreen> createState() => _LeavesListScreenState();
}

class _LeavesListScreenState extends State<LeavesListScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late LeavesListController controller = Get.put(LeavesListController());
  late OutlineInputBorder _outlineInputBorder;
  late ToastMessageController toastcontroller;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _outlineInputBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      );
      toastcontroller = ToastMessageController(this);
      await controller.loadData();
    });
    super.initState();
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
                            "HR",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Dashboard'),
                              MyBreadcrumbItem(name: 'Leaves'),
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
                MyContainer(
                  width: 200,
                  height: 35,
                  padding: MySpacing.zero,
                  child: MyButton.block(
                      elevation: 0.5,
                      onPressed: () async {
                        controller.setData(null);
                        addLeave();
                      },
                      backgroundColor: contentTheme.primary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.plusSquare,
                            color: contentTheme.onPrimary,
                            size: 20,
                          ),
                          MyText.bodyMedium(
                            'Add Leave',
                            fontSize: 12,
                            color: contentTheme.onPrimary,
                          ),
                        ],
                      )),
                ),
                IOUtils.fields(
                  "Search",
                  "Search",
                  controller.searchcontroller,
                  onlybox: true,
                  onChanged: (value) => controller.loadVoucher(),
                ),
              ],
            ),
            MySpacing.height(8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: constrains.maxWidth > 700
                        ? constrains.maxWidth - 46
                        : 1000),
                child: DataTable(
                    sortAscending: true,
                    onSelectAll: (_) => {},
                    headingRowColor: WidgetStatePropertyAll(
                        contentTheme.primary.withAlpha(40)),
                    dataRowMaxHeight: 40,
                    dataRowMinHeight: 30,
                    showBottomBorder: true,
                    headingRowHeight: 40,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    border: TableBorder.all(
                        borderRadius: BorderRadius.circular(8),
                        style: BorderStyle.solid,
                        width: .4,
                        color: Colors.grey),
                    columns: [
                      DataColumn(
                          label: MyText.labelLarge(
                        'Voucher No',
                        fontSize: 12,
                        color: contentTheme.primary,
                      )),
                      DataColumn(
                          label: MyText.labelLarge(
                        fontSize: 12,
                        'Date',
                        color: contentTheme.primary,
                      )),
                      DataColumn(
                          label: MyText.labelLarge(
                        'Driver',
                        fontSize: 12,
                        color: contentTheme.primary,
                      )),
                      DataColumn(
                          label: MyText.labelLarge(
                        'Vehicle',
                        fontSize: 12,
                        color: contentTheme.primary,
                      )),
                      DataColumn(
                          label: MyText.labelLarge(
                        'Leave Days',
                        fontSize: 12,
                        color: contentTheme.primary,
                      )),
                      DataColumn(
                          label: MyText.labelLarge(
                        'Amount',
                        fontSize: 12,
                        color: contentTheme.primary,
                      )),
                      DataColumn(
                          label: MyText.labelLarge(
                        'Reference',
                        fontSize: 12,
                        color: contentTheme.primary,
                      )),
                      DataColumn(
                          label: MyText.labelLarge(
                        'Created By',
                        fontSize: 12,
                        color: contentTheme.primary,
                      )),
                      DataColumn(
                          label: MyText.labelLarge(
                        'Branch',
                        fontSize: 12,
                        color: contentTheme.primary,
                      )),
                      DataColumn(
                          label: MyText.labelLarge(
                        'Action',
                        fontSize: 12,
                        color: contentTheme.primary,
                      )),
                    ],
                    rows: controller.data
                        .mapIndexed((index, data) => DataRow(
                                color: WidgetStateProperty.all(
                                  Colors.transparent,
                                ),
                                cells: [
                                  DataCell(MyText.labelMedium(
                                      data["file_id"].toString(),
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      fontWeight: 600)),
                                  DataCell(MyText.labelMedium(
                                      DateFormat('dd MMM yyyy').format(
                                          DateTime.parse(
                                              data["voucher_date"].toString())),
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      fontWeight: 600)),
                                  DataCell(MyText.labelMedium(
                                      data["subledger_name"].toString(),
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      fontWeight: 600)),
                                  DataCell(MyText.labelMedium(
                                      data["vehicle_name"].toString(),
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      fontWeight: 600)),
                                  DataCell(MyText.labelMedium(
                                      data["leave_days"].toString(),
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      fontWeight: 600)),
                                  DataCell(MyText.labelMedium(
                                      data["voucher_value"].toString(),
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      fontWeight: 600)),
                                  DataCell(MyText.labelMedium(
                                      data["referrence_id"].toString(),
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      color: Colors.red,
                                      fontWeight: 600)),
                                  DataCell(MyText.labelMedium(
                                      data["created_by_name"].toString(),
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      fontWeight: 600)),
                                  DataCell(MyText.labelMedium(
                                      data["branch_name"].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 10,
                                      maxLines: 1,
                                      fontWeight: 600)),
                                  DataCell(SizedBox(
                                    width: 150,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        PermissionHandler(
                                          permission: 'hr_leave_edit',
                                          child: MyContainer(
                                            onTap: () async {
                                              controller.setLoading(true);
                                              controller.setData(data);
                                              controller.setLoading(false);
                                              editLeave(data);
                                            },
                                            padding: MySpacing.xy(8, 8),
                                            color: contentTheme.warning
                                                .withAlpha(36),
                                            child: Icon(
                                              LucideIcons.edit,
                                              size: 14,
                                              color: contentTheme.warning,
                                            ),
                                          ),
                                        ),
                                        MySpacing.width(10),
                                        PermissionHandler(
                                          permission: 'hr_leave_delete',
                                          child: MyContainer(
                                            onTap: () async {
                                              await DeleteView.deleteDialog(
                                                  '',
                                                  '',
                                                  'Leave',
                                                  toastMessage,
                                                  () {
                                                    controller.loadData();
                                                  },
                                                  context,
                                                  () async {
                                                    final response =
                                                        await APIService
                                                            .deleteVoucher(data[
                                                                    'file_id']
                                                                .toString());
                                                    return response;
                                                  });
                                              controller.setLoading(false);
                                            },
                                            padding: MySpacing.xy(8, 8),
                                            color: contentTheme.danger
                                                .withAlpha(36),
                                            child: Icon(
                                              LucideIcons.ban,
                                              size: 14,
                                              color: contentTheme.danger,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ]))
                        .toList()),
              ),
            ),
            MySpacing.height(10),
            FlutterCustomPagination(
              currentPage: controller.pagenumber,
              limitPerPage: controller.pagelimit,
              totalDataCount: controller.totalcount,
              onPreviousPage: controller.setPageNumber,
              onBackToFirstPage: controller.setPageNumber,
              onNextPage: controller.setPageNumber,
              onGoToLastPage: controller.setPageNumber,
              backgroundColor: Theme.of(context).colorScheme.surface,
              textStyle: const TextStyle(
                fontSize: 12,
                overflow: TextOverflow.ellipsis,
              ),
              previousPageIcon: Icons.keyboard_arrow_left,
              backToFirstPageIcon: Icons.first_page,
              nextPageIcon: Icons.keyboard_arrow_right,
              goToLastPageIcon: Icons.last_page,
            ),
          ],
        ),
      );
    });
  }

  void editLeave(Map<String, dynamic> details) {
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
                          width: 900,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: MyText.labelLarge(
                                  'Edit Leave',
                                  fontWeight: 600,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                  padding: MySpacing.xy(0, 0),
                                  child: MyContainer(
                                    child: Wrap(
                                        children: [
                                      IOUtils.typeAheadField<dynamic>(
                                          "Driver",
                                          "Select Driver",
                                          (term) =>
                                              controller.selectDriverList(term),
                                          controller.setSelectedDriver,
                                          (value) => "${value['name']}",
                                          controller.selecteddriver,
                                          readOnly: details["referrence_id"]
                                                  .toString()
                                                  .isNotEmpty
                                              ? true
                                              : false),
                                      IOUtils.typeAheadField<dynamic>(
                                        readOnly: details["referrence_id"]
                                                .toString()
                                                .isNotEmpty
                                            ? true
                                            : controller.selecteddriver == null
                                                ? true
                                                : false,
                                        "Vehicle",
                                        "Select Vehicle",
                                        (term) =>
                                            controller.selectVehicleList(term),
                                        controller.setSelectedVehicle,
                                        (value) =>
                                            "${value["registration"]} / ${value['name']}",
                                        controller.selectedvehicle,
                                      ),
                                      IOUtils.dateField(
                                          "Voucher Date",
                                          "Select Date",
                                          context,
                                          controller.setLeaveDate,
                                          APIService.formatDate,
                                          controller.voucherdate,
                                          readOnly: details["referrence_id"]
                                                  .toString()
                                                  .isNotEmpty
                                              ? true
                                              : false),
                                      IOUtils.fields(
                                          readOnly:
                                              controller.selectedvehicle == null
                                                  ? true
                                                  : false,
                                          "Leave Days",
                                          "Leave Days",
                                          controller.leavedayscontroller,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]')),
                                          ], onChanged: (val) {
                                        controller.calculateDeductionAmount();
                                      }),
                                      IOUtils.fields(
                                          "Deduction Amount",
                                          "Deduction Amount",
                                          controller.deductionamountcontroller,
                                          readOnly: true,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]')),
                                          ]),
                                    ]
                                            .map((e) => Padding(
                                                padding: MySpacing.all(5),
                                                child: e))
                                            .toList()),
                                  )),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                child: MyText.labelLarge(
                                  'Reason / Complaint',
                                  fontWeight: 600,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                padding: MySpacing.xy(0, 0),
                                child: MyContainer(
                                  child: Wrap(
                                      children: [
                                    IOUtils.fields(
                                      "Notes",
                                      "Notes",
                                      controller.notescontroller,
                                      minlines: 4,
                                      maxlines: 6,
                                    ),
                                  ]
                                          .map((e) => Padding(
                                              padding: MySpacing.all(5),
                                              child: e))
                                          .toList()),
                                ),
                              ),
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
                                    MyButton(
                                      onPressed: () async {
                                        if (controller.selecteddriver == null) {
                                          toastMessage("Please select driver",
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller.selectedvehicle ==
                                            null) {
                                          toastMessage("Please select vehicle",
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller.currency.isEmpty) {
                                          toastMessage("Please select currency",
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller.tax.isEmpty) {
                                          toastMessage("Please select tax",
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (num.parse(controller
                                                    .leavedayscontroller
                                                    .text
                                                    .isEmpty
                                                ? "0"
                                                : controller.leavedayscontroller
                                                    .text) <=
                                            0) {
                                          toastMessage(
                                              "Please enter leave days",
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller.deductionamountcontroller
                                            .text.isEmpty) {
                                          toastMessage("Please enter amount",
                                              contentTheme.danger);
                                          return;
                                        }
                                        controller.setLoading(true);
                                        final dynamic response =
                                            await controller.editLeaveVoucher(
                                                details["id"].toString());

                                        if (response["status"] == "success") {
                                          toastMessage(response['message'],
                                              contentTheme.success);
                                          controller.loadData();
                                          Get.back();
                                        } else {
                                          toastMessage(response['message'],
                                              contentTheme.danger);
                                        }
                                        controller.setLoading(false);
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
                              ),
                            ],
                          ),
                        ),
                );
              });
        });
  }

  void addLeave() {
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
                          width: 900,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: MyText.labelLarge(
                                  'Add Leave',
                                  fontWeight: 600,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                  padding: MySpacing.xy(0, 0),
                                  child: MyContainer(
                                    child: Wrap(
                                        children: [
                                      IOUtils.typeAheadField<dynamic>(
                                          "Driver",
                                          "Select Driver",
                                          (term) =>
                                              controller.selectDriverList(term),
                                          controller.setSelectedDriver,
                                          (value) => "${value['name']}",
                                          controller.selecteddriver),
                                      IOUtils.typeAheadField<dynamic>(
                                          readOnly:
                                              controller.selecteddriver == null
                                                  ? true
                                                  : false,
                                          "Vehicle",
                                          "Select Vehicle",
                                          (term) => controller
                                              .selectVehicleList(term),
                                          controller.setSelectedVehicle,
                                          (value) =>
                                              "${value["registration"]} / ${value['name']}",
                                          controller.selectedvehicle),
                                      IOUtils.dateField(
                                        "Leave Date",
                                        "Select Date",
                                        context,
                                        controller.setLeaveDate,
                                        APIService.formatDate,
                                        controller.voucherdate,
                                      ),
                                      IOUtils.fields(
                                          readOnly:
                                              controller.selectedvehicle == null
                                                  ? true
                                                  : false,
                                          "Leave Days",
                                          "Leave Days",
                                          controller.leavedayscontroller,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]')),
                                          ], onChanged: (val) {
                                        controller.calculateDeductionAmount();
                                      }),
                                      IOUtils.fields(
                                          "Deduction Amount",
                                          "Deduction Amount",
                                          controller.deductionamountcontroller,
                                          readOnly: true,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]')),
                                          ]),
                                    ]
                                            .map((e) => Padding(
                                                padding: MySpacing.all(5),
                                                child: e))
                                            .toList()),
                                  )),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                child: MyText.labelLarge(
                                  'Reason / Complaint',
                                  fontWeight: 600,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                padding: MySpacing.xy(0, 0),
                                child: MyContainer(
                                  child: Wrap(
                                      children: [
                                    IOUtils.fields(
                                      "Notes",
                                      "Notes",
                                      controller.notescontroller,
                                      minlines: 4,
                                      maxlines: 6,
                                    ),
                                  ]
                                          .map((e) => Padding(
                                              padding: MySpacing.all(5),
                                              child: e))
                                          .toList()),
                                ),
                              ),
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
                                    MyButton(
                                      onPressed: () async {
                                        if (controller.selecteddriver == null) {
                                          toastMessage("Please select driver",
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller.selectedvehicle ==
                                            null) {
                                          toastMessage("Please select vehicle",
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller.currency.isEmpty) {
                                          toastMessage("Please select currency",
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller.tax.isEmpty) {
                                          toastMessage("Please select tax",
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (num.parse(controller
                                                    .leavedayscontroller
                                                    .text
                                                    .isEmpty
                                                ? "0"
                                                : controller.leavedayscontroller
                                                    .text) <=
                                            0) {
                                          toastMessage(
                                              "Please enter leave days",
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller.deductionamountcontroller
                                            .text.isEmpty) {
                                          toastMessage("Please enter amount",
                                              contentTheme.danger);
                                          return;
                                        }
                                        controller.setLoading(true);
                                        final dynamic response =
                                            await controller.saveLeaveVoucher();

                                        if (response["status"] == "success") {
                                          toastMessage(response['message'],
                                              contentTheme.success);
                                          controller.loadData();
                                          Get.back();
                                        } else {
                                          toastMessage(response['message'],
                                              contentTheme.danger);
                                        }
                                        controller.setLoading(false);
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
                              ),
                            ],
                          ),
                        ),
                );
              });
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
