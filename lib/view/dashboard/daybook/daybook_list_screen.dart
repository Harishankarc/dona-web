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
  late RentalListController controller = Get.put(RentalListController());
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
                  (value) => value['subledger_name'],
                  (value) => APIService.formatDate(APIService.stringToDate(
                      value['voucher_delivery_date'].toString())),
                  (value) => MyText.labelMedium(
                      controller.statusMap[value['status']].toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      fontSize: 11,
                      color: controller.statusColorMap[value['status']] ??
                          Colors.black,
                      fontWeight: 600),
                ],
                controller.data,
                context,
                isaction: true,
                actionwidth: 500,
                actionList: [
                  TableAction(
                    permission: 'rentals_rentals_view',
                    function: (data) async {
                      controller.setLoading(true);
                      final requestresponse =
                          await controller.setVoucherData(data);
                      controller.setLoading(false);
                      if (requestresponse['status'] == 'success') {
                        viewVoucher(data, requestresponse['data']);
                      } else {
                        toastMessage(
                            requestresponse['message'], contentTheme.danger);
                      }
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

  void viewVoucher(dynamic data, dynamic items) {
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
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: MyText.labelLarge(
                                  'Voucher ID  ${data['file_id']}',
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
                                      Wrap(
                                        alignment: WrapAlignment.start,
                                        children: [
                                          IOUtils.fields(
                                              "Customer Name",
                                              "Customer Name",
                                              TextEditingController(
                                                  text: data['subledger_name']),
                                              readOnly: true),
                                          IOUtils.dateField(
                                              "Voucher Date",
                                              "Voucher Date",
                                              context,
                                              (data) {},
                                              APIService.formatDate,
                                              APIService.stringToDate(
                                                  data['voucher_date']
                                                      .toString()),
                                              readOnly: true),
                                          IOUtils.dateField(
                                              "Start Date",
                                              "Start Date",
                                              context,
                                              (data) {},
                                              APIService.formatDate,
                                              APIService.stringToDate(
                                                  data['voucher_delivery_date']
                                                      .toString()),
                                              readOnly: true),
                                          IOUtils.fields(
                                              "Salesman",
                                              "Salesman",
                                              TextEditingController(
                                                  text: data['created_by_name']
                                                      .toString()),
                                              readOnly: true),
                                          IOUtils.fields(
                                              "Remarks",
                                              "Remarks",
                                              TextEditingController(
                                                  text: data['remarks']),
                                              readOnly: true),
                                        ]
                                            .map((e) => Padding(
                                                  padding: MySpacing.all(5),
                                                  child: e,
                                                ))
                                            .toList(),
                                      ),
                                      MySpacing.height(10),
                                      IOUtils.dataTable2<dynamic>(
                                          [
                                            "Item Code",
                                            "Item Name",
                                            "Quantity",
                                            "Price/Day",
                                          ],
                                          items,
                                          [
                                            (value) =>
                                                value['item_code'].toString(),
                                            (value) =>
                                                value['item_name'].toString(),
                                            (value) =>
                                                '${value['quantity']} ${value['unit_name']}',
                                            (value) => value['rate'].toString(),
                                          ])
                                    ],
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
