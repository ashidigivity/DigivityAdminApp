import 'dart:async';
import 'dart:ui';

class OtpHelperForLoginUi {
  Timer? _resendTimer;
  Timer? _expireTimer;

  int resendSecondsRemaining = 0;
  int expireSecondsRemaining = 0;

  bool get isResendEnabled => resendSecondsRemaining <= 0;
  bool get isOtpExpired => expireSecondsRemaining <= 0;

  void startResendTimer({
    required int totalSeconds,
    required VoidCallback onTick,
    required VoidCallback onComplete,
  }) {
    resendSecondsRemaining = totalSeconds;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSecondsRemaining <= 0) {
        timer.cancel();
        onComplete();
      } else {
        resendSecondsRemaining--;
        onTick();
      }
    });
  }

  void startExpireTimer({
    required int totalSeconds,
    required VoidCallback onTick,
    required VoidCallback onExpire,
  }) {

    print(totalSeconds);
    _expireTimer?.cancel();
    expireSecondsRemaining = totalSeconds;
    _expireTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (expireSecondsRemaining > 0) {
        expireSecondsRemaining--;
        onTick();
      } else {
        timer.cancel();
        onExpire();
      }
    });
  }


  void cancelTimers() {
    _resendTimer?.cancel();
    _expireTimer?.cancel();
    resendSecondsRemaining = 0;
    expireSecondsRemaining = 0;
  }


  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
