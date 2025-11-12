import 'dart:async';

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/utils/mixins/ui_mixin.dart';
import 'package:LeLaundrette/helpers/widgets/my_button.dart';
import 'package:LeLaundrette/helpers/widgets/my_spacing.dart';
import 'package:LeLaundrette/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DeleteView extends MyController with UIMixin {
  bool loading = false;

  void setLoading(bool value) {
    loading = value;
    update();
  }

  Future<Map<String, dynamic>> deleteData(String id, String tableName) async {
    final response = await APIService.deleteModelRecord(
      tableName,
      id,
    );
    return response;
  }

  static Future<void> deleteDialog(
    String id,
    String tableName,
    String subheading,
    Function(
      String title,
      Color color,
    ) toastMessage,
    Function onSuccess,
    BuildContext context, [
    FutureOr<Map<String, dynamic>> Function()? deleteFuntion,
  ]) async {
    await showDialog<bool>(
        context: context,
        builder: (_) {
          final controller = DeleteView();
          return GetBuilder(
              init: controller,
              builder: (con) {
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
                              color: controller.contentTheme.primary, size: 40),
                        )
                      : SizedBox(
                          width: 400,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: MySpacing.all(16),
                                child: const MyText.labelLarge(
                                  'Delete',
                                  fontWeight: 700,
                                  fontSize: 18,
                                ),
                              ),
                              Padding(
                                padding: MySpacing.xy(16, 15),
                                child: MyText.bodyMedium(
                                  'Are you sure to delete $subheading from the database?.',
                                  fontWeight: 600,
                                  fontSize: 14,
                                ),
                              ),
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
                                      backgroundColor: controller
                                          .colorScheme.secondaryContainer,
                                      child: MyText.labelMedium(
                                        "No",
                                        fontWeight: 600,
                                        color: controller
                                            .colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                    MySpacing.width(16),
                                    MyButton(
                                      onPressed: () async {
                                        controller.setLoading(true);
                                        final response = deleteFuntion != null
                                            ? await deleteFuntion()
                                            : await controller.deleteData(
                                                id, tableName);
                                        if (response['status'] == 'success') {
                                          controller.setLoading(false);
                                          toastMessage(
                                            response['message'].toString(),
                                            controller.contentTheme.success,
                                          );
                                          Get.back();
                                          Future.delayed(
                                              const Duration(
                                                milliseconds: 6,
                                              ), () {
                                            onSuccess();
                                          });
                                        } else {
                                          controller.setLoading(false);
                                          toastMessage(
                                            response['message'].toString(),
                                            controller.contentTheme.danger,
                                          );
                                          Get.back();
                                        }
                                      },
                                      elevation: 0,
                                      borderRadiusAll: 8,
                                      padding: MySpacing.xy(20, 16),
                                      backgroundColor:
                                          controller.colorScheme.primary,
                                      child: MyText.labelMedium(
                                        "Yes",
                                        fontWeight: 600,
                                        color: controller.colorScheme.onPrimary,
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
