import 'package:LeLaundrette/helpers/services/url_service.dart';
import 'package:LeLaundrette/helpers/theme/theme_customizer.dart';
import 'package:LeLaundrette/helpers/utils/mixins/ui_mixin.dart';
import 'package:LeLaundrette/helpers/utils/my_shadow.dart';
import 'package:LeLaundrette/helpers/widgets/my_card.dart';
import 'package:LeLaundrette/helpers/widgets/my_container.dart';
import 'package:LeLaundrette/helpers/widgets/my_spacing.dart';
import 'package:LeLaundrette/helpers/widgets/my_text.dart';
import 'package:LeLaundrette/images.dart';
import 'package:LeLaundrette/view/ui/permission_handler.dart';
import 'package:LeLaundrette/widgets/custom_pop_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/route_manager.dart';
import 'package:lucide_icons/lucide_icons.dart';

typedef LeftbarMenuFunction = void Function(String key);

class LeftbarObserver {
  static Map<String, LeftbarMenuFunction> observers = {};

  static attachListener(String key, LeftbarMenuFunction fn) {
    observers[key] = fn;
  }

  static detachListener(String key) {
    observers.remove(key);
  }

  static notifyAll(String key) {
    for (var fn in observers.values) {
      fn(key);
    }
  }
}

class LeftBar extends StatefulWidget {
  final bool isCondensed;

  const LeftBar({super.key, this.isCondensed = false});

  @override
  _LeftBarState createState() => _LeftBarState();
}

