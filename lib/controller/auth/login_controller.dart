import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginController extends MyController {
  bool isCheckToggle = false, obscureText = false;
  String message = '';
  bool loading = false;

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void updateLoading(bool value) {
    loading = value;
    update();
  }

  void showPasswordToggle() {
    obscureText = !obscureText;
    update();
  }

  void onSelectToggle() {
    isCheckToggle = !isCheckToggle;
    update();
  }

  Future<Map<String, dynamic>> onLogin() async {
    var resp = await AuthService.loginUser({
      'username': usernameController.text,
      'password': passwordController.text
    });
    return resp;
  }
}
