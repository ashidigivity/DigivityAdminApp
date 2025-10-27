import 'dart:async';

import 'package:digivity_admin_app/Helpers/getApiService.dart';
import 'package:flutter/cupertino.dart';

class LoginService {

/// Get User Data For The Login Using UserName
  Future<Map<String, dynamic>> loginWithUserName({
    required String username,
    required Map<String, dynamic> schoolData,
  }) async {
    try {
      final url = '${schoolData['base_url']}/api/MobileApp/loginbyusernampassword/$username';

      // Call your API service
      final data = await getApiService.getApiServiceForLogin(url);

      // Check if response is null
      if (data == null) {
        throw Exception("No response from server");
      }

      // Ensure 'success' key exists and is a Map
      if (data['success'] == null || data['success'] is! Map<String, dynamic>) {
        final message = data['message'] ?? "Invalid credentials";
        throw Exception(message);
      }

      final successData = data['success'] as Map<String, dynamic>;

      // Optional: ensure the object is not empty
      if (successData.isEmpty) {
        final message = data['message'] ?? "Invalid credentials";
        throw Exception(message);
      }

      return data; // full response with result, message, two-fa, success
    } catch (e, stackTrace) {
      debugPrint("loginWithUserName error: $e\n$stackTrace");
      throw Exception("Login failed: ${e.toString()}");
    }
  }



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
