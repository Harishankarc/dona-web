// ignore_for_file: depend_on_referenced_packages, must_be_immutable

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/dashboard/drivers/drivers_document_controller.dart';
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
import 'package:LeLaundrette/view/layouts/delete_view.dart';
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

class DriversDocumentScreen extends StatefulWidget {
  const DriversDocumentScreen({
    super.key,
  });

  @override
  State<DriversDocumentScreen> createState() => _DriversDocumentScreenState();
}

class _DriversDocumentScreenState extends State<DriversDocumentScreen>
    with UIMixin, TickerProviderStateMixin {
  DriversDocumentController controller = Get.put(DriversDocumentController());
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
          tag: 'documents_list_controller',
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
                            "Drivers Documents",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Dashboard'),
                              MyBreadcrumbItem(name: 'Drivers Documents'),
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
                child: IOUtils.dataTable<dynamic>(
                    [
                      "Driver Name",
                      "Document Type",
                      "Date of Validity",
                      "Reminder Date",
                    ],
                    [
                      (value) => value['subledger_name'].toString(),
                      (value) => value['document_type_name'].toString(),
                      (value) => APIService.formatReportDate(
                          value['validity_date'].toString()),
                      (value) => MyText.labelMedium(
                          value['reminder_date'].toString() == "0000-00-00"
                              ? "-"
                              : APIService.formatReportDate(
                                  value['reminder_date'].toString()),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: 600),
                    ],
                    controller.data,
                    context,
                    isaction: true,
                    actionList: [
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
                                APIService.imageUrl(
                                    data['attachment'].toString()),
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
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Icon(
                                                          LucideIcons.x,
                                                          color: contentTheme
                                                              .primary,
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
                                                    imageuri:
                                                        APIService.imageUrl(
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
                              : APIService.openPDF(
                                  data['attachment'].toString());
                        },
                        iconData: LucideIcons.eye,
                        color: contentTheme.success,
                      ),
                      TableAction(
                        function: (data) async {
                          controller.setDocumentData(data);
                          editDocument(data);
                        },
                        iconData: LucideIcons.edit,
                        color: contentTheme.warning,
                      ),
                      TableAction(
                          function: (data) async {
                            DeleteView.deleteDialog(
                                data["id"].toString(),
                                'vehicle_documents',
                                "${data["document_type_name"]} of ${data["subledger_name"]}",
                                toastMessage,
                                controller.loadData,
                                context);
                          },
                          iconData: IOUtils.deleteIcon,
                          color: contentTheme.danger),
                    ]),
              ),
              MySpacing.height(10),
            ],
          ),
        ),
      );
    });
  }

  void editDocument(dynamic data) {
    showGeneralDialog(
        barrierColor: Colors.transparent,
        context: context,
        pageBuilder: (a, b, c) {
          return GetBuilder(
              init: controller,
              tag: 'document_controller',
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
                                padding: MySpacing.only(top: 16, left: 16),
                                child: const MyText.labelLarge(
                                  'Edit Document',
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
                                            "Document Type",
                                            "Enter Document Type",
                                            (term) =>
                                                APIService.getDocumentTypes(
                                                    term, "D"),
                                            controller.setSelecteddocumenttype,
                                            (value) => value['name'].toString(),
                                            controller.selecteddocumenttype),
                                        IOUtils.dateField(
                                            readOnly: controller
                                                        .selecteddocumenttype ==
                                                    null
                                                ? true
                                                : false,
                                            "Date of Validity",
                                            "Select Date of Validity",
                                            context,
                                            controller.setValidity,
                                            APIService.formatDate,
                                            controller.dateOfValidity),
                                        IOUtils.dateField(
                                            readOnly:
                                                controller.dateOfValidity ==
                                                        null
                                                    ? true
                                                    : false,
                                            "Date of Reminder",
                                            "Select Date of Reminder",
                                            context,
                                            controller.setReminder,
                                            APIService.formatDate,
                                            controller.reminderDate),
                                        IOUtils.documetUploadField(
                                          "Attachment",
                                          "Choose File",
                                          "Change File",
                                          controller.attachment,
                                          controller.setAttachment,
                                        ),
                                      ].map((e) {
                                        return Padding(
                                          padding: MySpacing.all(5),
                                          child: e,
                                        );
                                      }).toList(),
                                    ),
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
                                        if (controller.selecteddocumenttype ==
                                            null) {
                                          toastMessage(
                                              "Please select document type",
                                              contentTheme.danger);
                                        }
                                        if (controller.dateOfValidity == null) {
                                          toastMessage(
                                              "Please select date of validity",
                                              contentTheme.danger);
                                        }
                                        if (controller.reminderDate == null) {
                                          toastMessage(
                                              "Please select date of reminder",
                                              contentTheme.danger);
                                        }
                                        controller.setLoading(true);

                                        String imagename =
                                            data['attachment'].toString();
                                        String docextension =
                                            data['document_format'].toString();
                                        if (controller.attachment != null &&
                                            controller.attachment!.size != 0) {
                                          String fileName =
                                              controller.attachment!.name;
                                          docextension = p.extension(fileName);
                                          final response =
                                              await APIService.uploadImageWeb(
                                                  controller.attachment!);
                                          if (response['success'].toString() ==
                                              '1') {
                                            imagename =
                                                response['documentpath'];
                                          } else {
                                            controller.setLoading(false);
                                            toastMessage(
                                                response['message'].toString(),
                                                contentTheme.danger);
                                            return;
                                          }
                                        }

                                        final response =
                                            await APIService.editDocument(
                                                data["id"].toString(),
                                                '',
                                                data["subledger_id"].toString(),
                                                controller
                                                    .selecteddocumenttype['id']
                                                    .toString(),
                                                imagename,
                                                controller
                                                    .dateOfValidity
                                                    .toString(),
                                                controller.reminderDate
                                                    .toString(),
                                                LocalStorage.getLoggedUserdata()[
                                                        'userid']
                                                    .toString(),
                                                docextension.toString());
                                        print("This is the response");
                                        print(response);
                                        if (response['status'] == 'success') {
                                          toastMessage(
                                              response['message'].toString(),
                                              contentTheme.success);
                                        } else {
                                          toastMessage(
                                              response['message'].toString(),
                                              contentTheme.danger);
                                        }
                                        controller.setLoading(false);
                                        Get.back();
                                        Get.back();
                                        controller.loadData();
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
