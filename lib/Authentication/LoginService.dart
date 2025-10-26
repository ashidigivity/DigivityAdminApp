import 'dart:async';

import 'package:digivity_admin_app/Helpers/getApiService.dart';

class LoginService {

  /// Username/password login (call your API here)
  Future<Map<String, dynamic>> loginWithPassword({
    required String username,
    required String password,
    required Map<String, dynamic> schoolData,
  }) async {
    final url = '${schoolData['base_url']}/api/MobileApp/login/$username/$password';

    final data = await getApiService.getApiServiceForLogin(url);

    // Validate
    if (data == null || data['success'] == null) {
      throw Exception("Invalid credentials");
    }

    return data;
  }

  /// Send OTP to phone using Firebase
Future<Map<String, dynamic>> loginWithOtp({required Map<String, dynamic> schoolData,required String phone}) async{
  final url = '${schoolData['base_url']}/api/MobileApp/sendOtp/$phone';
  try {
    final data = await getApiService.sendOtp(url);
    return data;
  }catch(e){
    print("${e}");
    return {
      "result":0,
      "message":"${e}",
      "success":[]
    };
  }

}

}
