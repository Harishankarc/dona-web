import 'dart:io';

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/helpers/services/auth_service.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:LeLaundrette/view/auth/login_screen.dart';
import 'package:LeLaundrette/view/dashboard/analytics_screen.dart';
import 'package:LeLaundrette/view/dashboard/daybook/add_daybook_screen.dart';
import 'package:LeLaundrette/view/dashboard/drivers/driver_list_screen.dart';
import 'package:LeLaundrette/view/dashboard/settings/branches/branches_list_screen.dart';
import 'package:LeLaundrette/view/dashboard/settings/users/user_list_screen.dart';
import 'package:LeLaundrette/view/dashboard/settings/users/usergroup_screen.dart';
import 'package:LeLaundrette/view/dashboard/subledgers/customer_list_screen.dart';
import 'package:LeLaundrette/view/dashboard/vehicles/vehicle_list_screen.dart';
import 'package:LeLaundrette/view/ui/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    APIService.dio.options.headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      'branchid': LocalStorage.getLoggedUserdata()['branch_id'].toString()
    };
    return (AuthService.isLoggedIn)
        ? null
        : const RouteSettings(name: '/auth/login');
  }
}

class NullArgsMiddleware extends GetMiddleware {
  dynamic args;
  @override
  RouteSettings? redirect(String? route) {
    return args == null
        ? const RouteSettings(name: '/dashboard/analytics')
        : null;
  }
}

getPageRoute() {
  var routes = [
    GetPage(name: '/auth/login', page: () => const LoginScreen()),
    GetPage(
      name: '/dashboard/analytics',
      page: () => const AnalyticsScreen(),
      middlewares: [PermissionMiddleware(permission: 'dashboard_main')],
    ),
    GetPage(
      name: '/vehicles/listvehicles',
      page: () => const VehiclesListScreen(),
      middlewares: [PermissionMiddleware(permission: 'vehicle_vehicle')],
    ),
    GetPage(
      name: '/subledgers/customers',
      page: () => const CustomerListScreen(),
      middlewares: [PermissionMiddleware(permission: 'driver_driver')],
    ),
    GetPage(
      name: '/drivers/listdrivers',
      page: () => const DriversListScreen(),
      middlewares: [PermissionMiddleware(permission: 'driver_driver')],
    ),
    GetPage(
      name: '/daybook/adddaybook',
      page: () => const AddDayBookScreen(),
      middlewares: [PermissionMiddleware(permission: 'reminder_reminder')],
    ),
    GetPage(
      name: '/settings/usergroup',
      page: () => const UserGroupScreen(),
      middlewares: [PermissionMiddleware(permission: 'settings_user-groups')],
    ),
    GetPage(
        name: '/settings/users',
        page: () => const UsersListScreen(),
        middlewares: [PermissionMiddleware(permission: 'settings_users')]),
    GetPage(
        name: '/settings/branches',
        page: () => const BranchesListScreen(),
        middlewares: [PermissionMiddleware(permission: 'settings_branches')]),
  ];
  return routes
      .map((e) => e.name == '/auth/login'
          ? GetPage(name: e.name, page: e.page, transition: Transition.fadeIn)
          : GetPage(
              name: e.name,
              page: e.page,
              middlewares: [AuthMiddleware(), ...e.middlewares ?? []],
              transition: Transition.fadeIn))
      .toList();
}

class ArgumentRedirect extends StatefulWidget {
  final dynamic args;
  final String? path;
  final Widget child;
  const ArgumentRedirect(
      {super.key, required this.args, this.path, required this.child});

  @override
  State<ArgumentRedirect> createState() => _ArgumentRedirectState();
}

class _ArgumentRedirectState extends State<ArgumentRedirect> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (widget.args == null) {
          Get.offNamed(widget.path ?? "/dashboard/analytics");
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
