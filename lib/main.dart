import 'package:LeLaundrette/helpers/extensions/app_localization_delegate.dart';
import 'package:LeLaundrette/helpers/services/localizations/language.dart';
import 'package:LeLaundrette/helpers/services/navigation_services.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/helpers/theme/app_notifier.dart';
import 'package:LeLaundrette/helpers/theme/app_theme.dart';
import 'package:LeLaundrette/helpers/theme/theme_customizer.dart';
import 'package:LeLaundrette/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  await LocalStorage.init();
  AppStyle.init();
  await ThemeCustomizer.init();
  runApp(ChangeNotifierProvider<AppNotifier>(
    create: (context) => AppNotifier(),
    child: const MyApp(),
  ));
}

ValueNotifier<String> title = ValueNotifier("DONA");

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLogged = false;
  @override
  void initState() {
    isLogged = LocalStorage.getLoggedInUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (_, notifier, ___) {
        return ValueListenableBuilder(
            valueListenable: title,
            builder: (context, value, _) {
              return GetMaterialApp(
                title: title.value,
                scrollBehavior: MyCustomScrollBehavior(),
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeCustomizer.instance.theme,
                navigatorKey: NavigationService.navigatorKey,
                initialRoute: isLogged ? "/dashboard/analytics" : "/auth/login",
                getPages: getPageRoute(),
                builder: (_, child) {
                  NavigationService.registerContext(_);
                  return Directionality(
                      textDirection: AppTheme.textDirection,
                      child: child ?? Container());
                },
                localizationsDelegates: [
                  AppLocalizationsDelegate(context),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: Language.getLocales(),
              );
            });
      },
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