class _LeftBarState extends State<LeftBar>
    with SingleTickerProviderStateMixin, UIMixin {
  final ThemeCustomizer customizer = ThemeCustomizer.instance;

  bool isCondensed = false;
  String path = UrlService.getCurrentUrl();

  @override
  Widget build(BuildContext context) {
    isCondensed = widget.isCondensed;
    return MyCard(
      paddingAll: 0,
      shadow: MyShadow(position: MyShadowPosition.centerRight, elevation: 0.2),
      child: AnimatedContainer(
        color: leftBarTheme.background,
        width: isCondensed ? 60 : 250,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
              child: Padding(
                padding: MySpacing.xy(5, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                        onTap: () {
                          Get.offNamed('/dashboard/analytics');
                        },
                        child: Image.asset(
                            !widget.isCondensed ? Images.logo : Images.logoSm,
                            height: widget.isCondensed ? 28 : 55))
                  ],
                ),
              ),
            ),
            Expanded(
                child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView(
                shrinkWrap: true,
                controller: ScrollController(),
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                children: [
                  labelWidget("dashboard".tr),
                  NavigationItem(
                    iconData: LucideIcons.areaChart,
                    title: "Dashboard",
                    isCondensed: isCondensed,
                    route: '/dashboard/analytics',
                  ),
                  MenuWidget(
                      permission: 'reminder_main',
                      iconData: LucideIcons.book,
                      isCondensed: isCondensed,
                      title: "DayBook",
                      children: [
                        MenuItem(
                          permission: 'reminder_reminder',
                          title: 'Add Voucher',
                          route: '/daybook/adddaybook',
                          isCondensed: widget.isCondensed,
                        ),
                      ]),
                  MenuWidget(
                      permission: 'hr_main',
                      iconData: LucideIcons.userSquare2,
                      isCondensed: isCondensed,
                      title: "HR",
                      children: [
                        MenuItem(
                          permission: 'hr_leave_view',
                          title: 'Leaves',
                          route: '/hr/leaves',
                          isCondensed: widget.isCondensed,
                        ),
                      ]),
                  MenuWidget(
                      permission: 'vehicle_main',
                      iconData: LucideIcons.bus,
                      isCondensed: isCondensed,
                      title: "Vehicles",
                      children: [
                        MenuItem(
                          permission: 'vehicle_vehicle',
                          title: 'List Vehicles',
                          route: '/vehicles/listvehicles',
                          isCondensed: widget.isCondensed,
                        ),
                      ]),
                  MenuWidget(
                      permission: 'driver_main',
                      iconData: LucideIcons.userCheck2,
                      isCondensed: isCondensed,
                      title: "Subledgers",
                      children: [
                        MenuItem(
                          permission: 'driver_driver',
                          title: 'Customers',
                          route: '/subledgers/customers',
                          isCondensed: widget.isCondensed,
                        ),
                      ]),
                  MenuWidget(
                      permission: 'driver_main',
                      iconData: LucideIcons.users2,
                      isCondensed: isCondensed,
                      title: "Drivers",
                      children: [
                        MenuItem(
                          permission: 'driver_driver',
                          title: 'List Drivers',
                          route: '/drivers/listdrivers',
                          isCondensed: widget.isCondensed,
                        ),
                      ]),
                  MenuWidget(
                    permission: 'settings_main',
                    iconData: LucideIcons.settings,
                    isCondensed: widget.isCondensed,
                    title: 'Settings',
                    children: [
                      MenuItem(
                        permission: 'settings_branches',
                        title: 'Branches',
                        route: '/settings/branches',
                        isCondensed: widget.isCondensed,
                      ),
                      MenuItem(
                        permission: 'settings_users',
                        title: 'Users',
                        route: '/settings/users',
                        isCondensed: widget.isCondensed,
                      ),
                      MenuItem(
                        permission: 'settings_user-groups',
                        title: 'User Group',
                        route: '/settings/usergroup',
                        isCondensed: widget.isCondensed,
                      ),
                    ],
                  ),
                  MySpacing.height(32),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget labelWidget(String label) {
    return isCondensed
        ? MySpacing.empty()
        : Container(
            padding: MySpacing.xy(24, 8),
            child: MyText.labelSmall(
              label.toUpperCase(),
              color: leftBarTheme.labelColor,
              muted: true,
              maxLines: 1,
              overflow: TextOverflow.clip,
              fontWeight: 700,
            ),
          );
  }
}

class MenuWidget extends StatefulWidget {
  final String permission;
  final IconData iconData;
  final String title;
  final bool isCondensed;
  final bool active;
  final String? route;
  final List<MenuItem> children;

  const MenuWidget({
    super.key,
    this.permission = '',
    required this.iconData,
    required this.title,
    this.isCondensed = false,
    this.active = false,
    this.children = const [],
    this.route,
  });

  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget>
    with UIMixin, SingleTickerProviderStateMixin {
  bool isHover = false;
  bool isActive = false;
  late Animation<double> _iconTurns;
  late AnimationController _controller;
  bool popupShowing = true;
  Function? hideFn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5)
        .chain(CurveTween(curve: Curves.easeIn)));
    LeftbarObserver.attachListener(widget.title, onChangeMenuActive);
  }

  void onChangeMenuActive(String key) {
    if (key != widget.title) {
      onChangeExpansion(false);
    }
  }

  void onChangeExpansion(value) {
    isActive = value;
    if (isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var route = UrlService.getCurrentUrl();
    isActive = widget.children.any((element) => element.route == route);
    onChangeExpansion(isActive);
    if (hideFn != null) {
      hideFn!();
    }
    popupShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.permission.isEmpty ||
        PermissionHandler.getPermission(widget.permission)) {
      if (widget.isCondensed) {
        return CustomPopupMenu(
          backdrop: true,
          show: popupShowing,
          hideFn: (_) => hideFn = _,
          onChange: (_) {
            popupShowing = _;
          },
          placement: CustomPopupMenuPlacement.right,
          menu: MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover: (event) {
              print('hii');
              setState(() {
                isHover = true;
              });
            },
            onExit: (event) {
              setState(() {
                isHover = false;
              });
            },

            /// Small Side Bar
            child: MyContainer.transparent(
              margin: MySpacing.fromLTRB(4, 0, 8, 8),
              borderRadiusAll: 8,
              padding: MySpacing.xy(0, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyContainer(
                    height: 26,
                    width: 6,
                    paddingAll: 0,
                    color: isActive || isHover
                        ? leftBarTheme.activeItemColor
                        : Colors.transparent,
                  ),
                  MySpacing.width(12),
                  Icon(
                    widget.iconData,
                    color: (isHover || isActive)
                        ? leftBarTheme.activeItemColor
                        : leftBarTheme.onBackground,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          menuBuilder: (_) => MyContainer(
            borderRadiusAll: 8,
            paddingAll: 8,
            width: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: widget.children,
            ),
          ),
        );
      } else {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            setState(() {
              isHover = true;
            });
          },
          onExit: (event) {
            setState(() {
              isHover = false;
            });
          },
          child: MyContainer.transparent(
            margin: MySpacing.fromLTRB(4, 0, 16, 0),
            paddingAll: 0,
            child: ListTileTheme(
              contentPadding: const EdgeInsets.all(0),
              dense: true,
              horizontalTitleGap: 0.0,
              minLeadingWidth: 0,
              child: ExpansionTile(
                  tilePadding: MySpacing.zero,
                  initiallyExpanded: isActive,
                  maintainState: true,
                  onExpansionChanged: (_) {
                    LeftbarObserver.notifyAll(widget.title);
                    onChangeExpansion(_);
                  },
                  trailing: RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      LucideIcons.chevronDown,
                      size: 18,
                      color: leftBarTheme.onBackground,
                    ),
                  ),
                  iconColor: leftBarTheme.activeItemColor,
                  childrenPadding: MySpacing.x(12),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Large Side Bar
                      MyContainer(
                        height: 26,
                        width: 5,
                        paddingAll: 0,
                        color: isActive || isHover
                            ? leftBarTheme.activeItemColor
                            : Colors.transparent,
                      ),
                      MySpacing.width(12),
                      Icon(
                        widget.iconData,
                        size: 20,
                        color: isHover || isActive
                            ? leftBarTheme.activeItemColor
                            : leftBarTheme.onBackground,
                      ),
                      MySpacing.width(18),
                      Expanded(
                        child: MyText.labelLarge(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          color: isHover || isActive
                              ? leftBarTheme.activeItemColor
                              : leftBarTheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  collapsedBackgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent),
                  ),
                  backgroundColor: Colors.transparent,
                  children: widget.children),
            ),
          ),
        );
      }
    } else {
      return const SizedBox();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    LeftbarObserver.detachListener(widget.title);
  }
}

