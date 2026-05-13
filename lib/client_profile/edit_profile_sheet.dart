import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileSheet {
  static void show(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color goldColor = const Color(0xFFD4AF37);

    String? localPreviewUrl;
    bool isUploading = false;
    Map<String, dynamic>? currentUserData;
    final String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;

    // ১. সুপাবেস থেকে বর্তমান ডাটা ফেচ করা
    try {
      if (firebaseUid != null) {
        currentUserData = await Supabase.instance.client
            .from('users')
            .select()
            .eq('user_id', firebaseUid)
            .maybeSingle();
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }

    final TextEditingController addressController =
    TextEditingController(text: currentUserData?['address'] ?? "");

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {

            // ২. ইমেজ পিক এবং আপলোড লজিক
            Future<void> _pickAndUpload(ImageSource source) async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: source,
                imageQuality: 35,
                maxWidth: 500,
              );

              if (image != null) {
                setSheetState(() => isUploading = true);
                try {
                  // আপনার নতুন পলিসি অনুযায়ী ফাইল পাথ (private/ বাদ দেওয়া হয়েছে)
                  final String filePath = 'profile_$firebaseUid.jpg';
                  final storage = Supabase.instance.client.storage.from('user_assets');

                  // ফাইল আপলোড (Upsert: true মানে পুরানো ছবি রিপ্লেস হবে)
                  if (kIsWeb) {
                    final bytes = await image.readAsBytes();
                    await storage.uploadBinary(
                        filePath,
                        bytes,
                        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg')
                    );
                  } else {
                    await storage.upload(
                        filePath,
                        File(image.path),
                        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg')
                    );
                  }

                  // পাবলিক ইউআরএল জেনারেট
                  final String rawUrl = storage.getPublicUrl(filePath);

                  setSheetState(() {
                    // ক্যাশ রিফ্রেশ করতে টাইমস্ট্যাম্প যোগ করা হয়েছে যাতে স্ক্রিনে সাথে সাথে পরিবর্তন দেখা যায়
                    localPreviewUrl = "$rawUrl?v=${DateTime.now().millisecondsSinceEpoch}";
                    isUploading = false;
                  });

                  debugPrint("Success: Image uploaded to user_assets bucket.");
                } catch (e) {
                  setSheetState(() => isUploading = false);
                  debugPrint("Detailed Upload Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Upload Error: $e")),
                  );
                }
              }
            }

            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 15),
                    Text("UPDATE PROFILE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: goldColor)),
                    const SizedBox(height: 25),

                    // ইমেজ প্রিভিউ সেকশন
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: goldColor.withOpacity(0.1),
                          backgroundImage: localPreviewUrl != null
                              ? NetworkImage(localPreviewUrl!)
                              : (currentUserData?['profile_image'] != null && currentUserData?['profile_image'] != ""
                              ? NetworkImage(currentUserData!['profile_image'])
                              : null),
                          child: (localPreviewUrl == null && (currentUserData?['profile_image'] == null || currentUserData?['profile_image'] == ""))
                              ? Icon(Icons.person, size: 55, color: goldColor)
                              : null,
                        ),
                        if (isUploading) CircularProgressIndicator(color: goldColor),
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: () => _pickAndUpload(ImageSource.gallery),
                            child: CircleAvatar(
                                radius: 18,
                                backgroundColor: goldColor,
                                child: const Icon(Icons.camera_alt, size: 18, color: Colors.black)
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    TextField(
                      controller: addressController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: "Address",
                        labelStyle: TextStyle(color: goldColor),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: goldColor.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: goldColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: goldColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        onPressed: isUploading ? null : () async {
                          // টাইমস্ট্যাম্প বাদে শুধু মূল লিঙ্কটি ডাটাবেসে সেভ করা হচ্ছে
                          final String? finalImageUrl = localPreviewUrl?.split('?').first ?? currentUserData?['profile_image'];

                          await _saveToDB(addressController.text.trim(), finalImageUrl);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Profile Updated Successfully!")),
                            );
                          }
                        },
                        child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ৩. ডাটাবেস আপডেট লজিক
  static Future<void> _saveToDB(String address, String? imageUrl) async {
    try {
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await Supabase.instance.client.from('users').update({
          'address': address,
          'profile_image': imageUrl,
        }).eq('user_id', uid);
        debugPrint("Database sync successful!");
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }
}