import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridematch/views/profile/cards/help/HelpCenter.dart';
import 'package:ridematch/views/profile/cards/myrides.dart';
import 'package:ridematch/views/profile/cards/verfied%20document/verfiedDoc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// 🧾 Fetch user data
  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.29.206:5000/api/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data['user'] ?? data;
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        logout();
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Error fetching profile: $e");
      setState(() => isLoading = false);
    }
  }

  /// 🚪 Logout function
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  /// 🖼 Pick profile image
  Future<void> pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
      await uploadProfileImage(_profileImage!);
    }
  }

  /// ⬆ Upload new profile picture
  Future<void> uploadProfileImage(File image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.29.206:5000/api/auth/upload-profile'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('profile', image.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      await fetchUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile picture updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Failed to upload profile image")),
      );
    }
  }

  /// 🧱 UI starts here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff113F67),
        title: Center(
          child: Text(
            "Profile",
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 🧍 Profile Image
              GestureDetector(
                onTap: pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (userData?['profileUrl'] != null
                          ? NetworkImage(userData!['profileUrl'])
                          : const AssetImage(
                          'assets/images/default_avatar.png')
                      as ImageProvider),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff09205f),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              /// 🧾 Name + Email
              Text(
                userData?['name'] ?? 'Guest User',
                style: GoogleFonts.dmSans(
                  color: const Color(0xff09205f),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userData?['email'] ?? 'user@email.com',
                style: GoogleFonts.dmSans(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),

              /// 🪪 Account Info
              _sectionTitle("Account Information"),
              _infoCard("Full Name", userData?['name'] ?? "Not available"),
              _infoCard("Email", userData?['email'] ?? "Not available"),
              _infoCard("Phone", userData?['phone'] ?? "Not linked"),
              _infoCard(
                  "Member Since",
                  (userData?['createdAt'] != null)
                      ? userData!['createdAt']
                      .toString()
                      .substring(0, 10)
                      : "N/A"),

              const SizedBox(height: 30),

              /// 🚗 Activities
              _sectionTitle("Your Activities"),
              _optionCard(Icons.document_scanner, "Verified Document",
                      () {
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return VerifiedDoc();
                        }));

                      }),
              _optionCard(Icons.directions_car_rounded, "My Rides", () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return MyRidesScreen();
                }));
              }),
              _optionCard(Icons.wallet_rounded, "Payment Methods", () {
                Navigator.pushNamed(context, '/payments');
              }),
              _optionCard(
                  Icons.support_agent_rounded, "Help Center", () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return HelpCenterPage() ;
                }));
              }),

              const SizedBox(height: 30),

              /// ⚙️ Settings
              _sectionTitle("Settings"),
              _optionCard(
                  Icons.lock_rounded, "Privacy & Security", () {
                Navigator.pushNamed(context, '/privacy');
              }),
              _optionCard(Icons.notifications_rounded, "Notifications",
                      () {
                    Navigator.pushNamed(context, '/notifications');
                  }),
              _optionCard(Icons.language_rounded, "Language Preferences",
                      () {
                    Navigator.pushNamed(context, '/languages');
                  }),
              _optionCard(Icons.info_outline_rounded, "About App", () {
                Navigator.pushNamed(context, '/about');
              }),

              const SizedBox(height: 30),

              /// 🚪 Logout Button
              GestureDetector(
                onTap: logout,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Log Out",
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🧾 Section Title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.dmSans(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  /// 📋 Info Card
  Widget _infoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(color: Colors.black54, fontSize: 14)),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// ⚙️ Option Card (Now Clickable)
  Widget _optionCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff09205f), size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.black38, size: 16),
          ],
        ),
      ),
    );
  }
}
