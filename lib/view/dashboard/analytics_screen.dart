import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/dashboard/analytics_controller.dart';
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
import 'package:LeLaundrette/model/paymenttype_model.dart';
import 'package:LeLaundrette/view/layouts/layout.dart';
import 'package:LeLaundrette/view/ui/input_output_utils.dart';
import 'package:LeLaundrette/view/ui/toast_message_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late ToastMessageController toastcontroller;

  late AnalyticsController controller = Get.put(AnalyticsController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      toastcontroller = ToastMessageController(this);
      // await controller.fetchData();
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
        builder: (controller) {
          return controller.isLoading
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
                        const Row(
                          children: [
                            MyText.titleMedium(
                              "Dashboard",
                              fontSize: 18,
                              fontWeight: 600,
                            ),
                          ],
                        ),
                        MyBreadcrumb(
                          children: [
                            MyBreadcrumbItem(name: 'Dashboard'),
                            MyBreadcrumbItem(name: 'Analytics'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  MySpacing.height(flexSpacing),
                  controller.isLoading
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
                      : Padding(
                          padding: MySpacing.x(flexSpacing / 2),
                          child: MyFlex(
                            children: [
                              MyFlexItem(
                                sizes: 'lg-4 md-6',
                                child: buildOverView(
                                  LucideIcons.badgeDollarSign,
                                  Colors.brown,
                                  "Total Sales Amount",
                                  (controller.data?['total_collected_amount'] ??
                                          0)
                                      .toString(),
                                  LucideIcons.trendingUp,
                                  contentTheme.success,
                                  '8%',
                                ),
                              ),
                              MyFlexItem(
                                sizes: 'lg-4 md-6',
                                child: buildOverView(
                                  LucideIcons.badgeDollarSign,
                                  Colors.teal,
                                  "Today's Sales Amount",
                                  (controller.data?['today_collected_amount'] ??
                                          0)
                                      .toString(),
                                  LucideIcons.trendingUp,
                                  contentTheme.success,
                                  '8%',
                                ),
                              ),
                              MyFlexItem(
                                sizes: 'lg-4 md-6',
                                child: buildOverView(
                                  LucideIcons.truck,
                                  contentTheme.primary,
                                  "Total Vehicles",
                                  (controller.data?['total_vehicles_count'] ??
                                          0)
                                      .toString(),
                                  LucideIcons.trendingUp,
                                  contentTheme.success,
                                  '12%',
                                ),
                              ),
                              MyFlexItem(
                                sizes: 'lg-4 md-6',
                                child: buildOverView(
                                  LucideIcons.users2,
                                  Colors.purpleAccent,
                                  "Total Drivers",
                                  (controller.data?['total_drivers_count'] ?? 0)
                                      .toString(),
                                  LucideIcons.trendingDown,
                                  contentTheme.danger,
                                  '8%',
                                ),
                              ),
                              MyFlexItem(
                                sizes: 'lg-4 md-6',
                                child: buildOverView(
                                  LucideIcons.truck,
                                  const Color.fromARGB(255, 189, 199, 56),
                                  "Total Customers",
                                  (controller.data?[
                                              'total_only_vehicle_documents'] ??
                                          0)
                                      .toString(),
                                  LucideIcons.trendingUp,
                                  contentTheme.success,
                                  '8%',
                                ),
                              ),
                            ],
                          ))
                ]);
        },
      ),
    );
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
                  child: controller.isLoading
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
                                          ? const SizedBox()
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
                                          ? const SizedBox()
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
                                          ? const SizedBox()
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
                                              controller.fetchData();
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
                                            controller.fetchData();
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

  Widget buildOverView(IconData icon, Color color, String title, subTitle,
      IconData tradIcon, Color tradColor, String per) {
    return MyCard(
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      borderRadiusAll: 8,
      paddingAll: 23,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    MyContainer(
                      height: 44,
                      width: 44,
                      borderRadiusAll: 8,
                      paddingAll: 0,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: color.withAlpha(36),
                      child: Icon(icon, color: color),
                    ),
                    MySpacing.width(12),
                    MyText.bodyLarge(title, muted: true, fontWeight: 700),
                  ],
                ),
                MyText.bodyLarge(subTitle, fontWeight: 600, muted: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
