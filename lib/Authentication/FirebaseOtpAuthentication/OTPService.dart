import 'package:firebase_auth/firebase_auth.dart';

class OTPService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send OTP to the phone number
  Future<void> sendOTP({
    required String phone,
    required Function(String verificationId) onCodeSent,
    Function()? onAutoVerified,
    Function(String error)? onFailed,
    int timeoutInMinutes = 5,
  }) async {

    print(phone);
    print(onCodeSent);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            if (onAutoVerified != null) onAutoVerified();
          } catch (e) {
            if (onFailed != null) onFailed("Auto verification failed: ${e.toString()}");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMsg;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMsg = "The phone number is not valid.";
              break;
            case 'quota-exceeded':
              errorMsg = "SMS quota exceeded. Try again later.";
              break;
            case 'user-disabled':
              errorMsg = "This user has been disabled.";
              break;
            default:
              errorMsg = e.message ?? "Verification failed due to unknown error.";
          }
          if (onFailed != null) onFailed(errorMsg);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Optionally notify user OTP auto-retrieval timed out
        },
        timeout: Duration(minutes: timeoutInMinutes),
      );
    } catch (e) {
      if (onFailed != null) onFailed("Failed to send OTP: ${e.toString()}");
    }
  }

  /// Verify OTP entered by user
  Future<bool> verifyOTP({
    required String verificationId,
    required String otp,
    Function(String? error)? onFailed,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      return true; // OTP correct
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMsg = "The OTP entered is invalid.";
          break;
        case 'session-expired':
          errorMsg = "OTP has expired. Please request a new one.";
          break;
        case 'user-disabled':
          errorMsg = "This user has been disabled.";
          break;
        default:
          errorMsg = e.message ?? "Failed to verify OTP.";
      }
      if (onFailed != null) onFailed(errorMsg);
      return false;
    } catch (e) {
      if (onFailed != null) onFailed("Unexpected error: ${e.toString()}");
      return false;
    }
  }
}
