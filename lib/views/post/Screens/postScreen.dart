import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ridematch/views/chats/SocketScreenchat.dart';
import 'package:ridematch/views/chats/chatHistory/chathistoryScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String? senderId;

  final List<Map<String, dynamic>> _posts = [
    {
      "userId": "user101", // 👈 Receiver ID
      "userName": "Rahul Sharma",
      "userImage": "https://i.pravatar.cc/150?img=3",
      "from": "Indore",
      "to": "Bhopal",
      "date": "27 Oct 2025",
      "time": "10:30 AM",
      "note": "Leaving early tomorrow morning. Have 2 seats available.",
    },
    {
      "userId": "user102",
      "userName": "Priya Mehta",
      "userImage": "https://i.pravatar.cc/150?img=5",
      "from": "Ujjain",
      "to": "Indore",
      "date": "28 Oct 2025",
      "time": "5:00 PM",
      "note": "Commuting daily from Ujjain to Indore. Calm music & friendly chat 😄",
    },
    {
      "userId": "user103",
      "userName": "Rohit Verma",
      "userImage": "https://i.pravatar.cc/150?img=7",
      "from": "Dewas",
      "to": "Pithampur",
      "date": "29 Oct 2025",
      "time": "8:00 AM",
      "note": "Office ride — can take 2 more people. Fuel cost split equally.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSenderId();
  }

  Future<void> _loadSenderId() async {
    final prefs = await SharedPreferences.getInstance();
    // Example: stored during login
    setState(() {
      senderId = prefs.getString('userId') ?? 'user001'; // fallback
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChatHistoryScreen()));
              },
              icon: const Icon(Icons.chat, color: Colors.white),
            ),
          )
        ],
        backgroundColor: const Color(0xff113F67),
        title: Text(
          "Posts",
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  /// 🔹 Post Card Widget
  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔸 User Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(post['userImage']),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['userName'],
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${post['date']} • ${post['time']}",
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 🔸 From → To Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff113F67).withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 20, color: Color(0xff113F67)),
                    const SizedBox(width: 8),
                    Text(
                      "From: ",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        post['from'],
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.flag_rounded,
                        size: 20, color: Color(0xff113F67)),
                    const SizedBox(width: 8),
                    Text(
                      "To: ",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        post['to'],
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// 🔸 Note / Description
          Text(
            post['note'],
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 14),

          /// 🔸 Match + Chat Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff113F67),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'You sent a match request to ${post['userName']}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.favorite_rounded,
                    color: Colors.pinkAccent),
                label: const Text(
                  "Match",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xff113F67)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  if (senderId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please log in to start chatting.')));
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        senderId: senderId!,
                        receiverId: post['userId'], // 👈 receiver id from post
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded,
                    color: Color(0xff113F67)),
                label: const Text(
                  "Chat",
                  style: TextStyle(color: Color(0xff113F67)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
