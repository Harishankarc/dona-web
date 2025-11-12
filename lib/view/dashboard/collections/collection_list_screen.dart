import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/dashboard/collections/collection_list_controller.dart';
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

class CollectionsListScreen extends StatefulWidget {
  const CollectionsListScreen({super.key});

  @override
  State<CollectionsListScreen> createState() => _CollectionsListScreenState();
}

class _CollectionsListScreenState extends State<CollectionsListScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late CollectionsListController controller =
      Get.put(CollectionsListController());
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
                            "Collections",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Dashboard'),
                              MyBreadcrumbItem(name: 'Collections'),
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
                        addCollection();
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
                            'Add Collection',
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
                        'Collection No',
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
                        'Amount',
                        fontSize: 12,
                        color: contentTheme.primary,
                      )),
                      DataColumn(
                          label: MyText.labelLarge(
                        'Payment Type',
                        fontSize: 12,
                        color: contentTheme.primary,
                      )),
                      DataColumn(
                          label: MyText.labelLarge(
                        'Collected By',
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
                                      data["voucher_value"].toString(),
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      fontWeight: 600)),
                                  DataCell(MyText.labelMedium(
                                      data["payment_type_name"].toString(),
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
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
                                          permission:
                                              'collection_collection_edit',
                                          child: MyContainer(
                                            onTap: () async {
                                              controller.setLoading(true);
                                              await controller.setData(data);
                                              controller.setLeaveVoucherData(
                                                  data["file_id"].toString());
                                              controller.setLoading(false);
                                              editCollection(data);
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
                                          permission:
                                              'collection_collection_delete',
                                          child: MyContainer(
                                            onTap: () async {
                                              await DeleteView.deleteDialog(
                                                  '',
                                                  '',
                                                  'Collection',
                                                  toastMessage,
                                                  () {
                                                    controller.loadData();
                                                  },
                                                  context,
                                                  () async {
                                                    final response = await APIService
                                                        .deleteVoucherByFileIDByRef(
                                                            data['file_id']
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

  void addCollection() {
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
                          width: 1200,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: MyText.labelLarge(
                                  'Add Collection',
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
                                          "Vehicle",
                                          "Select Vehicle",
                                          (term) => controller
                                              .selectVehicleList(term),
                                          controller.setSelectedVehicle,
                                          (value) =>
                                              "${value["registration"]} / ${value['name']}",
                                          controller.selectedvehicle),
                                      controller.selectedvehicle == null
                                          ? SizedBox()
                                          : IOUtils.statusBox(
                                              "Chasis Number",
                                              "Chasis Number",
                                              controller.selectedvehicle == null
                                                  ? "-"
                                                  : controller.selectedvehicle[
                                                          "chasis_number"]
                                                      .toString(),
                                              Colors.black),
                                      controller.selectedvehicle == null
                                          ? SizedBox()
                                          : IOUtils.statusBox(
                                              "Engine Number",
                                              "Engine Number",
                                              controller.selectedvehicle == null
                                                  ? "-"
                                                  : controller.selectedvehicle[
                                                          "engine_number"]
                                                      .toString(),
                                              Colors.black),
                                      controller.selectedvehicle == null
                                          ? SizedBox()
                                          : IOUtils.statusBox(
                                              "Driver",
                                              "Driver",
                                              controller.selectedvehicle == null
                                                  ? "-"
                                                  : controller.selectedvehicle[
                                                          "assigned_to_name"]
                                                      .toString(),
                                              Colors.black),
                                    ]
                                            .map((e) => Padding(
                                                padding: MySpacing.all(5),
                                                child: e))
                                            .toList()),
                                  )),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                child: MyText.labelLarge(
                                  'Collection Details',
                                  fontWeight: 600,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                padding: MySpacing.xy(0, 0),
                                child: MyContainer(
                                  child: Wrap(
                                      children: [
                                    IOUtils.dateField(
                                      "Collection Date",
                                      "Select Date",
                                      context,
                                      controller.setCollectionDate,
                                      APIService.formatDate,
                                      controller.voucherdate,
                                    ),
                                    IOUtils.statusBox(
                                        "Caution Deposit",
                                        "Caution Deposit",
                                        controller.selectedvehicle == null
                                            ? "-"
                                            : controller.selectedvehicle[
                                                    "advance_amount"]
                                                .toString(),
                                        Colors.black),
                                    IOUtils.statusBox(
                                        "Balance",
                                        "Balance",
                                        controller.driverbalance.isEmpty
                                            ? "-"
                                            : controller
                                                .driverbalance["balance_amount"]
                                                .toString(),
                                        Colors.red),
                                    IOUtils.typeAheadField<PaymentTypeModel>(
                                      "Payment Type",
                                      "Select Payment Type",
                                      (value) =>
                                          APIService.getPaymentTypeQueryList(
                                              value),
                                      controller.setPaymentType,
                                      (value) => value!.name,
                                      controller.selectedpaymenttype,
                                    ),
                                    IOUtils.fields("Paid Amount", "Paid Amount",
                                        controller.paidamountcontroller,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.]')),
                                        ]),
                                  ]
                                          .map((e) => Padding(
                                              padding: MySpacing.all(5),
                                              child: e))
                                          .toList()),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                child: MyText.labelLarge(
                                  'Attendance',
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
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                child: MyText.labelLarge(
                                  'More Information',
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
                                        if (controller.selectedpaymenttype ==
                                            null) {
                                          toastMessage(
                                              "Please select payment type",
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller.paidamountcontroller.text
                                            .isEmpty) {
                                          toastMessage("Please enter amount",
                                              contentTheme.danger);
                                          return;
                                        }
                                        controller.setLoading(true);
                                        final dynamic response =
                                            await controller
                                                .savePaymentCollection();

                                        if (response["status"] == "success") {
                                          if (num.parse(controller
                                                      .leavedayscontroller
                                                      .text
                                                      .isEmpty
                                                  ? "0"
                                                  : controller
                                                      .leavedayscontroller
                                                      .text) >
                                              0) {
                                            final dynamic leavevoucherresponse =
                                                await controller
                                                    .saveLeaveVoucher(
                                                        response["file_id"]
                                                            .toString());
                                            if (leavevoucherresponse[
                                                    "status"] ==
                                                "success") {
                                              toastMessage(
                                                  "Collection added successfully",
                                                  contentTheme.success);
                                              controller.loadData();
                                              Get.back();
                                            } else {
                                              toastMessage(
                                                  leavevoucherresponse[
                                                      'message'],
                                                  contentTheme.danger);
                                            }
                                          } else {
                                            toastMessage(response['message'],
                                                contentTheme.success);
                                            controller.loadData();
                                            Get.back();
                                          }
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

  void editCollection(Map<String, dynamic> details) {
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
                          width: 1200,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: MyText.labelLarge(
                                  'Edit Collection',
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
                                          "Vehicle",
                                          "Select Vehicle",
                                          (term) => controller
                                              .selectVehicleList(term),
                                          controller.setSelectedVehicle,
                                          (value) =>
                                              "${value["registration"]} / ${value['name']}",
                                          controller.selectedvehicle),
                                      controller.selectedvehicle == null
                                          ? SizedBox()
                                          : IOUtils.statusBox(
                                              "Chasis Number",
                                              "Chasis Number",
                                              controller.selectedvehicle == null
                                                  ? "-"
                                                  : controller.selectedvehicle[
                                                          "chasis_number"]
                                                      .toString(),
                                              Colors.black),
                                      controller.selectedvehicle == null
                                          ? SizedBox()
                                          : IOUtils.statusBox(
                                              "Engine Number",
                                              "Engine Number",
                                              controller.selectedvehicle == null
                                                  ? "-"
                                                  : controller.selectedvehicle[
                                                          "engine_number"]
                                                      .toString(),
                                              Colors.black),
                                      controller.selectedvehicle == null
                                          ? SizedBox()
                                          : IOUtils.statusBox(
                                              "Driver",
                                              "Driver",
                                              controller.selectedvehicle == null
                                                  ? "-"
                                                  : controller.selectedvehicle[
                                                          "assigned_to_name"]
                                                      .toString(),
                                              Colors.black),
                                    ]
                                            .map((e) => Padding(
                                                padding: MySpacing.all(5),
                                                child: e))
                                            .toList()),
                                  )),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                child: MyText.labelLarge(
                                  'Collection Details',
                                  fontWeight: 600,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                padding: MySpacing.xy(0, 0),
                                child: MyContainer(
                                  child: Wrap(
                                      children: [
                                    IOUtils.dateField(
                                      "Collection Date",
                                      "Select Date",
                                      context,
                                      controller.setCollectionDate,
                                      APIService.formatDate,
                                      controller.voucherdate,
                                    ),
                                    IOUtils.statusBox(
                                        "Caution Deposit",
                                        "Caution Deposit",
                                        controller.selectedvehicle == null
                                            ? "-"
                                            : controller.selectedvehicle[
                                                    "advance_amount"]
                                                .toString(),
                                        Colors.black),
                                    IOUtils.statusBox(
                                        "Balance",
                                        "Balance",
                                        controller.driverbalance.isEmpty
                                            ? "-"
                                            : controller
                                                .driverbalance["balance_amount"]
                                                .toString(),
                                        Colors.red),
                                    IOUtils.typeAheadField<PaymentTypeModel>(
                                      "Payment Type",
                                      "Select Payment Type",
                                      (value) =>
                                          APIService.getPaymentTypeQueryList(
                                              value),
                                      controller.setPaymentType,
                                      (value) => value!.name,
                                      controller.selectedpaymenttype,
                                    ),
                                    IOUtils.fields("Paid Amount", "Paid Amount",
                                        controller.paidamountcontroller,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.]')),
                                        ]),
                                  ]
                                          .map((e) => Padding(
                                              padding: MySpacing.all(5),
                                              child: e))
                                          .toList()),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                child: MyText.labelLarge(
                                  'Attendance',
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
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                child: MyText.labelLarge(
                                  'More Information',
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
                                        if (controller.selectedpaymenttype ==
                                            null) {
                                          toastMessage(
                                              "Please select payment type",
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller.paidamountcontroller.text
                                            .isEmpty) {
                                          toastMessage("Please enter amount",
                                              contentTheme.danger);
                                          return;
                                        }
                                        controller.setLoading(true);
                                        final dynamic response =
                                            await controller
                                                .editPaymentCollection(
                                                    details["id"].toString());

                                        if (response["status"] == "success") {
                                          final dynamic leavevoucherresponse =
                                              await controller
                                                  .editLeaveVoucherByReferrenceID(
                                                      details["file_id"]
                                                          .toString());
                                          if (leavevoucherresponse["status"] ==
                                              "success") {
                                            if (leavevoucherresponse["type"]
                                                    .toString() ==
                                                "A") {
                                              if (num.parse(controller
                                                          .leavedayscontroller
                                                          .text
                                                          .isEmpty
                                                      ? "0"
                                                      : controller
                                                          .leavedayscontroller
                                                          .text) >
                                                  0) {
                                                final dynamic
                                                    addleavevoucherresponse =
                                                    await controller
                                                        .saveLeaveVoucher(
                                                            details["file_id"]
                                                                .toString());
                                                if (addleavevoucherresponse[
                                                        "status"] ==
                                                    "success") {
                                                  toastMessage(
                                                      "Collection updated successfully",
                                                      contentTheme.success);
                                                  controller.loadData();
                                                  Get.back();
                                                } else {
                                                  toastMessage(
                                                      addleavevoucherresponse[
                                                          'message'],
                                                      contentTheme.danger);
                                                }
                                              } else {
                                                toastMessage(
                                                    "Collection updated successfully",
                                                    contentTheme.success);
                                                controller.loadData();
                                                Get.back();
                                              }
                                            } else {
                                              toastMessage(
                                                  "Collection updated successfully",
                                                  contentTheme.success);
                                              controller.loadData();
                                              Get.back();
                                            }
                                          } else {
                                            Get.back();
                                            toastMessage(
                                                leavevoucherresponse['message'],
                                                contentTheme.danger);
                                          }
                                        } else {
                                          Get.back();
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
                                        "Update",
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
