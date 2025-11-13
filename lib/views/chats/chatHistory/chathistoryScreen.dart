import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chatList = [
      {
        "name": "Rohit Sharma",
        "lastMessage": "Hey! Are you still sharing the cab?",
        "time": "10:24 AM",
        "unread": 2,
        "profile": "https://i.pravatar.cc/150?img=3"
      },
      {
        "name": "Aditi Verma",
        "lastMessage": "Thanks for confirming the ride!",
        "time": "09:58 AM",
        "unread": 0,
        "profile": "https://i.pravatar.cc/150?img=5"
      },
      {
        "name": "Ridesafe Group",
        "lastMessage": "Next ride from Indore to Bhopal tomorrow 🚗",
        "time": "Yesterday",
        "unread": 5,
        "profile": "https://i.pravatar.cc/150?img=9"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Chats",
          style: GoogleFonts.poppins(
            color: const Color(0xff09205f),
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, color: Color(0xff09205f)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xff09205f)),
          ),
        ],
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final chat = chatList[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(chat["profile"]),
                  ),
                  if (chat["unread"] > 0)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                chat["name"],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: const Color(0xff09205f),
                ),
              ),
              subtitle: Text(
                chat["lastMessage"],
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    chat["time"],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (chat["unread"] > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xff09205f),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        chat["unread"].toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                // Navigate to chat detail screen
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xff09205f),
        child: const Icon(Icons.message_rounded, color: Colors.white),
      ),
    );
  }
}
