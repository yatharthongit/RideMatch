import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    connectSocket();
    fetchMessages();
  }

  void connectSocket() {
    socket = IO.io(
      'http://127.0.0.1:5000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('🟢 Connected to Socket.IO');
      socket.emit('register', widget.senderId);
    });

    // ✅ Listen for incoming messages
    socket.on('receiveMessage', (data) {
      if (!mounted) return;
      setState(() {
        messages.add({
          'senderId': data['senderId'],
          'message': data['message'],
          'timestamp': DateTime.now().toString(),
        });
      });
      _scrollToBottom();
    });
  }

  Future<void> fetchMessages() async {
    final url = Uri.parse(
        'http://127.0.0.1:5000/api/chat/${widget.senderId}/${widget.receiverId}');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      setState(() {
        messages = data
            .map((e) => {
          'senderId': e['senderId'],
          'message': e['message'],
          'timestamp': e['createdAt'] ?? e['timestamp'],
        })
            .toList();
      });
      _scrollToBottom();
    }
  }

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Emit message to backend
    socket.emit('sendMessage', {
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'message': text,
    });

    // ✅ Also locally add it for instant UI update
    setState(() {
      messages.add({
        'senderId': widget.senderId,
        'message': text,
        'timestamp': DateTime.now().toString(),
      });
    });
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xff113F67),
        title: Text(
          "Chat with ${widget.receiverId}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[i];
                final isMe = msg['senderId'] == widget.senderId;

                return Align(
                  alignment:
                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xff113F67).withOpacity(0.8)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['message'],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                CircleAvatar(
                  backgroundColor: const Color(0xff113F67),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
