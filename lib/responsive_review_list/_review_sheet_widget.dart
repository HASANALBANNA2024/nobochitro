// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// class ReviewService {
//   static const Color goldColor = Color(0xFFD4AF37);
//   static const Color tealColor = Color(0xFF008080);
//   static const Color surfaceColor = Color(0xFF131313);
//
//   static void showReviewSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const _DynamicReviewSheet(),
//     );
//   }
// }
//
// class _DynamicReviewSheet extends StatefulWidget {
//   const _DynamicReviewSheet({super.key});
//
//   @override
//   State<_DynamicReviewSheet> createState() => _DynamicReviewSheetState();
// }
//
// class _DynamicReviewSheetState extends State<_DynamicReviewSheet> {
//   int _rating = 0;
//   final TextEditingController _reviewController = TextEditingController();
//
//   // ইমেজ লিস্ট (একাধিক ছবি নেওয়ার সুবিধার জন্য লিস্ট রাখা ভালো)
//   final List<File> _selectedImages = [];
//   final ImagePicker _picker = ImagePicker();
//
//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 50,
//     );
//     if (image != null) {
//       setState(() {
//         _selectedImages.add(File(image.path));
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bottomInset = MediaQuery.of(context).viewInsets.bottom;
//
//     return Container(
//       constraints: BoxConstraints(
//         maxHeight:
//             MediaQuery.of(context).size.height *
//             0.85, // স্ক্রিনের ৮৫% এর বেশি বড় হবে না
//       ),
//       padding: EdgeInsets.fromLTRB(20, 15, 20, bottomInset + 20),
//       decoration: const BoxDecoration(
//         color: ReviewService.surfaceColor,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       child: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Handlebar
//             Center(
//               child: Container(
//                 width: 45,
//                 height: 5,
//                 margin: const EdgeInsets.only(bottom: 20),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[850],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//
//             const Text(
//               "Share Experience",
//               style: TextStyle(
//                 color: ReviewService.goldColor,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // ১. রেটিং সেকশন
//             Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   5,
//                   (index) => GestureDetector(
//                     onTap: () => setState(() => _rating = index + 1),
//                     child: Icon(
//                       index < _rating
//                           ? Icons.star_rounded
//                           : Icons.star_outline_rounded,
//                       color: index < _rating ? Colors.amber : Colors.white10,
//                       size: 40,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // ২. কমেন্ট বক্স
//             TextField(
//               controller: _reviewController,
//               maxLines: 4,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: "What's on your mind?",
//                 hintStyle: const TextStyle(color: Colors.white24),
//                 filled: true,
//                 fillColor: Colors.white.withOpacity(0.05),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 15),
//
//             // ৩. ইমেজ প্রিভিউ সেকশন (ওভারফ্লো প্রতিরোধ করবে)
//             if (_selectedImages.isNotEmpty)
//               Container(
//                 margin: const EdgeInsets.only(bottom: 15),
//                 height: 90, // ফিক্সড হাইট যাতে ফ্লেক্সিবল থাকে
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _selectedImages.length,
//                   itemBuilder: (context, index) {
//                     return Stack(
//                       children: [
//                         Container(
//                           margin: const EdgeInsets.only(right: 10),
//                           width: 80,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             image: DecorationImage(
//                               image: FileImage(_selectedImages[index]),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           right: 12,
//                           top: 2,
//                           child: GestureDetector(
//                             onTap: () =>
//                                 setState(() => _selectedImages.removeAt(index)),
//                             child: const CircleAvatar(
//                               radius: 10,
//                               backgroundColor: Colors.red,
//                               child: Icon(
//                                 Icons.close,
//                                 size: 12,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//
//             // ৪. টুলস বাটন (অ্যাড ফটো)
//             Row(
//               children: [
//                 _actionButton(
//                   Icons.camera_alt_outlined,
//                   "Add Photo",
//                   _pickImage,
//                 ),
//                 const SizedBox(width: 10),
//                 _actionButton(Icons.person_add_alt_1_outlined, "Tag", () {}),
//               ],
//             ),
//
//             const SizedBox(height: 25),
//
//             // ৫. পোস্ট বাটন
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: ReviewService.goldColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   elevation: 5,
//                 ),
//                 child: const Text(
//                   "POST REVIEW",
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.white10),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: ReviewService.tealColor, size: 18),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: const TextStyle(color: Colors.white70, fontSize: 13),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
