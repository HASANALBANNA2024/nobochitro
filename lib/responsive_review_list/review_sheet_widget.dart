import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'review_controller.dart';

class ReviewService {
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color tealColor = Color(0xFF008080);
  static const Color surfaceColor = Color(0xFF131313);

  static void showReviewSheet(BuildContext context, {dynamic booking}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ReviewSheet",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: _DynamicReviewSheet(booking: booking),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(anim1),
          child: child,
        );
      },
    );
  }
}

class _DynamicReviewSheet extends StatefulWidget {
  final dynamic booking;
  const _DynamicReviewSheet({super.key, this.booking});

  @override
  State<_DynamicReviewSheet> createState() => _DynamicReviewSheetState();
}

class _DynamicReviewSheetState extends State<_DynamicReviewSheet> {
  final ReviewController _controller = ReviewController();
  bool _isUserLoaded = false;
  final Map<String, Uint8List> _webImageCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSheet();
    });
  }

  void _initializeSheet() async {
    if (widget.booking != null && widget.booking is Map) {
      final Map<String, dynamic> bData = Map<String, dynamic>.from(
        widget.booking as Map,
      );

      String extractedName = bData['user_name']?.toString() ?? "";
      String extractedEmail =
          bData['user_email']?.toString() ?? bData['email']?.toString() ?? "";
      String? extractedAvatar =
          bData['user_avatar']?.toString() ??
          bData['profile_image']?.toString();

      _controller.setManualUserInformation(
        name: extractedName,
        email: extractedEmail,
        avatarUrl: extractedAvatar,
      );
    }

    try {
      await _controller.loadUserInformation();
    } catch (e) {
      debugPrint("Error loading user info: $e");
    }

    if (!mounted) return;

    setState(() {
      if (widget.booking != null && widget.booking is Map) {
        String package =
            widget.booking['package_name'] ?? "Photography Session";
        String photographer =
            widget.booking['photographer_name'] ?? "NoboChitro Team";
        String category =
            widget.booking['package_category'] ??
            widget.booking['category_name'] ??
            "Nature";

        _controller.reviewController.text =
            "Amazing experience with #$package package under $category category. Special thanks to Photographer: @$photographer! ";
      } else {
        _controller.reviewController.text = "";
      }
      _isUserLoaded = true;
    });
  }

  Future<Uint8List> _getImageBytes(String path, int index) async {
    if (_webImageCache.containsKey(path)) {
      return _webImageCache[path]!;
    }
    if (index >= _controller.selectedImages.length) {
      return Uint8List(0);
    }
    final bytes = await _controller.selectedImages[index].readAsBytes();
    _webImageCache[path] = bytes;
    return bytes;
  }

  void _handleFinalSubmit() async {
    Map<String, dynamic>? bookingData;
    if (widget.booking is Map) {
      bookingData = Map<String, dynamic>.from(widget.booking as Map);
    }

    bool isSuccess = await _controller.submitReview(
      context: context,
      bookingData: bookingData,
      onLoadingToggle: () {
        if (mounted) setState(() {});
      },
    );

    if (isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Review posted successfully! 🎉"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double sheetWidth = kIsWeb
        ? (screenWidth > 600 ? 550 : screenWidth)
        : screenWidth;

    String displaySubtitle =
        widget.booking is Map && widget.booking['package_name'] != null
        ? "Reviewing: ${widget.booking['package_name']}"
        : "Posting global review";

    String userNameToShow = _controller.displayName.isNotEmpty
        ? _controller.displayName
        : "User";

    return Container(
      width: sheetWidth,
      margin: EdgeInsets.only(bottom: bottomInset),
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: const BoxDecoration(
        color: ReviewService.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: !_isUserLoaded
          ? const SizedBox(
              height: 250,
              child: Center(
                child: CupertinoActivityIndicator(
                  color: Colors.white,
                  radius: 15,
                ),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey[800],
                        child: ClipOval(
                          child:
                              (_controller.userPhotoUrl != null &&
                                  _controller.userPhotoUrl!.startsWith('http'))
                              ? Image.network(
                                  _controller.userPhotoUrl!,
                                  fit: BoxFit.cover,
                                  width: 44,
                                  height: 44,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      color: Colors.white70,
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CupertinoActivityIndicator(
                                            radius: 8,
                                          ),
                                        );
                                      },
                                )
                              : const Icon(Icons.person, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userNameToShow,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displaySubtitle,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 25),
                  const Text(
                    "Share Experience",
                    style: TextStyle(
                      color: ReviewService.goldColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => GestureDetector(
                          onTap: () =>
                              setState(() => _controller.rating = index + 1),
                          child: Icon(
                            index < _controller.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: index < _controller.rating
                                ? Colors.amber
                                : Colors.white10,
                            size: 42,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller.reviewController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Write your review here...",
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (_controller.selectedImages.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _controller.selectedImages.length,
                        itemBuilder: (context, index) {
                          if (index >= _controller.selectedImages.length) {
                            return const SizedBox.shrink();
                          }
                          final imageFile = _controller.selectedImages[index];
                          return Stack(
                            key: ValueKey("${imageFile.path}_$index"),
                            children: [
                              FutureBuilder<Uint8List>(
                                future: _getImageBytes(imageFile.path, index),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData &&
                                      snapshot.data!.isNotEmpty) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      width: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: MemoryImage(snapshot.data!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                right: 12,
                                top: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    _webImageCache.remove(imageFile.path);
                                    _controller.removeImage(index, () {
                                      if (mounted) setState(() {});
                                    });
                                  },
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  Row(
                    children: [
                      _actionButton(Icons.camera_alt_outlined, "Add Photo", () {
                        _controller.pickImage(() {
                          if (mounted) setState(() {});
                        });
                      }),
                      const SizedBox(width: 10),
                      _actionButton(Icons.person_add_alt_1_outlined, "Tag", () {
                        setState(() {
                          _controller.reviewController.text +=
                              " #Photography_Session ";
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 25),

                  /// Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _controller.isLoading
                          ? null
                          : _handleFinalSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ReviewService.goldColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: _controller.isLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.black,
                            )
                          : const Text(
                              "POST REVIEW",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: ReviewService.tealColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
