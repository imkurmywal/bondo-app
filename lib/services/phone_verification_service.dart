import 'package:firebase_auth/firebase_auth.dart';

class PhoneVerificationService {
  static Future<void> verify(
      {String number,
      PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout,
      PhoneCodeSent phoneCodeSent,
      PhoneVerificationCompleted phoneVerificationCompleted,
      PhoneVerificationFailed phoneVerificationFailed}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: number,
        timeout: const Duration(seconds: 3),
        verificationCompleted: phoneVerificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout);
  }

  static verifyOtp(String verificationId, String smsCode) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final AuthResult result =
        await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
