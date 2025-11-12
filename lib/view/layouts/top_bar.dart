import 'package:LeLaundrette/helpers/services/auth_service.dart';
import 'package:LeLaundrette/helpers/services/localizations/language.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/helpers/theme/app_notifier.dart';
import 'package:LeLaundrette/helpers/theme/app_theme.dart';
import 'package:LeLaundrette/helpers/theme/theme_customizer.dart';
import 'package:LeLaundrette/helpers/utils/mixins/ui_mixin.dart';
import 'package:LeLaundrette/helpers/utils/my_shadow.dart';
import 'package:LeLaundrette/helpers/widgets/my_button.dart';
import 'package:LeLaundrette/helpers/widgets/my_card.dart';
import 'package:LeLaundrette/helpers/widgets/my_container.dart';
import 'package:LeLaundrette/helpers/widgets/my_spacing.dart';
import 'package:LeLaundrette/helpers/widgets/my_text.dart';
import 'package:LeLaundrette/images.dart';
import 'package:LeLaundrette/widgets/custom_pop_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart';

class TopBar extends StatefulWidget {
  const TopBar({
    super.key,
  });

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar>
    with SingleTickerProviderStateMixin, UIMixin {
  Function? languageHideFn;

  bool isFullScreen = false, isLeftBarCondensed = false;
  int isNotificationTab = 0;

  void goFullScreen() {
    isFullScreen
        ? document.exitFullscreen()
        : document.documentElement!.requestFullscreen();
    setState(() {
      isFullScreen = !isFullScreen;
    });
  }

  void leftBarCondensedToggle() {
    ThemeCustomizer.toggleLeftBarCondensed();
    isLeftBarCondensed = !isLeftBarCondensed;
    setState(() {});
  }

  void onChangeNotificationTabBar(int id) {
    isNotificationTab = id;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MyCard(
      shadow: MyShadow(position: MyShadowPosition.bottomRight, elevation: 0.5),
      height: 60,
      borderRadiusAll: 0,
      padding: MySpacing.x(24),
      color: topBarTheme.background.withAlpha(246),
      child: Row(
        children: [
          InkWell(
              splashColor: colorScheme.onSurface,
              highlightColor: colorScheme.onSurface,
              onTap: () => leftBarCondensedToggle(),
              child: Icon(
                !isLeftBarCondensed ? Icons.menu : Icons.arrow_forward_outlined,
                color: topBarTheme.onBackground,
              )),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                    onTap: goFullScreen,
                    child: Icon(
                        isFullScreen
                            ? LucideIcons.minimize
                            : LucideIcons.maximize,
                        size: 20)),
                MySpacing.width(24),
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
                      size: 20,
                      color: topBarTheme.onBackground),
                ),
                MySpacing.width(24),
                InkWell(
                  onTap: () {
                    ThemeCustomizer.toggleNotificationView(
                        !ThemeCustomizer.isNotificationOpen);
                  },
                  child: Icon(LucideIcons.bell,
                      size: 20, color: topBarTheme.onBackground),
                ),
                MySpacing.width(24),
                CustomPopupMenu(
                  backdrop: true,
                  onChange: (_) {},
                  offsetX: -20,
                  offsetY: 0,
                  menu: Padding(
                    padding: MySpacing.xy(0, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyContainer.rounded(
                            paddingAll: 0,
                            child: Image.asset(
                              Images.userlogo,
                              height: 28,
                              width: 28,
                              fit: BoxFit.cover,
                            )),
                        MySpacing.width(8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.labelLarge(
                                LocalStorage.getLoggedUserdata()['name']
                                    .toString(),
                                fontWeight: 600),
                            MyText.labelSmall("System User", fontWeight: 600),
                          ],
                        )
                      ],
                    ),
                  ),
                  menuBuilder: (_) => buildAccountMenu(),
                  hideFn: (_) => languageHideFn = _,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildLanguageSelector() {
    return MyContainer(
      borderRadiusAll: 8,
      width: 140,
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
    return MyContainer(
      borderRadiusAll: 8,
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyButton(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () async {
              await AuthService.logout();
              await Get.offNamedUntil(
                '/auth/login',
                (route) => false,
              );
            },
            borderRadiusAll: AppStyle.buttonRadius.medium,
            padding: MySpacing.xy(8, 4),
            splashColor: contentTheme.danger.withAlpha(28),
            backgroundColor: Colors.transparent,
            child: Row(
              children: [
                Icon(LucideIcons.logOut, size: 14, color: contentTheme.danger),
                MySpacing.width(8),
                MyText.labelMedium("Log out",
                    fontWeight: 600, color: contentTheme.danger)
              ],
            ),
          )
        ],
      ),
    );
  }
}
