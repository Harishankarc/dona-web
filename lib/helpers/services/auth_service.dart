import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/helpers/services/storage/local_storage.dart';

class AuthService {
  static bool isLoggedIn = false;

  static Future<Map<String, dynamic>> loginUser(
      Map<String, dynamic> data) async {
    final loginresp = await APIService.loginAPI(
        data['username'].toString(), data['password']);
    print("This is the login response");
    print(loginresp);
    if (loginresp['status'] == 'success') {
      await LocalStorage.setLoginData(
        loginresp["data"]["id"].toString(),
        loginresp["data"]["name"].toString(),
        loginresp["data"]["phone"].toString(),
        loginresp["data"]["username"].toString(),
        loginresp["data"]["password"].toString(),
        loginresp["data"]["branch_id"].toString(),
        loginresp["data"]["permission"].toString(),
        loginresp["data"]["user_group_id"].toString(),
        loginresp["data"]["branch_name"].toString(),
      );
      print(loginresp['data']);
      isLoggedIn = true;
    }

    return loginresp;
  }

  static Future<void> logout() async {
    await LocalStorage.clearUserCred();
    isLoggedIn = false;
  }
}
