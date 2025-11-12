// ignore_for_file: depend_on_referenced_packages, must_be_immutable

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/dashboard/reminder/reminder_list_controller.dart';
import 'package:LeLaundrette/controller/dashboard/vehicles/vehicles_document_controller.dart';
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
import 'package:LeLaundrette/view/layouts/image_builder.dart';
import 'package:LeLaundrette/view/layouts/layout.dart';
import 'package:LeLaundrette/view/ui/input_output_utils.dart';
import 'package:LeLaundrette/view/ui/toast_message_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

class ReminderDocumentsListScreen extends StatefulWidget {
  const ReminderDocumentsListScreen({
    super.key,
  });

  @override
  State<ReminderDocumentsListScreen> createState() =>
      _ReminderDocumentsListScreenState();
}

class _ReminderDocumentsListScreenState
    extends State<ReminderDocumentsListScreen>
    with UIMixin, TickerProviderStateMixin {
  ReminderDocumentListController controller =
      Get.put(ReminderDocumentListController());
  late ToastMessageController toastcontroller;
  @override
  void initState() {
    super.initState();
    toastcontroller = ToastMessageController(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await controller.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
          init: controller,
          tag: 'reminder_documents_list_controller',
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
                            "Reminders",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Dashboard'),
                              MyBreadcrumbItem(name: 'Reminders'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    MySpacing.height(flexSpacing),
                    Padding(
                        padding: MySpacing.x(flexSpacing), child: buildlist()),
                  ]);
          }),
    );
  }

  Widget buildlist() {
    return LayoutBuilder(builder: (context, constraints) {
      return MyCard(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
        borderRadiusAll: 8,
        padding: MySpacing.xy(23, 5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MySpacing.height(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyButton(
                          onPressed: () {
                            controller.listtype = controller.filterstatus[0];
                            controller.loadData();
                            controller.update();
                          },
                          elevation: 0,
                          padding: MySpacing.xy(20, 16),
                          backgroundColor:
                              controller.listtype == controller.filterstatus[0]
                                  ? colorScheme.primary
                                  : colorScheme.secondaryContainer,
                          child: MyText.labelMedium(
                            controller.filterstatus[0]["name"].toUpperCase(),
                            fontWeight: 600,
                            color: controller.listtype ==
                                    controller.filterstatus[0]
                                ? colorScheme.onPrimary
                                : colorScheme.onSecondaryContainer,
                          ),
                        ),
                        MySpacing.width(5),
                        MyButton(
                          onPressed: () {
                            controller.listtype = controller.filterstatus[1];
                            controller.loadData();
                            controller.update();
                          },
                          elevation: 0,
                          padding: MySpacing.xy(20, 16),
                          backgroundColor:
                              controller.listtype == controller.filterstatus[1]
                                  ? colorScheme.primary
                                  : colorScheme.secondaryContainer,
                          child: MyText.labelMedium(
                            controller.filterstatus[1]["name"].toUpperCase(),
                            fontWeight: 600,
                            color: controller.listtype ==
                                    controller.filterstatus[1]
                                ? colorScheme.onPrimary
                                : colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: MySpacing.only(right: 15),
                    child: Row(
                      children: [
                        IOUtils.fields(
                          '',
                          "Search",
                          controller.searchcontroller,
                          onChanged: (value) {
                            controller.loadData(false);
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
              MySpacing.height(10),
              SingleChildScrollView(
                child: IOUtils.dataTable<dynamic>([
                  controller.listtype["id"] == "V"
                      ? "Vehicle Name"
                      : "Driver Name",
                  "Document Type",
                  "Date of Validity",
                  "Reminder Date",
                  "Days"
                ], [
                  (value) => controller.listtype["id"] == "V"
                      ? value['vehicle_name'].toString()
                      : value['subledger_name'].toString(),
                  (value) => value['document_type_name'].toString(),
                  (value) => APIService.formatReportDate(
                      value['validity_date'].toString()),
                  (value) => MyText.labelMedium(
                      APIService.formatReportDate(
                          value['reminder_date'].toString()),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      fontSize: 11,
                      color: Colors.red,
                      fontWeight: 600),
                  (value) => MyText.labelMedium(
                      value['remaining_days'].toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      fontSize: 11,
                      color: int.parse(value['remaining_days'].toString()) < 0
                          ? Colors.red
                          : Colors.green,
                      fontWeight: 600),
                ], controller.data, context, isaction: true,
                    isDefaultcolor: (row) {
                  if (int.parse(row['remaining_days'].toString()) < 0) {
                    return Colors.red;
                  }

                  return Colors.transparent;
                }, actionList: [
                  TableAction(
                    function: (data) async {
                      final isImage =
                          data['document_format'].toString() == '.jpg';
                      final isPdf =
                          data['document_format'].toString() == '.pdf';
                      Uint8List? pdfBytes;
                      if (isPdf) {
                        try {
                          final response = await http.get(Uri.parse(
                            APIService.imageUrl(data['attachment'].toString()),
                          ));

                          if (response.statusCode == 200) {
                            pdfBytes = response.bodyBytes;
                            print(pdfBytes);
                          } else if (response.statusCode == 403) {
                            print('Access denied: File is private');
                          } else {
                            print('Error: ${response.statusCode}');
                          }
                        } catch (e) {
                          print('Error downloading PDF: $e');
                        }
                      }
                      if (!mounted) return;
                      isImage
                          ? showDialog(
                              context: context,
                              builder: (context) {
                                return ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 600),
                                  child: SizedBox(
                                    width: 600,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 600,
                                          color: contentTheme.onPrimary,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20, top: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                  onTap: () => Get.back(),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Icon(
                                                      LucideIcons.x,
                                                      color:
                                                          contentTheme.primary,
                                                      weight: 50,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                              width: 600,
                                              color: Colors.white,
                                              child: ImageBuilder(
                                                imageuri: APIService.imageUrl(
                                                    data['attachment']
                                                        .toString()),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : APIService.openPDF(data['attachment'].toString());
                    },
                    iconData: LucideIcons.eye,
                    color: contentTheme.success,
                  ),
                ]),
              ),
              MySpacing.height(10),
            ],
          ),
        ),
      );
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
