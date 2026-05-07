import 'package:flutter/material.dart';

class DynamicChatWindow extends StatefulWidget {
  final String title; // WhatsApp, Messenger, or Customer Care
  final Color primaryAccent;

  const DynamicChatWindow({
    super.key,
    required this.title,
    required this.primaryAccent,
  });

  @override
  State<DynamicChatWindow> createState() => _DynamicChatWindowState();
}

class _DynamicChatWindowState extends State<DynamicChatWindow> {
  bool _isMaximized = false;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hello! How can we help you today?", "isMe": false},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 700;

    // ডেস্কটপ ভিউতে সাইজ নির্ধারণ
    double width = isMobile ? size.width : (_isMaximized ? size.width * 0.8 : 350);
    double height = isMobile ? size.height : (_isMaximized ? size.height * 0.8 : 500);

    return Center( // ডেস্কটপে মাঝখানে বা পজিশনড রাখা যায়
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: width,
        height: height,
        curve: Curves.easeInOut,
        margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(isMobile ? 0 : 20),
          boxShadow: [
            if (!isMobile)
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 0 : 20),
          child: Scaffold(
            appBar: _buildAppBar(isMobile),
            body: Column(
              children: [
                Expanded(child: _buildMessageList()),
                _buildMessageInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- AppBar with Maximize/Minimize ---
  PreferredSizeWidget _buildAppBar(bool isMobile) {
    return AppBar(
      backgroundColor: widget.primaryAccent,
      elevation: 0,
      automaticallyImplyLeading: isMobile,
      title: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            widget.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
      actions: [
        if (!isMobile) ...[
          IconButton(
            icon: Icon(_isMaximized ? Icons.close_fullscreen : Icons.open_in_full, size: 20, color: Colors.white),
            onPressed: () => setState(() => _isMaximized = !_isMaximized),
          ),
          IconButton(
            icon: const Icon(Icons.minimize, size: 20, color: Colors.white),
            onPressed: () => Navigator.pop(context), // মিনিমাইজ মানে এখানে ক্লোজ ধরা হয়েছে
          ),
        ],
        if (isMobile)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
      ],
    );
  }

  // --- Message List ---
  Widget _buildMessageList() {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return Align(
          alignment: msg['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: msg['isMe'] ? widget.primaryAccent : Colors.grey[200],
              borderRadius: BorderRadius.circular(15).copyWith(
                bottomRight: msg['isMe'] ? const Radius.circular(0) : const Radius.circular(15),
                bottomLeft: msg['isMe'] ? const Radius.circular(15) : const Radius.circular(0),
              ),
            ),
            child: Text(
              msg['text'],
              style: TextStyle(color: msg['isMe'] ? Colors.white : Colors.black87),
            ),
          ),
        );
      },
    );
  }

  // --- Input Area ---
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1.0, // আপনি চাইলে উইডথ দিতে পারেন
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: widget.primaryAccent,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    _messages.add({"text": _messageController.text, "isMe": true});
                    _messageController.clear();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}