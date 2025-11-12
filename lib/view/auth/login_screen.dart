import 'package:LeLaundrette/controller/auth/login_controller.dart';
import 'package:LeLaundrette/helpers/utils/mixins/ui_mixin.dart';
import 'package:LeLaundrette/helpers/widgets/my_button.dart';
import 'package:LeLaundrette/helpers/widgets/my_container.dart';
import 'package:LeLaundrette/helpers/widgets/my_spacing.dart';
import 'package:LeLaundrette/helpers/widgets/my_text.dart';
import 'package:LeLaundrette/images.dart';
import 'package:LeLaundrette/view/layouts/auth_layout.dart';
import 'package:LeLaundrette/view/ui/toast_message_controller.dart';
import 'package:LeLaundrette/widgets/flow_kit_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late LoginController controller = Get.put(LoginController());

  late ToastMessageController toastcontroller;

  @override
  void initState() {
    toastcontroller = ToastMessageController(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: GetBuilder(
        tag: 'laundry_login_screen',
        init: controller,
        builder: (controller) {
          return Padding(
            padding: MySpacing.x(MediaQuery.of(context).size.width * .03),
            child: controller.loading
                ? LoadingAnimationWidget.threeArchedCircle(
                    color: contentTheme.primary, size: 40)
                : Column(
                    children: [
                      MySpacing.height(24),
                      MyContainer(
                          height: 75,
                          paddingAll: 0,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Image.asset(
                            Images.logo,
                            fit: BoxFit.cover,
                          )),
                      MySpacing.height(44),
                      buildFields(),
                      MySpacing.height(24),
                      MyButton.block(
                          elevation: 0,
                          borderRadiusAll: 8,
                          padding: MySpacing.y(20),
                          backgroundColor: contentTheme.primary,
                          onPressed: () async {
                            controller.updateLoading(true);
                            final resp = await controller.onLogin();
                            if (resp['status'] == 'success') {
                              print("This is the status");
                              Get.offNamed('/dashboard/analytics');
                            } else {
                              toastMessage(resp['message'].toString(),
                                  contentTheme.danger);
                            }
                            controller.updateLoading(false);
                          },
                          child: MyText.bodyMedium(
                            "Login",
                            fontWeight: 600,
                            color: contentTheme.onPrimary,
                          )),
                      MySpacing.height(24),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget buildFields() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium("Enter Username", fontWeight: 700),
          MySpacing.height(8),
          FlowKitTextField(
            controller: controller.usernameController,
            hintText: "Username",
          ),
          MySpacing.height(20),
          MyText.bodyMedium("Enter Password", fontWeight: 700),
          MySpacing.height(8),
          FlowKitTextField(
            controller: controller.passwordController,
            hintText: "Password",
            obscureText: controller.obscureText,
            suffixIcon: InkWell(
              onTap: () => controller.showPasswordToggle(),
              child: Icon(
                  controller.obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 20),
            ),
          ),
          if (controller.message.isNotEmpty) ...[
            MySpacing.height(10),
            MyText.bodyMedium('*${controller.message}', color: Colors.red)
          ]
        ],
      ),
    );
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
      backgroundColor: const Color(0xffffe5e5),
    ));
  }
}
