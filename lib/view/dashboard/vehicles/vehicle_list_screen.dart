import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/dashboard/vehicles/vehicles_list_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VehiclesListScreen extends StatefulWidget {
  const VehiclesListScreen({
    super.key,
  });

  @override
  State<VehiclesListScreen> createState() => _VehiclesListScreenState();
}

class _VehiclesListScreenState extends State<VehiclesListScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late VehiclesListController controller = Get.put(VehiclesListController());
  late OutlineInputBorder _outlineInputBorder;
  late ToastMessageController toastcontroller;

  @override
  void initState() {
    _outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    );
    toastcontroller = ToastMessageController(this);
    WidgetsBinding.instance.addPostFrameCallback((timestamps) async {
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
          tag: 'vehicle_list_controller',
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
                            "Vehicles",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Dashboard'),
                              MyBreadcrumbItem(name: 'Vehicles'),
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
                  MyContainer(
                    width: 200,
                    height: 35,
                    padding: MySpacing.zero,
                    child: MyButton.block(
                        elevation: 0.5,
                        onPressed: () async {
                          controller.setData(null);
                          addVehicle();
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
                              'Add Vehicle',
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
                    onChanged: (value) => controller.loadData(false),
                  ),
                ],
              ),
              MySpacing.height(8),
              IOUtils.dataTable<dynamic>(
                [
                  "Vehicle",
                  "Registration",
                  "Charge Per Hour",
                  "Minimum Charge",
                  "Need Shifting",
                  "Shifting Charge",
                  "Created By"
                ],
                [
                  (value) => value['name'].toString(),
                  (value) => value['registration'].toString(),
                  (value) => value['charge_per_hour'].toString(),
                  (value) => value['minimum_charge'].toString(),
                  (value) =>
                      value["need_shifting"].toString() == "Y" ? "Yes" : "No",
                  (value) => value["shifting_charge"].toString(),
                  (value) => value["created_by_name"].toString(),
                ],
                controller.data,
                context,
                isaction: true,
                actionList: [
                  TableAction(
                      permission: 'vehicle_vehicle_edit',
                      function: (data) async {
                        controller.setData(data);
                        editVehicle(data["id"].toString());
                      },
                      iconData: IOUtils.editIcon,
                      color: contentTheme.warning),
                  TableAction(
                      permission: 'vehicle_vehicle_delete',
                      function: (data) async {
                        DeleteView.deleteDialog(
                            data["id"].toString(),
                            'vehicles',
                            data["name"].toString(),
                            toastMessage,
                            controller.loadData,
                            context);
                      },
                      iconData: IOUtils.deleteIcon,
                      color: contentTheme.danger)
                ],
              ),
              MySpacing.height(10),
            ],
          ),
        ),
      );
    });
  }

  void addVehicle() {
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
                                  'Add Vehicle',
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
                                            "Enter name",
                                            controller.namecontroller,
                                          ),
                                          IOUtils.fields(
                                            "Plate No",
                                            "Enter plate no",
                                            controller.registrationcontroller,
                                          ),
                                          IOUtils.fields(
                                            "Charge / Hour",
                                            "Enter charge / hour",
                                            controller.chargeperhourcontroller,
                                          ),
                                          IOUtils.fields(
                                            "Minimum Charge",
                                            "Enter minimum charge",
                                            controller.minimumchargecontroller,
                                          ),
                                          IOUtils.checkBoxfield(
                                            "Need Shifting",
                                            "Need Shifting",
                                            controller.needshifting,
                                            (value) {
                                              controller
                                                  .setShifting(value ?? false);
                                            },
                                          ),
                                          controller.needshifting
                                              ? IOUtils.fields(
                                                  "Shifting Charge",
                                                  "Enter shifting charge",
                                                  controller
                                                      .shiftingchargecontroller,
                                                )
                                              : SizedBox(),
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
                                                  "Name field is required",
                                                  contentTheme.danger);
                                              return;
                                            }
                                            if (controller
                                                .chargeperhourcontroller
                                                .text
                                                .isEmpty) {
                                              toastMessage(
                                                  "Charge per hour is required",
                                                  contentTheme.danger);
                                              return;
                                            }

                                            if (controller
                                                .minimumchargecontroller
                                                .text
                                                .isEmpty) {
                                              toastMessage(
                                                  "Minimum charge is required",
                                                  contentTheme.danger);
                                              return;
                                            }
                                            controller.setLoading(true);
                                            final response = await APIService
                                                .createVehicleAPI(
                                                    controller
                                                        .namecontroller.text,
                                                    controller
                                                        .registrationcontroller
                                                        .text,
                                                    controller
                                                        .chargeperhourcontroller
                                                        .text,
                                                    controller
                                                        .minimumchargecontroller
                                                        .text,
                                                    controller.needshifting
                                                        ? "Y"
                                                        : "N",
                                                    controller
                                                        .shiftingchargecontroller
                                                        .text,
                                                    '0',
                                                    LocalStorage.getLoggedUserdata()[
                                                            'userid']
                                                        .toString());
                                            controller.setLoading(false);
                                            if (response['status'] ==
                                                'success') {
                                              toastMessage(
                                                  response['message']
                                                      .toString(),
                                                  contentTheme.success);
                                              Get.back();
                                              controller.loadData();
                                            } else {
                                              toastMessage(
                                                  response['message']
                                                      .toString(),
                                                  contentTheme.danger);
                                            }
                                          },
                                          elevation: 0,
                                          borderRadiusAll: 8,
                                          padding: MySpacing.xy(20, 16),
                                          backgroundColor: colorScheme.primary,
                                          child: MyText.labelMedium(
                                            "Submit",
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
        });
  }

  void editVehicle(String id) {
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
                                  'Edit Vehicle',
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
                                            "Enter name",
                                            controller.namecontroller,
                                          ),
                                          IOUtils.fields(
                                            "Plate No",
                                            "Enter plate no",
                                            controller.registrationcontroller,
                                          ),
                                          IOUtils.fields(
                                            "Charge / Hour",
                                            "Enter charge / hour",
                                            controller.chargeperhourcontroller,
                                          ),
                                          IOUtils.fields(
                                            "Minimum Charge",
                                            "Enter minimum charge",
                                            controller.minimumchargecontroller,
                                          ),
                                          IOUtils.checkBoxfield(
                                            "Need Shifting",
                                            "Need Shifting",
                                            controller.needshifting,
                                            (value) {
                                              controller
                                                  .setShifting(value ?? false);
                                            },
                                          ),
                                          controller.needshifting
                                              ? IOUtils.fields(
                                                  "Shifting Charge",
                                                  "Enter shifting charge",
                                                  controller
                                                      .shiftingchargecontroller,
                                                )
                                              : SizedBox(),
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
                                                  "Name field is required",
                                                  contentTheme.danger);
                                              return;
                                            }
                                            if (controller
                                                .chargeperhourcontroller
                                                .text
                                                .isEmpty) {
                                              toastMessage(
                                                  "Charge per hour is required",
                                                  contentTheme.danger);
                                              return;
                                            }

                                            if (controller
                                                .minimumchargecontroller
                                                .text
                                                .isEmpty) {
                                              toastMessage(
                                                  "Minimum charge is required",
                                                  contentTheme.danger);
                                              return;
                                            }
                                            controller.setLoading(true);
                                            final response =
                                                await APIService.editVehicleAPI(
                                                    id,
                                                    controller
                                                        .namecontroller.text,
                                                    controller
                                                        .registrationcontroller
                                                        .text,
                                                    controller
                                                        .chargeperhourcontroller
                                                        .text,
                                                    controller
                                                        .minimumchargecontroller
                                                        .text,
                                                    controller.needshifting
                                                        ? "Y"
                                                        : "N",
                                                    controller
                                                        .shiftingchargecontroller
                                                        .text,
                                                    '0',
                                                    LocalStorage.getLoggedUserdata()[
                                                            'userid']
                                                        .toString());
                                            controller.setLoading(false);
                                            if (response['status'] ==
                                                'success') {
                                              toastMessage(
                                                  response['message']
                                                      .toString(),
                                                  contentTheme.success);
                                              Get.back();
                                              controller.loadData();
                                            } else {
                                              toastMessage(
                                                  response['message']
                                                      .toString(),
                                                  contentTheme.danger);
                                            }
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
