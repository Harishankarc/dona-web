import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/dashboard/vehicles/add_vehicle_controller.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/helpers/theme/app_theme.dart';
import 'package:LeLaundrette/helpers/utils/mixins/ui_mixin.dart';
import 'package:LeLaundrette/helpers/utils/my_shadow.dart';
import 'package:LeLaundrette/helpers/widgets/my_breadcrumb.dart';
import 'package:LeLaundrette/helpers/widgets/my_breadcrumb_item.dart';
import 'package:LeLaundrette/helpers/widgets/my_button.dart';
import 'package:LeLaundrette/helpers/widgets/my_card.dart';
import 'package:LeLaundrette/helpers/widgets/my_flex.dart';
import 'package:LeLaundrette/helpers/widgets/my_flex_item.dart';
import 'package:LeLaundrette/helpers/widgets/my_spacing.dart';
import 'package:LeLaundrette/helpers/widgets/my_text.dart';
import 'package:LeLaundrette/view/layouts/layout.dart';
import 'package:LeLaundrette/view/ui/input_output_utils.dart';
import 'package:LeLaundrette/view/ui/toast_message_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({
    super.key,
  });

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late AddVehicleController controller = Get.put(AddVehicleController());
  late ToastMessageController toastcontroller;

  @override
  void initState() {
    toastcontroller = ToastMessageController(this);
    WidgetsBinding.instance.addPostFrameCallback((timestamps) async {
      toastcontroller = ToastMessageController(this);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
          init: controller,
          tag: 'add_vehicle_controller',
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
                            "Add Vehicle",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Dashboard'),
                              MyBreadcrumbItem(name: 'Add Vehicles'),
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
    return LayoutBuilder(builder: (context, constraints) {
      return MyCard(
        width: double.infinity,
        shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
        borderRadiusAll: 8,
        padding: MySpacing.xy(23, 5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MySpacing.height(8),
              Wrap(
                runSpacing: 15,
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
                      (term) => APIService.getVehicleModelTypes(term),
                      controller.setSelectedModel,
                      (value) => value['name'].toString(),
                      controller.selectedvehiclemodel),
                  IOUtils.typeAheadField<dynamic>(
                      "Brands",
                      "Enter Brands",
                      (term) => APIService.getVehicleBrandsTypes(term),
                      controller.setSelectedBrands,
                      (value) => value['name'].toString(),
                      controller.selectedvehicleBrands),
                  IOUtils.typeAheadField<dynamic>(
                      "Category",
                      "Enter Category",
                      (term) => APIService.getVehicleCategoryTypes(term),
                      controller.setSelectedVehicleCategory,
                      (value) => value['name'].toString(),
                      controller.selectedvehiclecategory),
                  IOUtils.fields(
                    "Registration",
                    "Enter Registration Number",
                    controller.registrationcontroller,
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
                      (term) => APIService.getVehicleDriverTypes(term, "1"),
                      controller.setSelectedVehicleDriver,
                      (value) => value['name'].toString(),
                      controller.selectedvehicleDriver),
                        IOUtils.typeAheadField<dynamic>(
                  "Status",
                  "Select Status",
                  (term) => controller.vehiclestatus,
                  (value) async {
                    
                      controller.setVehicleStatus(value);
                  
                  },
                  (value) => value['name'].toString(),
                  controller.selectedvehiclestatus,
                ),
                  IOUtils.documetUploadField(
                    "Photo of the Vehicle",
                    "Choose File",
                    "Change File",
                    controller.attachment,
                    controller.setAttachment,
                  ),
                   
                ],
              ),
              MySpacing.height(20),
              const MyText.titleMedium(
                "Tracking",
                fontSize: 18,
                fontWeight: 600,
              ),
              MySpacing.height(20),
              Wrap(runSpacing: 15, spacing: 7, children: [
                IOUtils.fields(
                  "GPS IMEI",
                  "Enter GPS IMEI",
                  controller.gpsimeicontroller,
                ),
                IOUtils.fields(
                  "GPS Sim Number ",
                  "Enter GPS Sim Number ",
                  controller.gpssimnumbercontroller,
                ),
                IOUtils.fields(
                  "GPS IMSI Number",
                  "Enter GPS IMSI Number",
                  controller.gpsimsinumbercontroller,
                ),
              ]),
              MySpacing.height(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    height: 30,
                    child: MyButton.outlined(
                        onPressed: () {
                          Get.back();
                        },
                        backgroundColor: contentTheme.primary,
                        borderRadiusAll: 5,
                        child:
                            const MyText.bodySmall("Cancel", fontWeight: 600)),
                  ),
                  MySpacing.width(12),
                  Padding(
                    padding: MySpacing.only(right: 15),
                    child: SizedBox(
                      width: 100,
                      height: 30,
                      child: MyButton.block(
                          elevation: 0,
                          borderRadiusAll: 5,
                          onPressed: () async {
                            if (controller.namecontroller.text.isEmpty) {
                              toastMessage('Vehicle Name Field is Required',
                                  contentTheme.danger);
                              return;
                            }
                            if (controller.selectedvehiclemodel == null) {
                              toastMessage('Vehicle Model Field is Required',
                                  contentTheme.danger);
                              return;
                            }
                            if (controller.selectedvehicleBrands == null) {
                              toastMessage('Vehicle Brand Field is Required',
                                  contentTheme.danger);
                              return;
                            }
                            if (controller.selectedvehiclecategory == null) {
                              toastMessage('Vehicle Category Field is Required',
                                  contentTheme.danger);
                              return;
                            }

                            if (controller.selectedvehicleDriver == null) {
                              toastMessage('Vehicle Driver Field is Required',
                                  contentTheme.danger);
                              return;
                            }

                              if (controller.selectedvehiclestatus == null) {
                              toastMessage('Vehicle Status Field is Required',
                                  contentTheme.danger);
                              return;
                            }

                            controller.setLoading(true);
                            String imagename = '';
                            if (controller.attachment != null) {
                              final response = await APIService.uploadImageWeb(
                                controller.attachment!,
                              );
                              if (response['success'].toString() == '1') {
                                imagename = response['documentpath'];
                              } else {
                                controller.setLoading(false);
                                toastMessage(response['message'].toString(),
                                    contentTheme.danger);
                                return;
                              }
                            }
                            final response = await APIService.createVehicleAPI(
                                controller.namecontroller.text.toString(),
                                controller.selectedvehiclemodel['id']
                                    .toString(),
                                controller.selectedvehicleBrands['id']
                                    .toString(),
                                controller.selectedvehiclecategory['id']
                                    .toString(),
                                controller.registrationcontroller.text
                                    .toString(),
                                controller.chassiscontroller.text.toString(),
                                controller.enginenocontroller.text.toString(),
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
                                        controller.insurancevalidupto!),
                                controller.fitnessvalidupto == null
                                    ? ""
                                    : APIService.formatReverseDate(
                                        controller.fitnessvalidupto!),
                                controller.taxvalidupto == null
                                    ? ""
                                    : APIService.formatReverseDate(
                                        controller.taxvalidupto!),
                                controller.permitvalidupto == null
                                    ? ""
                                    : APIService.formatReverseDate(
                                        controller.permitvalidupto!),
                                controller.metervalidupto == null
                                    ? ""
                                    : APIService.formatReverseDate(
                                        controller.metervalidupto!),
                                controller.puccvalidupto == null
                                    ? ""
                                    : APIService.formatReverseDate(
                                        controller.puccvalidupto!),
                                controller.gas1validupto == null
                                    ? ""
                                    : APIService.formatReverseDate(
                                        controller.gas1validupto!),
                                controller.gas2validupto == null
                                    ? ""
                                    : APIService.formatReverseDate(controller.gas2validupto!),
                                controller.gpsimeicontroller.text.toString(),
                                controller.gpssimnumbercontroller.text.toString(),
                                controller.gpsimsinumbercontroller.text.toString(),
                                controller.selectedvehiclestatus["id"].toString()
                                );
                            if (response['status'] == 'success') {
                              toastMessage(response['message'].toString(),
                                  contentTheme.success);
                            } else {
                              toastMessage(response['message'].toString(),
                                  contentTheme.danger);
                            }
                            controller.clearForm();
                            controller.setLoading(false);
                          },
                          backgroundColor: contentTheme.primary,
                          child: MyText.bodySmall(
                            "Submit",
                            fontWeight: 600,
                            color: contentTheme.onPrimary,
                          )),
                    ),
                  ),
                ],
              ),
              MySpacing.height(20),
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