class MenuItem extends StatefulWidget {
  final String permission;
  final IconData? iconData;
  final String title;
  final bool isCondensed;
  final String? route;
  final List<MenuItem> childrenMenuWidget;

  const MenuItem({
    super.key,
    this.permission = '',
    this.iconData,
    required this.title,
    this.isCondensed = false,
    this.route,
    this.childrenMenuWidget = const [],
  });

  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem>
    with UIMixin, SingleTickerProviderStateMixin {
  bool isHover = false;
  bool isActive = false;
  late Animation<double> _iconTurns;
  late AnimationController _controller;
  bool popupShowing = true;
  Function? hideFn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5)
        .chain(CurveTween(curve: Curves.easeIn)));
    LeftbarObserver.attachListener(widget.title, onChangeMenuActive);
  }

  void onChangeMenuActive(String key) {
    if (key != widget.title) {
      onChangeExpansion(false);
    }
  }

  void onChangeExpansion(value) {
    isActive = value;
    if (isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var route = UrlService.getCurrentUrl();
    isActive =
        widget.childrenMenuWidget.any((element) => element.route == route);
    onChangeExpansion(isActive);
    if (hideFn != null) {
      hideFn!();
    }
    popupShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    bool isActive = UrlService.getCurrentUrl() == widget.route;
    if (widget.permission.isEmpty ||
        PermissionHandler.getPermission(widget.permission)) {
      if (widget.childrenMenuWidget.isEmpty) {
        return GestureDetector(
          onTap: () {
            if (widget.route != null) {
              Get.offNamed(widget.route!);
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover: (event) {
              setState(() {
                isHover = true;
              });
            },
            onExit: (event) {
              setState(() {
                isHover = false;
              });
            },
            child: MyContainer.transparent(
              margin: MySpacing.fromLTRB(4, 0, 8, 4),
              borderRadiusAll: 8,
              color: isActive || isHover
                  ? leftBarTheme.activeItemBackground
                  : Colors.transparent,
              width: MediaQuery.of(context).size.width,
              padding: MySpacing.xy(18, 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.dot,
                      color: isActive || isHover
                          ? leftBarTheme.activeItemColor
                          : leftBarTheme.onBackground),
                  MyText.bodySmall(
                    widget.title,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    fontSize: 12.5,
                    color: isActive || isHover
                        ? leftBarTheme.activeItemColor
                        : leftBarTheme.onBackground,
                    fontWeight: isActive || isHover ? 600 : 500,
                  ),
                ],
              ),
            ),
          ),
        );
      } else if (widget.isCondensed) {
        return CustomPopupMenu(
          backdrop: true,
          show: popupShowing,
          hideFn: (_) => hideFn = _,
          onChange: (_) {
            popupShowing = _;
          },
          placement: CustomPopupMenuPlacement.right,
          menu: MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover: (event) {
              setState(() {
                isHover = true;
              });
            },
            onExit: (event) {
              setState(() {
                isHover = false;
              });
            },
            child: MyContainer.transparent(
              margin: MySpacing.fromLTRB(16, 0, 16, 8),
              color: isActive || isHover
                  ? leftBarTheme.activeItemBackground
                  : Colors.transparent,
              borderRadiusAll: 8,
              padding: MySpacing.xy(8, 8),
              child: Center(
                child: Icon(
                  widget.iconData,
                  color: (isHover || isActive)
                      ? leftBarTheme.activeItemColor
                      : leftBarTheme.onBackground,
                  size: 20,
                ),
              ),
            ),
          ),
          menuBuilder: (_) => MyContainer(
            borderRadiusAll: 8,
            paddingAll: 8,
            width: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: widget.childrenMenuWidget,
            ),
          ),
        );
      } else {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            setState(() {
              isHover = true;
            });
          },
          onExit: (event) {
            setState(() {
              isHover = false;
            });
          },
          child: MyContainer.transparent(
            margin: MySpacing.fromLTRB(24, 0, 16, 0),
            paddingAll: 0,
            borderRadiusAll: 8,
            child: ListTileTheme(
              contentPadding: const EdgeInsets.all(0),
              dense: true,
              horizontalTitleGap: 0.0,
              minLeadingWidth: 0,
              child: ExpansionTile(
                  tilePadding: MySpacing.zero,
                  initiallyExpanded: isActive,
                  maintainState: true,
                  onExpansionChanged: (_) {
                    LeftbarObserver.notifyAll(widget.title);
                    onChangeExpansion(_);
                  },
                  trailing: RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      LucideIcons.chevronDown,
                      size: 18,
                      color: leftBarTheme.onBackground,
                    ),
                  ),
                  iconColor: leftBarTheme.activeItemColor,
                  childrenPadding: MySpacing.x(12),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        widget.iconData,
                        size: 20,
                        color: isHover || isActive
                            ? leftBarTheme.activeItemColor
                            : leftBarTheme.onBackground,
                      ),
                      MySpacing.width(18),
                      Expanded(
                        child: MyText.labelLarge(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          color: isHover || isActive
                              ? leftBarTheme.activeItemColor
                              : leftBarTheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  collapsedBackgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent),
                  ),
                  backgroundColor: Colors.transparent,
                  children: widget.childrenMenuWidget),
            ),
          ),
        );
      }
    } else {
      return const SizedBox();
    }
  }
}

