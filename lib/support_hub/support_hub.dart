import 'dart:math' as math;

import 'package:flutter/material.dart';

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

    // overlay এর ভেতরে Positioned কাজ করার জন্য Stack ব্যবহার করা বাধ্যতামূলক
    return Stack(
      children: [
        Positioned(
          right: 20,
          // মোবাইলে ১১০ পিক্সেল উপরে, আর ওয়েব/ট্যাব এ ৪০ পিক্সেল উপরে
          bottom: isMobile ? 60 : 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isOpen) ...[
                _buildOption(
                  Icons.message,
                  const Color(0xFF25D366),
                  "WhatsApp",
                  3,
                ),
                _buildOption(
                  Icons.facebook,
                  const Color(0xFF0084FF),
                  "Messenger",
                  2,
                ),
                _buildOption(
                  Icons.auto_awesome,
                  widget.primaryAccent,
                  "AI Support",
                  1,
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

  Widget _buildOption(IconData icon, Color color, String label, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _controller.value) * 15 * index),
          child: Opacity(
            opacity: _controller.value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isOpen)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      margin: const EdgeInsets.only(right: 10),
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
                            decoration: TextDecoration
                                .none, // overlay এর টেক্সট এরর দূর করবে
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
        );
      },
    );
  }
}
