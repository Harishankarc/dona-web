import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/dashboard/drivers/add_driver_controller.dart';
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
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddDriverScreen extends StatefulWidget {
  const AddDriverScreen({
    super.key,
  });

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late AddDriverController controller = Get.put(AddDriverController());
  late OutlineInputBorder _outlineInputBorder;
  late ToastMessageController toastcontroller;

  @override
  void initState() {
    _outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    );
    toastcontroller = ToastMessageController(this);
    WidgetsBinding.instance.addPostFrameCallback((timestamps) async {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
          init: controller,
          tag: 'add_driver_controller',
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
                            "Add Driver",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Dashboard'),
                              MyBreadcrumbItem(name: 'Add Driver'),
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
              SizedBox(
                child: Wrap(
                  runSpacing: 15,
                  spacing: 8,
                  children: [
                    IOUtils.fields("Driver Name *", "Enter Driver Name",
                        controller.nameController),
                    IOUtils.dateField(
                        "Date of Birth * ",
                        "Select Date of Birth",
                        context,
                        controller.setDateOfBirth,
                        APIService.formatDate,
                        controller.dateOfBirth),
                    IOUtils.fields("Mobile Number * ", "Enter Mobile Number",
                        controller.mobileController),
                    IOUtils.fields(
                        "Aadhar", "Enter Aadhar", controller.aadharController),
                    IOUtils.fields("License Number", "Enter License Number",
                        controller.licenseController),
                    IOUtils.dateField(
                        "License Expiry",
                        "Select License Expiry",
                        context,
                        controller.setLicenseExpiry,
                        APIService.formatDate,
                        controller.licenseExpiry),
                    IOUtils.fields(
                        "Emergency Contact Name",
                        "Enter Emergency Contact Name",
                        controller.emergencyNameController),
                    IOUtils.fields(
                        "Emergency Contact Number",
                        "Enter Emergency Contact Number",
                        controller.emergencyNumberController),
                    IOUtils.typeAheadField<dynamic>(
                      "Emergency Contact Relationship",
                      "Enter Emergency Contact Relationship",
                      (term) => APIService.getDriverRelationShipTypes(term),
                      controller.setSelectedDriverRelationship,
                      (value) => value['name'].toString(),
                      controller.selecteddriverrelationship,
                    ),
                    IOUtils.fields("Address", "Enter Address",
                        controller.addressController),
                    IOUtils.fields("Referral Name", "Enter Referral Name",
                        controller.referralController),
                    IOUtils.dateField(
                        "Start Date with Business * ",
                        "Select Start Date",
                        context,
                        controller.setStartDate,
                        APIService.formatDate,
                        controller.startDate),
                    IOUtils.dateField(
                        "End Date with Business",
                        "Select End Date",
                        context,
                        controller.setEndDate,
                        APIService.formatDate,
                        controller.endDate),
                    IOUtils.fields(
                        "Opening Balance Amount",
                        "Enter Opening Balance",
                        controller.remainingAmountController),
                    IOUtils.fields("Advance Amount", "Enter Advance Amount",
                        controller.advanceAmountController),
                  ],
                ),
              ),
              MySpacing.height(10),
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
                            if (controller.nameController.text.isEmpty) {
                              toastMessage("Please Enter Driver Name",
                                  contentTheme.danger);
                              return;
                            }
                            if (controller.dateOfBirth == null) {
                              toastMessage("Please Select Date of Birth",
                                  contentTheme.danger);
                              return;
                            }
                            if (controller.mobileController.text.isEmpty) {
                              toastMessage("Please Enter Mobile Number",
                                  contentTheme.danger);
                              return;
                            }

                            if (controller.startDate == null) {
                              toastMessage("Please Select Start Date",
                                  contentTheme.danger);
                              return;
                            }
                            controller.setLoading(true);

                            final response = await APIService.createDriverAPI(
                              controller.nameController.text,
                              controller.mobileController.text,
                              controller.subledgertype,
                              controller.dateOfBirth == null
                                  ? ""
                                  : APIService.formatReverseDate(
                                      controller.dateOfBirth!),
                              controller.licenseController.text,
                              controller.licenseExpiry == null
                                  ? ""
                                  : APIService.formatReverseDate(
                                      controller.licenseExpiry!),
                              controller.aadharController.text,
                              controller.emergencyNumberController.text,
                              controller.emergencyNameController.text,
                              controller.selecteddriverrelationship == null
                                  ? ''
                                  : controller.selecteddriverrelationship['id']
                                      .toString(),
                              controller.referralController.text,
                              controller.addressController.text,
                              controller.startDate == null
                                  ? ""
                                  : APIService.formatReverseDate(
                                      controller.startDate!),
                              controller.endDate == null
                                  ? ""
                                  : APIService.formatReverseDate(
                                      controller.endDate!),
                              controller.remainingAmountController.text,
                              controller.advanceAmountController.text,
                              controller.branchid,
                              LocalStorage.getLoggedUserdata()['userid']
                                  .toString(),
                            );
                            if (response['status'] == 'success') {
                              toastMessage(response['message'].toString(),
                                  contentTheme.success);
                            } else {
                              controller.setLoading(false);
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
                  MySpacing.height(40),
                ],
              )
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
