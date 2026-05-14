import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileSheet {
  static void show(BuildContext context, {VoidCallback? onUpdate}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color goldColor = const Color(0xFFD4AF37);

    // ১. ভেরিয়েবল সেটআপ
    XFile? selectedImageFile; // লোকাল ফাইল সেভ রাখার জন্য
    String? localPreviewPath; // লোকাল প্রিভিউ দেখানোর জন্য
    bool isProcessing = false; // লোডিং ইন্ডিকেটর

    Map<String, dynamic>? currentUserData;
    final String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;

    // ডাটাবেস থেকে বর্তমান তথ্য আনা (image_bce9a5.png অনুযায়ী)
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

    final TextEditingController addressController = TextEditingController(
      text: currentUserData?['address'] ?? "",
    );

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // ২. ইমেজ পিক করার ফাংশন (শুধু প্রিভিউ করবে, আপলোড নয়)
            Future<void> _pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 50,
              );

              if (image != null) {
                setSheetState(() {
                  selectedImageFile = image;
                  localPreviewPath = image.path; // লোকাল পাথ স্টোর করা
                });
              }
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "UPDATE PROFILE",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: goldColor,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // ৩. ইমেজ প্রিভিউ সেকশন
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: goldColor.withOpacity(0.1),
                          child: ClipOval(
                            child: localPreviewPath != null
                                ? (kIsWeb
                                      ? Image.network(
                                          localPreviewPath!,
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(localPreviewPath!),
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                        ))
                                : (currentUserData?['profile_image'] != null
                                      ? Image.network(
                                          currentUserData!['profile_image'],
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 55,
                                          color: goldColor,
                                        )),
                          ),
                        ),
                        if (isProcessing)
                          CircularProgressIndicator(color: goldColor),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: goldColor,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    TextField(
                      controller: addressController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: "Address",
                        labelStyle: TextStyle(color: goldColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ৪. ফাইনাল সেভ বাটন (এখানেই সব আপলোড এবং ডাটাবেস সেভ হবে)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // Save Button Logic
                        onPressed: isProcessing
                            ? null
                            : () async {
                                setSheetState(() => isProcessing = true);

                                String? finalImageUrl =
                                    currentUserData?['profile_image'];

                                try {
                                  // ১. যদি নতুন ইমেজ সিলেক্ট করা থাকে তবেই আপলোড হবে
                                  if (selectedImageFile != null) {
                                    final String fileName =
                                        'profile_${firebaseUid}.jpg';
                                    final storage = Supabase
                                        .instance
                                        .client
                                        .storage
                                        .from('user_assets');

                                    // ফাইল আপলোড (Upsert true রাখা হয়েছে যেন পুরনোটা রিপ্লেস হয়)
                                    if (kIsWeb) {
                                      final bytes = await selectedImageFile!
                                          .readAsBytes();
                                      await storage.uploadBinary(
                                        fileName,
                                        bytes,
                                        fileOptions: const FileOptions(
                                          upsert: true,
                                          contentType: 'image/jpeg',
                                        ),
                                      );
                                    } else {
                                      await storage.upload(
                                        fileName,
                                        File(selectedImageFile!.path),
                                        fileOptions: const FileOptions(
                                          upsert: true,
                                          contentType: 'image/jpeg',
                                        ),
                                      );
                                    }

                                    // ২. আপলোড সফল হলে পাবলিক ইউআরএল জেনারেট করা
                                    finalImageUrl = storage.getPublicUrl(
                                      fileName,
                                    );
                                    debugPrint(
                                      "Log: Image uploaded successfully. URL: $finalImageUrl",
                                    );
                                  }

                                  // ৩. ডাটাবেস আপডেট (ইমেজ লিঙ্ক এবং অ্যাড্রেস একসাথে)
                                  final response = await Supabase
                                      .instance
                                      .client
                                      .from('users')
                                      .update({
                                        'address': addressController.text
                                            .trim(),
                                        'profile_image':
                                            finalImageUrl, // এখানে এখন সঠিক লিঙ্ক যাবে
                                      })
                                      .eq('user_id', firebaseUid!);

                                  debugPrint(
                                    "Log: Database update status: $response",
                                  );

                                  if (context.mounted) {
                                    if (onUpdate != null)
                                      onUpdate(); // মেইন প্রোফাইল স্ক্রিন রিফ্রেশ
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Profile Updated Successfully!",
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // ৪. যদি কোনো এরর হয় তবে তা এখানে দেখাবে
                                  debugPrint("Final Error Log: $e");
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Update Failed: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  setSheetState(() => isProcessing = false);
                                }
                              },
                        child: isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "SAVE CHANGES",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
}
