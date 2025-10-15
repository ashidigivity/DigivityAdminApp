import 'package:digivity_admin_app/Helpers/getApiService.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  Future<String> sendOTP({required String phone}) async {
    String verificationId = '';
    await _auth.verifyPhoneNumber(
      phoneNumber: phone.startsWith('+') ? phone : '+91$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        throw Exception(e.message ?? "OTP verification failed");
      },
      codeSent: (vid, _) {
        verificationId = vid;
      },
      codeAutoRetrievalTimeout: (vid) {},
      timeout: const Duration(minutes: 5),
    );
    return verificationId;
  }

  /// Verify OTP
  Future<bool> verifyOTP({required String verificationId, required String otp}) async {
    try {
      final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp);
      await _auth.signInWithCredential(credential);
      return true;
    } catch (_) {
      return false;
    }
  }
}
