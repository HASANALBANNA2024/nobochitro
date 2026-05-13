import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ফোন নম্বর ফরম্যাট করার জন্য প্রাইভেট মেথড (+88 যুক্ত করবে)
  String _formatPhoneNumber(String phone) {
    String p = phone.trim();
    if (p.startsWith('+88')) {
      return p;
    } else if (p.startsWith('88')) {
      return '+$p';
    } else if (p.startsWith('0')) {
      return '+88$p';
    } else {
      return '+880$p';
    }
  }

  //---- Sign up (Email & Password) ---------
  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String CustomId,
  }) async {
    try {
      // ফোন নম্বর ফরম্যাট করা
      String formattedPhone = _formatPhoneNumber(phone);

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'custom_id': CustomId,
          'name': name,
          'email': email,
          'phone': formattedPhone,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      print("Registration Error: $e");
      return null;
    }
  }

  // --- Login (Email & Password) ---
  Future<User?> logIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // --- Email Password Reset Link ---
  Future<void> sendEmailResetLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Email Sent Problem: $e");
    }
  }

  // --- Phone OTP (For Registration or Password Reset) ---
  // এখানে phoneNumber দিলে অটোমেটিক +88 অ্যাড হয়ে যাবে
  Future<void> sendPhoneOTP({
    required String phoneNumber,
    required Function(String verId) onCodeSent,
    required Function(FirebaseAuthException e) onFailed,
  }) async {
    try {
      String formattedPhone = _formatPhoneNumber(phoneNumber);

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: onFailed,
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      print("OTP Sent Problem: $e");
    }
  }

  // --- OTP Verify & Login ---
  Future<User?> verifyOTPAndLogin(String verId, String smsCode) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: smsCode,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print("ভুল ওটিপি কোড: $e");
      return null;
    }
  }

  // --- Password Change (ইউজার লগইন থাকা অবস্থায়) ---
  Future<bool> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        return true;
      }
      return false;
    } catch (e) {
      print("Password Update Error: $e");
      return false;
    }
  }

  // --- User Info and Log out ---
  String? getCurrentUID() => _auth.currentUser?.uid;

  Future<void> logOut() async {
    await _auth.signOut();
  }
}