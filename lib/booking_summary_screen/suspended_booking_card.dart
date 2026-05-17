import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class SuspendedBookingCard extends StatefulWidget {
  final Map<String, dynamic> booking;
  final bool isDark;
  final Color primaryAccent;
  final VoidCallback? onViewDetails;
  final VoidCallback? onAppeal;

  const SuspendedBookingCard({
    super.key,
    required this.booking,
    required this.isDark,
    required this.primaryAccent,
    this.onViewDetails,
    this.onAppeal,
  });

  @override
  State<SuspendedBookingCard> createState() => _SuspendedBookingCardState();
}

class _SuspendedBookingCardState extends State<SuspendedBookingCard> {
  late Map<String, dynamic> currentBooking;

  @override
  void initState() {
    super.initState();
    currentBooking = Map<String, dynamic>.from(widget.booking);
  }

  // 🚨 ৩ বার আপিল লিমিট শেষ হয়ে গেলে পপআপ ডায়ালগ মেসেজ
  void _showLimitExceededDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 10),
              Text(
                  "Limit Exceeded",
                  style: TextStyle(color: widget.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          content: Text(
            "Your appeal limit has been exceeded. You are not allowed to submit more appeals. Please contact our support team for further assistance.",
            style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87, fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // 📥 আপিল বটম শিট
  void _openInternalAppealSheet(BuildContext context, String bookingId, int currentCount) {
    final TextEditingController noteController = TextEditingController();
    final ImagePicker picker = ImagePicker();

    XFile? pickedXFile;
    dynamic fileToUpload;
    String? selectedFileName;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Submit Appeal (${currentCount + 1} of 3)",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text("Appeal Note (Reason)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: "Explain your issue clearly to the admin...",
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      filled: true,
                      fillColor: widget.isDark ? Colors.white10 : Colors.black12,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Attach Proof (Screenshot/Image)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        selectedFileName = image.name;
                        if (kIsWeb) {
                          final bytes = await image.readAsBytes();
                          setModalState(() {
                            pickedXFile = image;
                            fileToUpload = bytes;
                          });
                        } else {
                          setModalState(() {
                            pickedXFile = image;
                            fileToUpload = File(image.path);
                          });
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: pickedXFile == null ? 65 : 180,
                      decoration: BoxDecoration(
                        color: widget.isDark ? Colors.white10 : Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: pickedXFile == null ? Colors.grey.withOpacity(0.3) : Colors.green.withOpacity(0.5),
                        ),
                      ),
                      child: pickedXFile == null
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 18),
                          SizedBox(width: 8),
                          Text("Upload Image from Gallery", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      )
                          : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: kIsWeb
                                ? Image.memory(fileToUpload, width: double.infinity, height: 180, fit: BoxFit.cover)
                                : Image.file(fileToUpload as File, width: double.infinity, height: 180, fit: BoxFit.cover),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUploading ? null : () async {
                        String note = noteController.text.trim();
                        if (note.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please write an appeal note first!")));
                          return;
                        }
                        setModalState(() => isUploading = true);
                        try {
                          String? uploadedUrl;
                          if (fileToUpload != null && selectedFileName != null) {
                            // 📂 ১. কারেন্ট ইউজার আইডি তুলে আনা
                            String userId = await DatabaseHelper.instance.getCurrentUserId();

                            // ⏳ ২. এক্সাক্ট ডেট এবং টাইম ফরম্যাট করা (yyyyMMdd_HHmmss)
                            DateTime now = DateTime.now();
                            String timestamp = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_"
                                "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

                            // 📁 ৩. বাকেটের জন্য ইউনিক কাস্টম পাথ তৈরি (appeal_files/user_id/timestamp_filename)
                            String customBucketPath = "appeal_files/$userId/${timestamp}_$selectedFileName";

                            // ডাটাবেজ হেল্পারে ফাইল ও জেনারেট হওয়া কাস্টম পাথ পাঠিয়ে আপলোড করা
                            uploadedUrl = await DatabaseHelper.instance.uploadAppealImageWithPath(fileToUpload, customBucketPath);
                          }

                          int newCount = currentCount + 1;

                          await DatabaseHelper.instance.submitSuspensionAppeal(
                            bookingId: bookingId,
                            appealNote: note,
                            appealImageUrl: uploadedUrl,
                            appealCount: newCount,
                          );

                          setState(() {
                            currentBooking['appeal_status'] = 'appealed';
                            currentBooking['appeal_note'] = note;
                            currentBooking['appeal_count'] = newCount;
                            currentBooking['appeal_cancel_notes'] = null;
                            if (uploadedUrl != null) currentBooking['appeal_image_url'] = uploadedUrl;
                          });

                          if (widget.onAppeal != null) widget.onAppeal!();
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
                        } finally {
                          setModalState(() => isUploading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),
                      child: isUploading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Submit Appeal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 📦 ডেটা এক্সট্র্যাক্ট
    String bookingId = currentBooking['booking_id'] ?? "NB-00000";
    String packageTitle = currentBooking['package_name'] ?? "Photography Session";
    String dateStr = currentBooking['event_date'] ?? "N/A";
    String timeStr = currentBooking['event_time'] ?? "N/A";
    String locationStr = currentBooking['event_location'] ?? "N/A";
    String photographerName = currentBooking['photographer_name'] ?? "Not Assigned";
    String amountStr = "${currentBooking['total_amount']?.toString() ?? '0'} BDT";

    int appealCount = int.tryParse(currentBooking['appeal_count']?.toString() ?? '0') ?? 0;

    // 🔄 কলাম ট্র্যাকিং
    String bookingStatus = (currentBooking['booking_status'] ?? "").toString().trim().toLowerCase();
    String paymentStatus = (currentBooking['payment_status'] ?? "").toString().trim().toLowerCase();
    String appealStatus = (currentBooking['appeal_status'] ?? "").toString().trim().toLowerCase();

    // ২. অ্যাক্টিভ কন্ডিশন
    bool isApprovedAndActive = (bookingStatus == "approved" || bookingStatus == "active") &&
        (paymentStatus == "approved") &&
        (appealStatus == "approved");

    bool isAppealCancelled = appealStatus == "cancel" || appealStatus == "cancelled" || appealStatus == "rejected" || currentBooking['appeal_cancel_notes'] != null;
    bool isCurrentlyInFlight = appealStatus == "pending" || appealStatus == "appealed" || appealStatus == "processing";

    // 🚨 মেইন ট্র্যাকিং: ৩ বা তার বেশি হলে লিমিট শেষ!
    bool isLimitExceeded = appealCount >= 3;

    // ⏳ ৩-স্টেপ ডায়নামিক টাইমলাইন লজিক
    int currentStep = -1;
    if (appealStatus == "pending" || appealStatus == "appealed") {
      currentStep = 0;
    } else if (appealStatus == "processing") {
      currentStep = 1;
    } else if (appealStatus == "approved" || isApprovedAndActive || isAppealCancelled) {
      currentStep = 2;
    }

    // 🎨 ডায়নামিক টেক্সট ও কালার ম্যানেজমেন্ট
    Color statusBadgeColor = Colors.red;
    String statusBadgeText = "SUSPENDED";
    String accountStatusText = "Suspended State";

    if (isApprovedAndActive) {
      statusBadgeColor = Colors.green;
      statusBadgeText = "APPROVED & ACTIVE";
      accountStatusText = "Active State";
    } else if (isAppealCancelled) {
      statusBadgeColor = isLimitExceeded ? Colors.red : Colors.orange;
      statusBadgeText = isLimitExceeded ? "PERMANENT LOCKED" : "APPEAL CANCELLED";
      accountStatusText = isLimitExceeded ? "Max Limit Exceeded" : "Appeal Cancelled";
    } else if (isCurrentlyInFlight) {
      statusBadgeColor = Colors.blue;
      statusBadgeText = "APPEALED";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isApprovedAndActive ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔝 টপ হেডার (ব্যাজ এবং আইডি)
          Row(
            children: [
              Text("#$bookingId", style: TextStyle(color: widget.primaryAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text("$appealCount/3 Appeals", style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusBadgeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(statusBadgeText, style: TextStyle(color: statusBadgeColor, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(packageTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),

          // 💳 অ্যাকাউন্ট স্ট্যাটাস এরিয়া
          Row(
            children: [
              const Icon(Icons.wallet, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              const Text("Account Status: ", style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text(accountStatusText, style: TextStyle(color: statusBadgeColor, fontSize: 13, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                  isAppealCancelled
                      ? (currentBooking['appeal_cancel_notes'] ?? "No notes provided").toString()
                      : (currentBooking['suspended_note'] ?? "fraud payment").toString(),
                  style: TextStyle(fontSize: 13, color: widget.isDark ? Colors.white70 : Colors.black87)
              ),
            ],
          ),

          const Divider(height: 25, thickness: 0.5),

          // 📅 ইনফো সেকশন
          Row(
            children: [
              _infoTile(Icons.calendar_today, dateStr),
              const SizedBox(width: 20),
              _infoTile(Icons.access_time, timeStr),
            ],
          ),
          const SizedBox(height: 12),
          _infoTile(Icons.camera_alt_outlined, "Photographer: $photographerName"),
          const SizedBox(height: 12),
          _infoTile(Icons.location_on_outlined, locationStr),

          // ⚠️ সাসপেনশন বা ক্যানসেল নোটস লেআউট
          if (!isApprovedAndActive) ...[
            const Divider(height: 25, thickness: 0.5),



            const SizedBox(height: 20),

            // ⚖️ ৩-স্টেপ ক্লিন টাইমলাইন বার
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimelineStep("Request", currentStep >= 0, false),
                _buildTimelineArrow(currentStep >= 1),
                _buildTimelineStep("Processing", currentStep >= 1, false),
                _buildTimelineArrow(currentStep >= 2),
                _buildTimelineStep(isAppealCancelled ? "Rejected" : "Approved", currentStep >= 2, isAppealCancelled),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // 🔴 বোতাম অ্যাকশনস সেকশন
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onViewDetails ?? () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: statusBadgeColor),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("View Details", style: TextStyle(fontSize: 13, color: statusBadgeColor)),
                ),
              ),
              if (!isApprovedAndActive) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: isCurrentlyInFlight
                      ? ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                        appealStatus == "processing" ? "Processing" : "Appealed",
                        style: const TextStyle(fontSize: 13, color: Colors.white60)
                    ),
                  )
                      : ElevatedButton(
                    // 🧠 লজিক: কাউন্ট ৩ বা বেশি হলে বাটন ক্লিকেবল থাকবে কিন্তু চাপ দিলে সুন্দর পপআপ অ্যালার্ট আসবে
                    onPressed: isLimitExceeded
                        ? () => _showLimitExceededDialog(context)
                        : () => _openInternalAppealSheet(context, bookingId, appealCount),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLimitExceeded
                          ? Colors.grey.withOpacity(0.5)
                          : (isAppealCancelled ? Colors.orangeAccent : Colors.blueAccent),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                        isLimitExceeded ? "Limit Exceeded" : (isAppealCancelled ? "Re-Appeal" : "Appeal"),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, bool isActive, bool isErrorState) {
    Color stepColor = isActive ? (isErrorState ? Colors.red : Colors.green) : (widget.isDark ? Colors.white30 : Colors.black26);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isErrorState && isActive ? Icons.cancel : (isActive ? Icons.check_circle : Icons.radio_button_unchecked), size: 13, color: stepColor),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? (isErrorState ? Colors.red : (widget.isDark ? Colors.white : Colors.black87)) : Colors.grey)),
      ],
    );
  }

  Widget _buildTimelineArrow(bool isActive) {
    return Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 12.0), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("➔", style: TextStyle(fontSize: 10, color: isActive ? Colors.green : Colors.grey.withOpacity(0.3)))],),),);
  }

  Widget _infoTile(IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: Colors.grey), const SizedBox(width: 5), Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: widget.isDark ? Colors.white70 : Colors.black87)))],);
  }
}