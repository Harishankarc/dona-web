import 'package:LeLaundrette/controller/layout/layout_controller.dart';
import 'package:LeLaundrette/helpers/services/auth_service.dart';
import 'package:LeLaundrette/helpers/services/localizations/language.dart';
import 'package:LeLaundrette/helpers/theme/admin_theme.dart';
import 'package:LeLaundrette/helpers/theme/app_notifier.dart';
import 'package:LeLaundrette/helpers/theme/app_theme.dart';
import 'package:LeLaundrette/helpers/theme/theme_customizer.dart';
import 'package:LeLaundrette/helpers/widgets/my_button.dart';
import 'package:LeLaundrette/helpers/widgets/my_container.dart';
import 'package:LeLaundrette/helpers/widgets/my_responsive.dart';
import 'package:LeLaundrette/helpers/widgets/my_spacing.dart';
import 'package:LeLaundrette/helpers/widgets/my_text.dart';
import 'package:LeLaundrette/images.dart';
import 'package:LeLaundrette/view/layouts/back_to_top.dart';
import 'package:LeLaundrette/view/layouts/left_bar.dart';
import 'package:LeLaundrette/view/layouts/notification_screen.dart';
import 'package:LeLaundrette/view/layouts/right_bar.dart';
import 'package:LeLaundrette/view/layouts/top_bar.dart';
import 'package:LeLaundrette/widgets/custom_pop_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class Layout extends StatefulWidget {
  final Widget? child;

  const Layout({super.key, this.child});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final LayoutController controller = LayoutController();

  final topBarTheme = AdminTheme.theme.topBarTheme;

  final contentTheme = AdminTheme.theme.contentTheme;

  Function? languageHideFn;

  @override
  Widget build(BuildContext context) {
    return MyResponsive(builder: (BuildContext context, _, screenMT) {
      return FittedBox(
          alignment: Alignment.topLeft,
          child: SizedBox(
              width:
                  MediaQuery.of(context).size.width / 0.9, // inverse of scale
              height: MediaQuery.of(context).size.height / 0.9,
              child: Transform.scale(
                scale: 1,
                child: GetBuilder(
                    init: controller,
                    builder: (controller) {
                      if (screenMT.isMobile || screenMT.isTablet) {
                        return mobileScreen();
                      } else {
                        return largeScreen();
                      }
                    }),
              )));
    });
  }

  Widget mobileScreen() {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        actions: [
          InkWell(
            onTap: () {
              ThemeCustomizer.setTheme(
                  ThemeCustomizer.instance.theme == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark);
            },
            child: Icon(
              ThemeCustomizer.instance.theme == ThemeMode.dark
                  ? LucideIcons.sun
                  : LucideIcons.moon,
              size: 18,
              color: topBarTheme.onBackground,
            ),
          ),
          MySpacing.width(8),
          CustomPopupMenu(
            backdrop: true,
            hideFn: (_) => languageHideFn = _,
            onChange: (_) {},
            offsetX: -36,
            menu: MyContainer(
                paddingAll: 0,
                color: Colors.transparent,
                borderRadiusAll: 4,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: SvgPicture.asset(
                    'assets/lang/${ThemeCustomizer.instance.currentLanguage.locale.languageCode}.svg',
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    height: 18)),
            menuBuilder: (_) => buildLanguageSelector(),
          ),
          MySpacing.width(8),
          CustomPopupMenu(
            backdrop: true,
            onChange: (_) {},
            offsetX: -90,
            offsetY: 4,
            menu: Padding(
              padding: MySpacing.xy(8, 8),
              child: MyContainer.rounded(
                  paddingAll: 0,
                  child: Image.asset(
                    Images.logo,
                    height: 28,
                    width: 28,
                    fit: BoxFit.cover,
                  )),
            ),
            menuBuilder: (_) => buildAccountMenu(),
          ),
          MySpacing.width(20)
        ],
      ),
      drawer: const LeftBar(),
      body: SingleChildScrollView(
        key: controller.scrollKey,
        child: widget.child,
      ),
    );
  }

  Widget largeScreen() {
    return Scaffold(
      key: controller.scaffoldKey,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton:
          BackToTop(scrollController: controller.scrollController),
      endDrawer: const RightBar(),
      body: Row(
        children: [
          LeftBar(isCondensed: ThemeCustomizer.instance.leftBarCondensed),
          Expanded(
              child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    if (ThemeCustomizer.isNotificationOpen) {
                      ThemeCustomizer.toggleNotificationView(
                        false,
                      );
                    }
                  },
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    padding:
                        MySpacing.fromLTRB(0, 58 + flexSpacing, 0, flexSpacing),
                    key: controller.scrollKey,
                    child: widget.child,
                  ),
                ),
              ),
              const Positioned(top: 0, left: 0, right: 0, child: TopBar()),
              if (ThemeCustomizer.isNotificationOpen)
                const Positioned(
                    top: 60, right: 100, child: NotificationScreen()),
            ],
          )),
        ],
      ),
    );
  }

  Widget buildLanguageSelector() {
    return MyContainer.bordered(
      padding: MySpacing.xy(8, 8),
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: Language.languages
            .map((language) => MyButton.text(
                  padding: MySpacing.xy(8, 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashColor: contentTheme.onBackground.withAlpha(20),
                  onPressed: () async {
                    languageHideFn?.call();
                    await Provider.of<AppNotifier>(context, listen: false)
                        .changeLanguage(language, notify: true);
                    ThemeCustomizer.notify();
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      MyContainer(
                          borderRadiusAll: 4,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          paddingAll: 0,
                          child: SvgPicture.asset(
                              'assets/lang/${language.locale.languageCode}.svg',
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              height: 14,
                              width: 18)),
                      MySpacing.width(8),
                      MyText.labelMedium(language.languageName)
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget buildAccountMenu() {
    return MyContainer.bordered(
      paddingAll: 0,
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Padding(
            padding: MySpacing.xy(8, 8),
            child: MyButton(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () async {
                languageHideFn?.call();
                await AuthService.logout();
              },
              borderRadiusAll: AppStyle.buttonRadius.medium,
              padding: MySpacing.xy(8, 4),
              splashColor: contentTheme.danger.withAlpha(28),
              backgroundColor: Colors.transparent,
              child: Row(
                children: [
                  Icon(
                    LucideIcons.logOut,
                    size: 14,
                    color: contentTheme.danger,
                  ),
                  MySpacing.width(8),
                  MyText.labelMedium(
                    "Log out",
                    fontWeight: 600,
                    color: contentTheme.danger,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
