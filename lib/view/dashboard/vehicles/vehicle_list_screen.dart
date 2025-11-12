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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                  "Vehicle Name",
                  "Model Name",
                  "Brand Name",
                  "Category Name",
                  "Registration",
                  "Chasis Number",
                  "Engine Number",
                  "Driver",
                  "Status"
                ],
                [
                  (value) => value['name'].toString(),
                  (value) => value['model_name'].toString(),
                  (value) => value['brand_name'].toString(),
                  (value) => value['category_name'].toString(),
                  (value) => value['registration'].toString(),
                  (value) => value['chasis_number'].toString(),
                  (value) => value['engine_number'].toString(),
                  (value) => value["assigned_to_name"].toString(),
                  (value) => MyText.labelMedium(
                      controller.statusMap[value['vehicle_status']].toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      fontSize: 11,
                      color:
                          controller.statusColorMap[value['vehicle_status']] ??
                              Colors.black,
                      fontWeight: 600),
                ],
                controller.data,
                context,
                isaction: true,
                actionList: [
                  TableAction(
                      permission: 'vehicle_vehicle_edit',
                      function: (data) async {
                        controller.setData(data);
                        editVehicleDetails(data);
                      },
                      iconData: IOUtils.editIcon,
                      color: contentTheme.warning),
                  TableAction(
                      permission: 'vehicle_vehicle_documents',
                      function: (data) async {
                        controller.clearDocumentForm();
                        addDocument(data);
                      },
                      iconData: LucideIcons.fileBox,
                      color: Colors.indigo),
                  TableAction(
                      permission: 'vehicle_vehicle_documents',
                      function: (data) async {
                        controller.setLoading(true);
                        final requestresponse =
                            await APIService.getDocumentListAPI(
                                data["id"].toString(), "", "");
                        controller.setLoading(false);

                        if (requestresponse["status"] == "success") {
                          viewDocuments(data, requestresponse["data"]);
                        } else {
                          toastMessage(
                              requestresponse['message'], contentTheme.danger);
                        }
                      },
                      iconData: LucideIcons.clipboardList,
                      color: Colors.teal),
                ],
              ),
              MySpacing.height(10),
            ],
          ),
        ),
      );
    });
  }

  void editVehicleDetails(dynamic data) {
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
                                  'Edit Vehicle Details',
                                  fontSize: 18,
                                  fontWeight: 600,
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
                                            runSpacing: 10,
                                            spacing: 7,
                                            children: [
                                              IOUtils.fields(
                                                "Name",
                                                "Enter Vehicle Name",
                                                controller.namecontroller,
                                              ),
                                              IOUtils.typeAheadField<dynamic>(
                                                  "Model",
                                                  "Enter Model",
                                                  (term) => APIService
                                                      .getVehicleModelTypes(
                                                          term),
                                                  controller.setSelectedModel,
                                                  (value) =>
                                                      value['name'].toString(),
                                                  controller
                                                      .selectedvehiclemodel),
                                              IOUtils.typeAheadField<dynamic>(
                                                  "Brands",
                                                  "Enter Brands",
                                                  (term) => APIService
                                                      .getVehicleBrandsTypes(
                                                          term),
                                                  controller.setSelectedBrands,
                                                  (value) =>
                                                      value['name'].toString(),
                                                  controller
                                                      .selectedvehicleBrands),
                                              IOUtils.typeAheadField<dynamic>(
                                                  "Category",
                                                  "Enter Category",
                                                  (term) => APIService
                                                      .getVehicleCategoryTypes(
                                                          term),
                                                  controller
                                                      .setSelectedVehicleCategory,
                                                  (value) =>
                                                      value['name'].toString(),
                                                  controller
                                                      .selectedvehiclecategory),
                                              IOUtils.fields(
                                                "Registration",
                                                "Enter Registration Number",
                                                controller
                                                    .registrationcontroller,
                                              ),
                                              IOUtils.fields(
                                                "Chassis Number",
                                                "Enter Chassis Number",
                                                controller.chassiscontroller,
                                              ),
                                              IOUtils.fields(
                                                "Engine Number",
                                                "Enter Engine Number",
                                                controller.enginenocontroller,
                                              ),
                                              IOUtils.dateField(
                                                "Date of Registration",
                                                "Select Date of Registration",
                                                context,
                                                controller.setRegDate,
                                                APIService.formatDate,
                                                controller.dateofreg,
                                              ),
                                              IOUtils.dateField(
                                                "Insurance Valid Up To",
                                                "Select Insurance Valid Up To",
                                                context,
                                                controller.setInsuranceDate,
                                                APIService.formatDate,
                                                controller.insurancevalidupto,
                                              ),
                                              IOUtils.dateField(
                                                "Fitness Valid Up To",
                                                "Select Fitness Valid Up To",
                                                context,
                                                controller.setFitnessDate,
                                                APIService.formatDate,
                                                controller.fitnessvalidupto,
                                              ),
                                              IOUtils.dateField(
                                                "Tax Valid Up To",
                                                "Select Tax Valid Up To",
                                                context,
                                                controller.setTaxValidDate,
                                                APIService.formatDate,
                                                controller.taxvalidupto,
                                              ),
                                              IOUtils.dateField(
                                                "Permit Valid Up To",
                                                "Select Permit Valid Up To",
                                                context,
                                                controller.setPermitValidDate,
                                                APIService.formatDate,
                                                controller.permitvalidupto,
                                              ),
                                              IOUtils.dateField(
                                                "Meter Valid Up To",
                                                "Select Meter Valid Up To",
                                                context,
                                                controller.setMeterValidDate,
                                                APIService.formatDate,
                                                controller.metervalidupto,
                                              ),
                                              IOUtils.dateField(
                                                "PUCC Valid Up To",
                                                "Select PUCC Valid Up To",
                                                context,
                                                controller.setPUCCValidDate,
                                                APIService.formatDate,
                                                controller.puccvalidupto,
                                              ),
                                              IOUtils.dateField(
                                                "Gas 1 Valid Up To",
                                                "Select Gas 1 Valid Up To",
                                                context,
                                                controller.setGas1ValidDate,
                                                APIService.formatDate,
                                                controller.gas1validupto,
                                              ),
                                              IOUtils.dateField(
                                                "Gas 2 Valid Up To",
                                                "Select Gas 2 Valid Up To",
                                                context,
                                                controller.setGas2ValidDate,
                                                APIService.formatDate,
                                                controller.gas2validupto,
                                              ),
                                              IOUtils.typeAheadField<dynamic>(
                                                  "Currently Assigned Driver",
                                                  "Enter Currently Assigned Driver",
                                                  (term) => APIService
                                                      .getVehicleDriverTypes(
                                                          term, "1"),
                                                  controller
                                                      .setSelectedVehicleDriver,
                                                  (value) =>
                                                      value['name'].toString(),
                                                  controller
                                                      .selectedvehicleDriver),
                                              IOUtils.typeAheadField<dynamic>(
                                                "Status",
                                                "Select Status",
                                                (term) =>
                                                    controller.vehiclestatus,
                                                (value) async {
                                                  controller
                                                      .setVehicleStatus(value);
                                                },
                                                (value) =>
                                                    value['name'].toString(),
                                                controller
                                                    .selectedvehiclestatus,
                                              ),
                                              IOUtils.documetUploadField(
                                                "Photo of the Vehicle",
                                                "Choose File",
                                                "Change File",
                                                controller.attachment,
                                                controller.setAttachment,
                                              ),
                                            ]),
                                        MySpacing.height(20),
                                        const MyText.titleMedium(
                                          "Tracking",
                                          fontSize: 18,
                                          fontWeight: 600,
                                        ),
                                        MySpacing.height(20),
                                        Wrap(
                                            runSpacing: 15,
                                            spacing: 7,
                                            children: [
                                              IOUtils.fields(
                                                "GPS IMEI",
                                                "Enter GPS IMEI",
                                                controller.gpsimeicontroller,
                                              ),
                                              IOUtils.fields(
                                                "GPS Sim Number ",
                                                "Enter GPS Sim Number ",
                                                controller
                                                    .gpssimnumbercontroller,
                                              ),
                                              IOUtils.fields(
                                                "GPS IMSI Number",
                                                "Enter GPS IMSI Number",
                                                controller
                                                    .gpsimsinumbercontroller,
                                              ),
                                            ]),
                                        MySpacing.height(20),
                                      ],
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
                                        if (controller
                                            .namecontroller.text.isEmpty) {
                                          toastMessage(
                                              'Vehicle Name Field is Required',
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller.selectedvehiclemodel ==
                                            null) {
                                          toastMessage(
                                              'Vehicle Model Field is Required',
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller.selectedvehicleBrands ==
                                            null) {
                                          toastMessage(
                                              'Vehicle Brand Field is Required',
                                              contentTheme.danger);
                                          return;
                                        }
                                        if (controller
                                                .selectedvehiclecategory ==
                                            null) {
                                          toastMessage(
                                              'Vehicle Category Field is Required',
                                              contentTheme.danger);
                                          return;
                                        }

                                        if (controller.selectedvehicleDriver ==
                                            null) {
                                          toastMessage(
                                              'Vehicle Driver Field is Required',
                                              contentTheme.danger);
                                          return;
                                        }

                                        if (controller.selectedvehiclestatus ==
                                            null) {
                                          toastMessage(
                                              'Vehicle Status Field is Required',
                                              contentTheme.danger);
                                          return;
                                        }

                                        controller.setLoading(true);
                                        String imagename =
                                            data['photo_of_vehicle'].toString();
                                        if (controller.attachment != null &&
                                            controller.attachment!.size != 0) {
                                          final response =
                                              await APIService.uploadImageWeb(
                                            controller.attachment!,
                                          );
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
                                        final response = await APIService.editVehicleAPI(
                                            data["id"].toString(),
                                            controller.namecontroller.text
                                                .toString(),
                                            controller.selectedvehiclemodel['id']
                                                .toString(),
                                            controller.selectedvehicleBrands['id']
                                                .toString(),
                                            controller.selectedvehiclecategory['id']
                                                .toString(),
                                            controller.registrationcontroller.text
                                                .toString(),
                                            controller.chassiscontroller.text
                                                .toString(),
                                            controller.enginenocontroller.text
                                                .toString(),
                                            controller.dateofreg == null
                                                ? ""
                                                : APIService.formatReverseDate(
                                                    controller.dateofreg!),
                                            controller.selectedvehicleDriver['id']
                                                .toString(),
                                            imagename,
                                            LocalStorage.getLoggedUserdata()['userid']
                                                .toString(),
                                            controller.insurancevalidupto == null
                                                ? ""
                                                : APIService.formatReverseDate(
                                                    controller
                                                        .insurancevalidupto!),
                                            controller.fitnessvalidupto == null
                                                ? ""
                                                : APIService.formatReverseDate(controller.fitnessvalidupto!),
                                            controller.taxvalidupto == null ? "" : APIService.formatReverseDate(controller.taxvalidupto!),
                                            controller.permitvalidupto == null ? "" : APIService.formatReverseDate(controller.permitvalidupto!),
                                            controller.metervalidupto == null ? "" : APIService.formatReverseDate(controller.metervalidupto!),
                                            controller.puccvalidupto == null ? "" : APIService.formatReverseDate(controller.puccvalidupto!),
                                            controller.gas1validupto == null ? "" : APIService.formatReverseDate(controller.gas1validupto!),
                                            controller.gas2validupto == null ? "" : APIService.formatReverseDate(controller.gas2validupto!),
                                            controller.gpsimeicontroller.text.toString(),
                                            controller.gpssimnumbercontroller.text.toString(),
                                            controller.gpsimsinumbercontroller.text.toString(),
                                            controller.selectedvehiclestatus["id"].toString());
                                        if (response['status'] == 'success') {
                                          toastMessage(
                                              response['message'].toString(),
                                              contentTheme.success);
                                        } else {
                                          toastMessage(
                                              response['message'].toString(),
                                              contentTheme.danger);
                                        }
                                        controller.clearForm();
                                        Get.back();
                                        controller.loadData();
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

  void addDocument(dynamic data) {
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
                                  'Add Document',
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
                                                    term, "V"),
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
                                        controller.selecteddocumenttype == null
                                            ? SizedBox()
                                            : controller.selecteddocumenttype[
                                                            "is_mandatory"]
                                                        .toString() ==
                                                    "Y"
                                                ? IOUtils.dateField(
                                                    readOnly: controller
                                                                .dateOfValidity ==
                                                            null
                                                        ? true
                                                        : false,
                                                    "Date of Reminder",
                                                    "Select Date of Reminder",
                                                    context,
                                                    controller.setReminder,
                                                    APIService.formatDate,
                                                    controller.reminderDate)
                                                : SizedBox(),
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
                                        String imagename = '';
                                        String docextension = '';
                                        if (controller.attachment != null) {
                                          String fileName =
                                              controller.attachment!.name;
                                          docextension = p.extension(fileName);
                                          final response =
                                              await APIService.uploadImageWeb(
                                            controller.attachment!,
                                          );
                                          if (response['success'].toString() ==
                                              '1') {
                                            imagename =
                                                response['documentpath'];
                                            print("=====================");
                                            print(imagename);
                                            print("=====================");
                                          } else {
                                            controller.setLoading(false);
                                            toastMessage(
                                                response['message'].toString(),
                                                contentTheme.danger);
                                            return;
                                          }
                                        }
                                        final response =
                                            await APIService.addDocument(
                                                data["id"].toString(),
                                                '',
                                                controller
                                                    .selecteddocumenttype['id']
                                                    .toString(),
                                                imagename,
                                                controller.dateOfValidity
                                                    .toString(),
                                                controller.selecteddocumenttype[
                                                                "is_mandatory"]
                                                            .toString() ==
                                                        "Y"
                                                    ? controller.reminderDate
                                                        .toString()
                                                    : "0000-00-00",
                                                LocalStorage.getLoggedUserdata()[
                                                        'userid']
                                                    .toString(),
                                                docextension.toString());
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

  void viewDocuments(dynamic data, List<dynamic> documents) {
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
                                  'Documents',
                                  fontWeight: 600,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: SingleChildScrollView(
                                  child: IOUtils.dataTable<dynamic>(
                                      [
                                        "Vehicle Name",
                                        "Document Type",
                                        "Date of Validity",
                                        "Reminder Date",
                                      ],
                                      [
                                        (value) =>
                                            value['vehicle_name'].toString(),
                                        (value) => value['document_type_name']
                                            .toString(),
                                        (value) => APIService.formatReportDate(
                                            value['validity_date'].toString()),
                                        (value) => MyText.labelMedium(
                                            value['reminder_date'].toString() ==
                                                    "0000-00-00"
                                                ? "-"
                                                : APIService.formatReportDate(
                                                    value['reminder_date']
                                                        .toString()),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            fontSize: 11,
                                            color: Colors.red,
                                            fontWeight: 600),
                                      ],
                                      documents,
                                      context,
                                      isaction: true,
                                      actionList: [
                                        TableAction(
                                          function: (data) async {
                                            final isImage =
                                                data['document_format']
                                                        .toString() ==
                                                    '.jpg';
                                            final isPdf =
                                                data['document_format']
                                                        .toString() ==
                                                    '.pdf';
                                            Uint8List? pdfBytes;
                                            if (isPdf) {
                                              try {
                                                final response =
                                                    await http.get(Uri.parse(
                                                  APIService.imageUrl(
                                                      data['attachment']
                                                          .toString()),
                                                ));

                                                if (response.statusCode ==
                                                    200) {
                                                  pdfBytes = response.bodyBytes;
                                                } else if (response
                                                        .statusCode ==
                                                    403) {
                                                  print(
                                                      'Access denied: File is private');
                                                } else {
                                                  print(
                                                      'Error: ${response.statusCode}');
                                                }
                                              } catch (e) {
                                                print(
                                                    'Error downloading PDF: $e');
                                              }
                                            }
                                            if (!mounted) return;
                                            isImage
                                                ? showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return ConstrainedBox(
                                                        constraints:
                                                            const BoxConstraints(
                                                                maxHeight: 600),
                                                        child: SizedBox(
                                                          width: 600,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Container(
                                                                width: 600,
                                                                color: contentTheme
                                                                    .onPrimary,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              20,
                                                                          top:
                                                                              20),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      GestureDetector(
                                                                        onTap: () =>
                                                                            Get.back(),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              4.0),
                                                                          child:
                                                                              Icon(
                                                                            LucideIcons.x,
                                                                            color:
                                                                                contentTheme.primary,
                                                                            weight:
                                                                                50,
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
                                                                              data['attachment'].toString()),
                                                                    )),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : APIService.openPDF(
                                                    data['attachment']
                                                        .toString());
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
                                      ]),
                                ),
                              ),
                              Padding(
                                  padding:
                                      MySpacing.only(right: 20, bottom: 20),
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
                                            color: colorScheme
                                                .onSecondaryContainer,
                                          ),
                                        ),
                                      ]))
                            ],
                          ),
                        ),
                );
              });
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
                                                    term, "V"),
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
                                        controller.selecteddocumenttype == null
                                            ? SizedBox()
                                            : controller.selecteddocumenttype[
                                                            "is_mandatory"]
                                                        .toString() ==
                                                    "Y"
                                                ? IOUtils.dateField(
                                                    readOnly: controller
                                                                .dateOfValidity ==
                                                            null
                                                        ? true
                                                        : false,
                                                    "Date of Reminder",
                                                    "Select Date of Reminder",
                                                    context,
                                                    controller.setReminder,
                                                    APIService.formatDate,
                                                    controller.reminderDate)
                                                : SizedBox(),
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

                                        final response = await APIService
                                            .editDocument(
                                                data["id"].toString(),
                                                data["vehicle_id"].toString(),
                                                '',
                                                controller
                                                    .selecteddocumenttype['id']
                                                    .toString(),
                                                imagename,
                                                controller.dateOfValidity
                                                    .toString(),
                                                controller.selecteddocumenttype[
                                                                "is_mandatory"]
                                                            .toString() ==
                                                        "Y"
                                                    ? controller.reminderDate
                                                        .toString()
                                                    : "0000-00-00",
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
