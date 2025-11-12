import 'dart:convert';

import 'package:LeLaundrette/helpers/services/auth_service.dart';
import 'package:LeLaundrette/helpers/services/localizations/language.dart';
import 'package:LeLaundrette/helpers/theme/theme_customizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _loggedInUserKey = "islogged";
  static const String _username = "username";
  static const String _permissions = "permissions";
  static const String _themeCustomizerKey = "theme_customizer";
  static const String _languageKey = "lang_code";

  static SharedPreferences? _preferencesInstance;

  static SharedPreferences get preferences {
    if (_preferencesInstance == null) {
      throw ("Call LocalStorage.init() to initialize local storage");
    }
    return _preferencesInstance!;
  }

  static Future<void> init() async {
    _preferencesInstance = await SharedPreferences.getInstance();
    await initData();
  }

  static Future<void> initData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    AuthService.isLoggedIn = preferences.getBool(_loggedInUserKey) ?? false;
    ThemeCustomizer.fromJSON(preferences.getString(_themeCustomizerKey));
  }

  static Future<bool> setLoggedInUser(bool loggedIn) async {
    return preferences.setBool(_loggedInUserKey, loggedIn);
  }

  static Future<bool> setLoggedUserdata(String user) async {
    return preferences.setString(_username, user);
  }

  static Future<bool> setPermissions(String permissions) async {
    return preferences.setString(_permissions, permissions);
  }

  static bool getLoggedInUser() {
    return preferences.getBool(_loggedInUserKey) ?? false;
  }

  static Future<Map<String, dynamic>> setLoginData(
      String userid,
      String name,
      String phone,
      String username,
      String password,
      String branchid,
      String permissions,
      String usergroupid,
      String branchname) async {
    preferences.setBool("islogged", true);
    preferences.setString('userid', userid);
    preferences.setString('name', name);
    preferences.setString('phone', phone);
    preferences.setString('username', username);
    preferences.setString('password', password);
    preferences.setString('branchid', branchid);
    preferences.setString('permissions', permissions);
    preferences.setString('usergroupid', usergroupid);
    preferences.setString('branchname', branchname);
    return {"status": "success"};
  }

  static Map<String, dynamic> getLoggedUserdata() {
    if (preferences.containsKey('userid')) {
      String? userid = preferences.getString('userid');
      String? name = preferences.getString('name');
      String? phone = preferences.getString('phone');
      String? username = preferences.getString('username');
      String? password = preferences.getString('password');
      String? branchid = preferences.getString('branchid');
      String? permissions = preferences.getString('permissions');
      String? usergroupid = preferences.getString('usergroupid');
      String? branchname = preferences.getString('branchname');

      return {
        'status': 'success',
        'userid': userid,
        'name': name,
        'phone': phone,
        'username': username,
        'password': password,
        "branchid": branchid,
        "permissions": permissions,
        "usergroupid": usergroupid,
        "branchname": branchname
      };
    } else {
      return {'status': 'failed', 'message': 'User not available'};
    }
  }

  static Map<String, bool> getPermissions() {
    final permission = preferences.getString(_permissions) ?? '';
    return Map.castFrom(json.decode(permission));
  }

  static Future<bool> setCustomizer(ThemeCustomizer themeCustomizer) {
    return preferences.setString(_themeCustomizerKey, themeCustomizer.toJSON());
  }

  static Future<bool> setLanguage(Language language) {
    return preferences.setString(_languageKey, language.locale.languageCode);
  }

  static Future<bool> clearUserCred() async {
    await preferences.setString(_username, '');
    await preferences.setString(_permissions, '');
    return await preferences.setBool(_loggedInUserKey, false);
  }

  static String? getLanguage() {
    return preferences.getString(_languageKey);
  }

  static Future<bool> removeLoggedInUser() async {
    return preferences.remove(_loggedInUserKey);
  }

  static bool isSuperAdmin() {
    return getLoggedUserdata()['usergroupid'].toString() == "1";
  }
}
