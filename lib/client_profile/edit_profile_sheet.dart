import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileSheet {
  static void show(BuildContext context, {VoidCallback? onUpdate}) async {
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

            // ২. ইমেজ পিক এবং আপলোড ফাংশন
            Future<void> _handleImageAction() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 35,
                maxWidth: 500,
              );

              if (image != null) {
                setSheetState(() => isUploading = true);
                try {
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

                  // ৩. প্রিভিউ আপডেট: ক্যাশ এড়াতে টাইমস্ট্যাম্প যোগ করা হয়েছে
                  final String rawUrl = storage.getPublicUrl(filePath);
                  setSheetState(() {
                    localPreviewUrl = "$rawUrl?v=${DateTime.now().millisecondsSinceEpoch}";
                    isUploading = false;
                  });

                } catch (e) {
                  setSheetState(() => isUploading = false);
                  debugPrint("Upload Error: $e");
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
                          child: ClipOval(
                            child: (localPreviewUrl != null || (currentUserData?['profile_image'] != null && currentUserData?['profile_image'] != ""))
                                ? Image.network(
                              localPreviewUrl ?? currentUserData!['profile_image'],
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                              key: ValueKey(localPreviewUrl), // এই Key-টি প্রিভিউ নিশ্চিত করে
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const CircularProgressIndicator();
                              },
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 55, color: goldColor),
                            )
                                : Icon(Icons.person, size: 55, color: goldColor),
                          ),
                        ),
                        if (isUploading) CircularProgressIndicator(color: goldColor),
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: _handleImageAction,
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                          // ডাটাবেসে সেভ করার সময় টাইমস্ট্যাম্প বাদে মূল লিঙ্ক রাখা হচ্ছে
                          final String? finalImageUrl = localPreviewUrl?.split('?').first ?? currentUserData?['profile_image'];

                          await _saveToDB(addressController.text.trim(), finalImageUrl);

                          if (context.mounted) {
                            if (onUpdate != null) onUpdate(); // মেইন স্ক্রিন রিফ্রেশ করবে
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

  static Future<void> _saveToDB(String address, String? imageUrl) async {
    try {
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await Supabase.instance.client.from('users').update({
          'address': address,
          'profile_image': imageUrl,
        }).eq('user_id', uid);
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }
}