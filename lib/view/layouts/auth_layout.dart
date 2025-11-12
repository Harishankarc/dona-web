import 'package:LeLaundrette/controller/layout/auth_layout_controller.dart';
import 'package:LeLaundrette/helpers/theme/app_theme.dart';
import 'package:LeLaundrette/helpers/utils/mixins/ui_mixin.dart';
import 'package:LeLaundrette/helpers/widgets/my_container.dart';
import 'package:LeLaundrette/helpers/widgets/my_flex.dart';
import 'package:LeLaundrette/helpers/widgets/my_flex_item.dart';
import 'package:LeLaundrette/helpers/widgets/my_responsive.dart';
import 'package:LeLaundrette/helpers/widgets/my_spacing.dart';
import 'package:LeLaundrette/images.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthLayout extends StatefulWidget {
  final Widget? child;

  const AuthLayout({super.key, this.child});

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> with UIMixin {
  final AuthLayoutController controller = AuthLayoutController();

  @override
  Widget build(BuildContext context) {
    return MyResponsive(builder: (BuildContext context, constraints, screenMT) {
      return FittedBox(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: constraints.maxWidth / 0.9, // inverse of scale
          height: constraints.maxHeight / 0.9,

          child: Transform.scale(
            scale: 1,
            child: MyResponsive(builder: (BuildContext context, _, screenMT) {
              return GetBuilder(
                  init: controller,
                  builder: (controller) {
                    return screenMT.isMobile
                        ? mobileScreen(context)
                        : largeScreen(context);
                  });
            }),
          ),
        ),
      );
    });
  }

  Widget mobileScreen(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      body: Container(
        padding: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
        height: MediaQuery.of(context).size.height,
        color: theme.cardTheme.color,
        child: SingleChildScrollView(
          key: controller.scrollKey,
          child: widget.child,
        ),
      ),
    );
  }

  Widget largeScreen(BuildContext context) {
    return Scaffold(
        key: controller.scaffoldKey,
        body: Stack(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 0.9,
              height: MediaQuery.of(context).size.height / 0.9,
              child: Image.asset(
                Images.background,
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: MyFlex(
                wrapAlignment: WrapAlignment.center,
                wrapCrossAlignment: WrapCrossAlignment.start,
                runAlignment: WrapAlignment.center,
                spacing: 0,
                runSpacing: 0,
                children: [
                  MyFlexItem(
                    sizes: "xxl-4 lg-4 md-6 sm-8",
                    child: MyContainer(
                      borderRadiusAll: 8,
                      height: MediaQuery.of(context).size.height * .65,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyFlex(
                          wrapAlignment: WrapAlignment.center,
                          wrapCrossAlignment: WrapCrossAlignment.start,
                          runAlignment: WrapAlignment.center,
                          runSpacing: 0,
                          contentPadding: false,
                          children: [
                            MyFlexItem(
                                sizes: "lg-12",
                                child: widget.child ?? Container()),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
