import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_pagination/flutter_custom_pagination.dart';
import 'package:get/get.dart';
import 'package:LeLaundrette/controller/dashboard/settings/users/usergroup_controller.dart';
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
import 'package:LeLaundrette/helpers/widgets/my_text_style.dart';
import 'package:LeLaundrette/model/usergroupmodel.dart';
import 'package:LeLaundrette/view/layouts/layout.dart';
import 'package:LeLaundrette/view/ui/input_output_utils.dart';
import 'package:LeLaundrette/view/ui/toast_message_controller.dart';

class UserGroupScreen extends StatefulWidget {
  const UserGroupScreen({
    super.key,
  });

  @override
  State<UserGroupScreen> createState() => _UserGroupScreenState();
}

class _UserGroupScreenState extends State<UserGroupScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late UserGroupController controller = Get.put(UserGroupController());

  late ToastMessageController toastcontroller;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      toastcontroller = ToastMessageController(this);
      controller.usersList();
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
    controller.usersList();
    return Layout(
      child: GetBuilder(
          init: controller,
          tag: 'user_group_controller',
          builder: (controller) {
            return controller.loading
                ? MyFlex(
                    children: [
                      MyFlexItem(
                          sizes: 'lg-12',
                          child: MyCard(
                              height: MediaQuery.of(context).size.height,
                              child: IOUtils.loadingWidget())),
                    ],
                  )
                : Column(children: [
                    Padding(
                      padding: MySpacing.x(flexSpacing),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText.titleMedium(
                            "User Group",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Users'),
                              MyBreadcrumbItem(name: 'User Group'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    MySpacing.height(flexSpacing),
                    Padding(
                        padding: MySpacing.x(flexSpacing),
                        child: buildList(context)),
                  ]);
          }),
    );
  }

  Widget buildList(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      return Column(
        children: [
          MyCard(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
            borderRadiusAll: 8,
            padding: MySpacing.xy(15, 5),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MySpacing.height(6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: MySpacing.only(right: 15),
                        child: Row(
                          children: [
                            IOUtils.fields(
                              '',
                              "Search",
                              controller.searchcontroller,
                              onChanged: (value) {
                                controller.page = 1;
                                controller.usersList();
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  MySpacing.height(10),
                  IOUtils.dataTable<UserGroupModel>(
                    ['Name'],
                    [(value) => value.groupname.toString()],
                    controller.usersgroup,
                    context,
                    isaction: true,
                    actionList: [
                      TableAction(
                          permission: 'settings_user-groups_edit',
                          function: (data) {
                            controller.setUserGroupValue(data);
                            viewPermissions();
                          },
                          iconData: IOUtils.editIcon,
                          color: contentTheme.warning),
                    ],
                  ),
                  MySpacing.height(10),
                  FlutterCustomPagination(
                    currentPage: controller.page,
                    limitPerPage: controller.limit,
                    totalDataCount: controller.totalPages,
                    onPreviousPage: controller.onPreviousPage,
                    onBackToFirstPage: controller.gotoFirstPage,
                    onNextPage: controller.onNextPage,
                    onGoToLastPage: controller.gotoLastPage,
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
            ),
          ),
        ],
      );
    });
  }

  void viewPermissions() {
    showGeneralDialog(
        barrierColor: Colors.transparent,
        context: context,
        pageBuilder: (a, b, c) {
          return GetBuilder(
              init: controller,
              tag: 'user_group_controller',
              builder: (controller) {
                return Dialog(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                  child: controller.loading
                      ? MyCard(height: 400, child: IOUtils.loadingWidget())
                      : SizedBox(
                          width: 1200,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: MySpacing.all(16),
                                child: const MyText.labelLarge(
                                  'User Permissions',
                                  fontWeight: 600,
                                  fontSize: 16,
                                ),
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.7,
                                  minHeight: 200,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: {
                                        ...controller
                                            .selectedgroup!.permissions!.keys
                                            .map(
                                          (e) => e.split('_')[0],
                                        )
                                      }
                                          .map(
                                            (e) => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    MyText.bodyMedium(
                                                      e
                                                          .replaceAll('-', ' ')
                                                          .capitalize
                                                          .toString(),
                                                      fontWeight: 700,
                                                    ),
                                                    Checkbox(
                                                        side: IOUtils
                                                            .outlineInputBorder
                                                            .borderSide,
                                                        fillColor: controller
                                                                        .selectedgroup!
                                                                        .permissions![
                                                                    '${e}_main'] ??
                                                                false
                                                            ? WidgetStatePropertyAll(
                                                                contentTheme
                                                                    .success)
                                                            : WidgetStatePropertyAll(
                                                                contentTheme
                                                                    .onSuccess),
                                                        checkColor: contentTheme
                                                            .onSuccess,
                                                        value: controller
                                                                .selectedgroup!
                                                                .permissions![
                                                            '${e}_main'],
                                                        onChanged: (value) {
                                                          controller
                                                              .setForAllValue(
                                                                  e, value!);
                                                          controller.setValue(
                                                              '${e}_main',
                                                              value);
                                                        }),
                                                  ],
                                                ),
                                                const Divider(),
                                                if (controller.selectedgroup!
                                                            .permissions![
                                                        '${e}_main'] ??
                                                    false)
                                                  ...{
                                                    ...controller.selectedgroup!
                                                        .permissions!.keys
                                                        .where(
                                                          (i) =>
                                                              i.split('_')[0] ==
                                                                  e &&
                                                              i != '${e}_main',
                                                        )
                                                        .map(
                                                          (i) =>
                                                              i.split('_')[1],
                                                        )
                                                  }.map(
                                                    (i) => MyContainer.bordered(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 3,
                                                                  child: MyText.bodySmall(i
                                                                      .replaceAll(
                                                                          '-',
                                                                          ' ')
                                                                      .capitalize
                                                                      .toString()),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Column(
                                                                    children: [
                                                                      MySpacing
                                                                          .height(
                                                                              15),
                                                                      Checkbox(
                                                                          side: IOUtils
                                                                              .outlineInputBorder
                                                                              .borderSide,
                                                                          fillColor: controller.selectedgroup!.permissions!['${e}_$i'] ?? false
                                                                              ? WidgetStatePropertyAll(contentTheme
                                                                                  .success)
                                                                              : WidgetStatePropertyAll(contentTheme
                                                                                  .onSuccess),
                                                                          checkColor: contentTheme
                                                                              .onSuccess,
                                                                          value: controller.selectedgroup!.permissions!['${e}_$i'] ??
                                                                              false,
                                                                          onChanged:
                                                                              (value) {
                                                                            controller.setForAllValue('${e}_$i',
                                                                                value!);
                                                                            controller.setValue('${e}_$i',
                                                                                value);
                                                                          }),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    ...controller
                                                                        .selectedgroup!
                                                                        .permissions!
                                                                        .keys
                                                                        .where(
                                                                          (j) =>
                                                                              j.contains('${e}_${i}_') &&
                                                                              j.split('_').length == 3,
                                                                        )
                                                                        .map((j) =>
                                                                            SizedBox(
                                                                              width: 100,
                                                                              child: Column(
                                                                                children: [
                                                                                  AutoSizeText(
                                                                                    j.split('_').last.capitalize.toString(),
                                                                                    style: MyTextStyle.bodyMedium(),
                                                                                  ),
                                                                                  Checkbox(
                                                                                    side: IOUtils.outlineInputBorder.borderSide,
                                                                                    fillColor: controller.selectedgroup!.permissions![j] ?? false ? WidgetStatePropertyAll(contentTheme.success) : WidgetStatePropertyAll(contentTheme.onSuccess),
                                                                                    checkColor: contentTheme.onSuccess,
                                                                                    value: controller.selectedgroup!.permissions![j],
                                                                                    onChanged: (value) => (controller.selectedgroup!.permissions!['${e}_$i'] ?? false) ? controller.setValue(j, value!) : null,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ))
                                                                  ]),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                MySpacing.height(20)
                                              ],
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   height: 600,
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(8.0),
                              //     child: SingleChildScrollView(
                              //       child: GridView.builder(
                              //         shrinkWrap: true,
                              //         gridDelegate:
                              //             const SliverGridDelegateWithFixedCrossAxisCount(
                              //                 childAspectRatio: 270 / 70,
                              //                 crossAxisCount: 4),
                              //         itemCount: controller.selectedgroup
                              //                 ?.permissions.length ??
                              //             0,
                              //         itemBuilder: (context, index) {
                              //           final udata = controller.selectedgroup!;
                              //           final permissionlist = controller
                              //               .selectedgroup!.permissions.keys
                              //               .toList();
                              //           return IOUtils.checkBoxfield(
                              //             permissionlist[index]
                              //                 .replaceAll('_', ' ')
                              //                 .capitalize
                              //                 .toString(),
                              //             udata.permissions[
                              //                 permissionlist[index]],
                              //             (value) {
                              //               controller.setValue(
                              //                   permissionlist[index], value!);
                              //             },
                              //           );
                              //         },
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              Padding(
                                padding: MySpacing.all(20),
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
                                        if (controller.selectedgroup == null) {
                                          return;
                                        }
                                        controller.setLoading(true);
                                        final resp =
                                            await controller.updatePermission();
                                        if (resp['status'] == 'success') {
                                          controller.setLoading(false);
                                          IOUtils.toastMessage(
                                              resp['message'].toString(),
                                              contentTheme.success,
                                              context,
                                              toastcontroller
                                                  .animationController);
                                          Get.back();
                                        } else {
                                          controller.setLoading(false);
                                          IOUtils.toastMessage(
                                              resp['message'].toString(),
                                              contentTheme.danger,
                                              context,
                                              toastcontroller
                                                  .animationController);
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
}
