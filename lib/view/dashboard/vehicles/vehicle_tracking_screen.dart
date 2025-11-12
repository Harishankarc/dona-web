// ignore_for_file: depend_on_referenced_packages

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/dashboard/vehicles/vehicle_tracking_controller.dart';
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

class VehiclesTrackingScreen extends StatefulWidget {
  const VehiclesTrackingScreen({
    super.key,
  });

  @override
  State<VehiclesTrackingScreen> createState() => _VehiclesTrackingScreenState();
}

class _VehiclesTrackingScreenState extends State<VehiclesTrackingScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late VehicleTrackingListController controller =
      Get.put(VehicleTrackingListController());
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
          tag: 'vehicle_tracking_controller',
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
                            "Tracking",
                            fontSize: 18,
                            fontWeight: 600,
                          ),
                          MyBreadcrumb(
                            children: [
                              MyBreadcrumbItem(name: 'Dashboard'),
                              MyBreadcrumbItem(name: 'Tracking'),
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
                          await controller.syncData();
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
                              'Sync Now',
                              fontSize: 12,
                              color: contentTheme.onPrimary,
                            ),
                          ],
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IOUtils.dateField("", "Date", context, controller.setDate,
                          APIService.formatDate, controller.filterdate,
                          emptyOption: true),
                      MySpacing.width(10),
                      IOUtils.fields(
                        "Search",
                        "Search",
                        controller.searchcontroller,
                        onlybox: true,
                        onChanged: (value) => controller.loadData(false),
                      ),
                    ],
                  ),
                ],
              ),
              MySpacing.height(8),
              IOUtils.dataTable<dynamic>(
                [
                  "Vehicle Name",
                  "Driver Name",
                  "Last Seen",
                  "Odo Distance",
                  "Distance Covered",
                  "Today Working Hrs",
                  "Address",
                ],
                [
                  (value) => value['vehicle_name'].toString(),
                  (value) => value['driver_name'].toString(),
                  (value) => value['lastseen'].toString(),
                  (value) => value['odo_distance'].toString(),
                  (value) => value['distance_covered'].toString(),
                  (value) => value['today_working_hours'].toString(),
                  (value) => value["address"].toString(),
                ],
                controller.data,
                context,
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
