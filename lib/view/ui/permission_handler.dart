import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PermissionHandler extends StatefulWidget {
  final String permission;
  final Widget child;
  const PermissionHandler(
      {super.key, required this.permission, required this.child});
  static bool getPermission(String key) {
    return key.isEmpty ? true : LocalStorage.getPermissions()[key] ?? false;
  }

  @override
  State<PermissionHandler> createState() => _PermissionHandlerState();
}

class _PermissionHandlerState extends State<PermissionHandler> {
  @override
  Widget build(BuildContext context) {
    return PermissionHandler.getPermission(widget.permission)
        ? widget.child
        : const SizedBox();
  }
}

class PermissionMiddleware extends GetMiddleware {
  final String permission;
  PermissionMiddleware({required this.permission}) : super();

  @override
  RouteSettings? redirect(String? route) {
    final value = PermissionHandler.getPermission(permission);
    return value ? null : const RouteSettings(name: '/auth/login');
  }
}
