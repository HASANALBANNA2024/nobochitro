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

    // Variable setup
    XFile? selectedImageFile; // local file save
    String? localPreviewPath; // local preview
    bool isProcessing = false; // loading indicator

    Map<String, dynamic>? currentUserData;
    final String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;

    // to receive database present image
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
            // image picture to pickup function
            Future<void> _pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                maxHeight: 100,
                maxWidth: 100,
                imageQuality: 20,
              );

              if (image != null) {
                setSheetState(() {
                  selectedImageFile = image;
                  localPreviewPath = image.path; // local path store
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

                    // image preview section
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
                              // এখানে টাইমস্ট্যাম্প যুক্ত করো, এতে অ্যাপ নতুন ইমেজটি লোড করবে
                              "${currentUserData!['profile_image']}?t=${DateTime.now().millisecondsSinceEpoch}",
                              key: ValueKey(currentUserData['profile_image']), // কি (key) দেওয়ার ফলে নতুন ইমেজ আসলে এটি রি-বিল্ড হবে
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

                    // final save button
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

                        onPressed: isProcessing
                            ? null
                            : () async {
                          setSheetState(() => isProcessing = true);

                          final String customerId = currentUserData?['id']?.toString() ?? "unknown";
                          String? newImageUrl = currentUserData?['profile_image'];

                          try {
                            if (selectedImageFile != null) {
                              if (customerId == "unknown") throw Exception("Customer ID not found!");

                              final String fileName = 'profile_user_image/$customerId.jpg';
                              final storage = Supabase.instance.client.storage.from('user_assets');

                              // cacheControl: '0' যোগ করা হলো যাতে সার্ভার ক্যাশ না রাখে
                              final fileOptions = const FileOptions(
                                upsert: true,
                                contentType: 'image/jpeg',
                                cacheControl: '0',
                              );

                              if (kIsWeb) {
                                final bytes = await selectedImageFile!.readAsBytes();
                                await storage.uploadBinary(fileName, bytes, fileOptions: fileOptions);
                              } else {
                                await storage.upload(fileName, File(selectedImageFile!.path), fileOptions: fileOptions);
                              }

                              // টাইমস্ট্যাম্পসহ নতুন URL সেট করা
                              newImageUrl = "${storage.getPublicUrl(fileName)}?t=${DateTime.now().millisecondsSinceEpoch}";
                            }

                            // ডাটাবেস আপডেট
                            await Supabase.instance.client
                                .from('users')
                                .update({
                              'address': addressController.text.trim(),
                              'profile_image': newImageUrl,
                            })
                                .eq('user_id', firebaseUid!);

                            debugPrint("Log: Database updated successfully with image: $newImageUrl");

                            if (context.mounted) {
                              if (onUpdate != null) onUpdate();
                              Navigator.pop(context);
                              // ScaffoldMessenger.(
                              //   const SnackBar(content: Text("Profile Updated Successfully!")),
                              // );
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated Successfully!")));
                            }
                          } catch (e) {
                            debugPrint("Final Error Log: $e");
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Update Failed: $e"), backgroundColor: Colors.red),
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