class NavigationItem extends StatefulWidget {
  final IconData? iconData;
  final String title;
  final bool isCondensed;
  final String? route;

  const NavigationItem(
      {super.key,
      this.iconData,
      required this.title,
      this.isCondensed = false,
      this.route});

  @override
  _NavigationItemState createState() => _NavigationItemState();
}

class _NavigationItemState extends State<NavigationItem> with UIMixin {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    bool isActive = UrlService.getCurrentUrl() == widget.route;
    return GestureDetector(
      onTap: () {
        if (widget.route != null) {
          Get.offNamed(widget.route!);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          setState(() {
            isHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            isHover = false;
          });
        },
        child: MyContainer.transparent(
          margin: MySpacing.fromLTRB(4, 0, 8, 8),
          borderRadiusAll: 8,
          padding: MySpacing.xy(0, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyContainer(
                height: 26,
                width: 6,
                paddingAll: 0,
                color: isActive || isHover
                    ? leftBarTheme.activeItemColor
                    : Colors.transparent,
              ),
              MySpacing.width(12),
              if (widget.iconData != null)
                Center(
                  child: Icon(widget.iconData,
                      color: (isHover || isActive)
                          ? leftBarTheme.activeItemColor
                          : leftBarTheme.onBackground,
                      size: 20),
                ),
              if (!widget.isCondensed)
                Flexible(
                  fit: FlexFit.loose,
                  child: MySpacing.width(16),
                ),
              if (!widget.isCondensed)
                Expanded(
                  flex: 3,
                  child: MyText.labelLarge(
                    widget.title,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    color: isActive || isHover
                        ? leftBarTheme.activeItemColor
                        : leftBarTheme.onBackground,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
