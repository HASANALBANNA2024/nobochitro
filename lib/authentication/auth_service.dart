import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //----Sign up---------
  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // Email and password to create user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // User Unique ID
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'phone': phone, //Mobile Number
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

  // --- Login ---
  Future<User?> logIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // --- Email Reset Link
  Future<void> sendEmailResetLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password Reset Link");
    } catch (e) {
      throw Exception("Email Sent Problem: $e");
    }
  }

  // ---Phone OTP ---
  Future<void> sendPhoneOTP({
    required String phoneNumber,
    required Function(String verId) onCodeSent,
    required Function(FirebaseAuthException e) onFailed,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android Auto Verify
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

  // --- OTP Verify  ---
  Future<User?> verifyOTPAndLogin(String verId, String smsCode) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verId, smsCode: smsCode);
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print("ভুল ওটিপি কোড: $e");
      return null;
    }
  }

  // ---Password Change  ---
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