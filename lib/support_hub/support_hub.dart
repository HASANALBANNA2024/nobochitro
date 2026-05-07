import 'dart:math' as math;
import 'package:nobochitro/main.dart';
import 'package:flutter/material.dart';
import 'package:nobochitro/support_hub/dynamic_chat_window.dart';

class SupportHub extends StatefulWidget {
  final Color primaryAccent;
  const SupportHub({super.key, required this.primaryAccent});

  @override
  State<SupportHub> createState() => _SupportHubState();
}

class _SupportHubState extends State<SupportHub>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Toggle menu animation and state
  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 700;

    return Stack(
      children: [
        Positioned(
          right: 20,
          bottom: isMobile
              ? 45
              : 45, // Set to 110 to stay above the Nav Bar on mobile
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isOpen) ...[
                // Option: WhatsApp
                _buildOption(
                  Icons.message,
                  const Color(0xFF25D366),
                  "WhatsApp",
                  2,
                      () {
                    // সরাসরি context ব্যবহার না করে navigatorKey এর context ব্যবহার করুন
                    final navContext = navigatorKey.currentContext;
                    if (navContext != null) {
                      showGeneralDialog(
                        context: navContext,
                        barrierDismissible: true,
                        barrierLabel: "Chat",
                        pageBuilder: (context, anim1, anim2) {
                          return DynamicChatWindow(
                            title: "Nobochitro Whatsapp",
                            primaryAccent: widget.primaryAccent,
                          );
                        },
                      );
                    }
                  },
                ),
                // Option: Messenger
                _buildOption(
                  Icons.facebook,
                  const Color(0xFF0084FF),
                  "Messenger",
                  1,
                  () {
                    print("Opening Messenger...");
                  },
                ),
                // Option: AI Support
                _buildOption(
                  Icons.auto_awesome,
                  widget.primaryAccent,
                  "AI Support",
                  0,
                  () {
                   print("Navigating to AI Support Screen...");
                  },
                ),
                const SizedBox(height: 12),
              ],
              GestureDetector(
                onTap: _toggleMenu,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * 0.75 * math.pi,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _isOpen
                              ? Colors.redAccent
                              : widget.primaryAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isOpen ? Icons.close : Icons.chat_bubble_rounded,
                          color: _isOpen ? Colors.white : Colors.black,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Updated helper to handle clicks and auto-close the menu
  Widget _buildOption(
    IconData icon,
    Color color,
    String label,
    int index,
    VoidCallback onTap,
  ) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _controller.value) * 15 * index),
          child: Opacity(
            opacity: _controller.value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  // Execute the custom logic (Navigate or URL)
                  onTap();
                  // Automatically close the options menu after selection
                  _toggleMenu();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isOpen)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        margin: const EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
