import 'package:LeLaundrette/controller/dashboard/settings/brand/brand_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:LeLaundrette/backend/apiservice.dart';
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
import 'package:LeLaundrette/view/ui/permission_handler.dart';
import 'package:LeLaundrette/view/ui/toast_message_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BrandsListScreen extends StatefulWidget {
  const BrandsListScreen({
    super.key,
  });

  @override
  State<BrandsListScreen> createState() => _BrandsListScreenState();
}

class _BrandsListScreenState extends State<BrandsListScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late BrandsListController controller = Get.put(BrandsListController());
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
    controller.loadData();
    return Layout(
      child: GetBuilder(
          init: controller,
          tag: 'brands_controller',
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
                            "Brands",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Dashboard'),
                              MyBreadcrumbItem(name: 'Brands'),
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

  Widget addData() {
    return MyContainer(
      width: 200,
      height: 35,
      padding: MySpacing.zero,
      child: MyButton.block(
          elevation: 0.5,
          onPressed: () async {
            controller.clearData();
            addBrand();
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
                'Add Brands',
                fontSize: 12,
                color: contentTheme.onPrimary,
              ),
            ],
          )),
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
                PermissionHandler(
                    permission: 'settings_brands_add', child: addData()),
                IOUtils.fields(
                  "Search",
                  "Search",
                  controller.searchcontroller,
                  onlybox: true,
                  onChanged: (value) {
                    controller.loadData(false);
                  },
                ),
              ],
            ),
            MySpacing.height(8),
            IOUtils.dataTable<dynamic>(
              ["Name"],
              [
                (value) => value['name'].toString(),
              ],
              controller.data,
              context,
              isaction: true,
              actionwidth: 200,
              actionList: [
                TableAction(
                    permission: 'settings_brands_edit',
                    function: (data) {
                      controller.setData(data);
                      editBrand(data);
                    },
                    iconData: IOUtils.editIcon,
                    color: contentTheme.warning),
                TableAction(
                    permission: 'settings_brands_delete',
                    function: (data) async {
                      DeleteView.deleteDialog(
                          data['id'].toString(),
                          'brands',
                          data['name'],
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
      );
    });
  }

  void addBrand() {
    showGeneralDialog(
        barrierColor: Colors.transparent,
        context: context,
        pageBuilder: (a, b, c) {
          return GetBuilder(
              init: controller,
              tag: 'brands_controller',
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
                                  'Add Brand',
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
                                        "Name",
                                        "Enter Name",
                                        controller.namecontroller,
                                      ),
                                    ]
                                            .map((e) => Padding(
                                                  padding: MySpacing.all(5),
                                                  child: e,
                                                ))
                                            .toList()),
                                  )),
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
                                        if (controller
                                            .namecontroller.text.isEmpty) {
                                          toastMessage('Name Field is Required',
                                              contentTheme.danger);
                                          return;
                                        }

                                        controller.setLoading(true);
                                        final resp =
                                            await APIService.addMasterAPI(
                                                'brands',
                                                controller.namecontroller.text,
                                                LocalStorage.getLoggedUserdata()[
                                                        'userid']
                                                    .toString());
                                        if (resp['status'] == 'success') {
                                          controller.setLoading(false);
                                          toastMessage(
                                              "Brand Added Successfully",
                                              contentTheme.success);
                                          Get.back();
                                          controller.loadData();
                                        } else {
                                          controller.setLoading(false);
                                          toastMessage(
                                              resp['message'].toString(),
                                              contentTheme.danger);
                                        }
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

  void editBrand(dynamic data) {
    showGeneralDialog(
        barrierColor: Colors.transparent,
        context: context,
        pageBuilder: (a, b, c) {
          return GetBuilder(
              init: controller,
              tag: 'brand_controller',
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
                                  'Edit Brand',
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
                                        "Name",
                                        "Enter Name",
                                        controller.namecontroller,
                                      ),
                                    ]
                                            .map((e) => Padding(
                                                  padding: MySpacing.all(5),
                                                  child: e,
                                                ))
                                            .toList()),
                                  )),
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
                                        if (controller
                                            .namecontroller.text.isEmpty) {
                                          toastMessage('Name Field is Required',
                                              contentTheme.danger);
                                          return;
                                        }

                                        controller.setLoading(true);
                                        final resp =
                                            await APIService.editMasterAPI(
                                                data['id'].toString(),
                                                controller.namecontroller.text,
                                                'brands',
                                                LocalStorage.getLoggedUserdata()[
                                                        'userid']
                                                    .toString());
                                        if (resp['status'] == 'success') {
                                          controller.setLoading(false);
                                          toastMessage(
                                              "Brand Updated Successfully",
                                              contentTheme.success);
                                          Get.back();
                                          controller.loadData();
                                        } else {
                                          controller.setLoading(false);
                                          toastMessage(
                                              resp['message'].toString(),
                                              contentTheme.danger);
                                        }
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
