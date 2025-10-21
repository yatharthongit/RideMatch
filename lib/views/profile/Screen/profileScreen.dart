import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
        setState(() {
          userData = json.decode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        logout();
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
      await uploadProfileImage(_profileImage!);
    }
  }

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
      fetchUserData(); // refresh profile data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload profile image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : Column(
          children: [
            const SizedBox(height: 30),

            // Profile Header
            Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (userData?['profileUrl'] != null
                            ? NetworkImage(userData!['profileUrl'])
                        as ImageProvider
                            : const AssetImage(
                            'assets/images/default_avatar.png')),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.8),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userData?['name'] ?? 'User',
                  style: GoogleFonts.dmSans(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Member since ${userData?['createdAt']?.substring(0, 4) ?? '2022'}",
                  style: GoogleFonts.dmSans(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    SizedBox(width: 4),
                    Text("4.9 (150+ ratings)",
                        style: TextStyle(
                            color: Colors.black54, fontSize: 14)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Menu Bar (Trips, Payment, Help)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _menuItem(Icons.directions_car, "Trips"),
                  _menuItem(Icons.payment, "Payment"),
                  _menuItem(Icons.help_outline, "Help"),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30)),
                ),
                child: ListView(
                  children: [
                    const SizedBox(height: 25),
                    _settingsTile(Icons.settings, "Account Settings"),
                    _settingsTile(Icons.notifications,
                        "Notification Preferences"),
                    _settingsTile(Icons.lock, "Privacy"),
                    _settingsTile(Icons.description, "Terms of Service"),
                    _settingsTile(Icons.logout, "Log Out",
                        onTap: logout, color: Colors.redAccent),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 30),
        const SizedBox(height: 6),
        Text(title,
            style: GoogleFonts.dmSans(color: Colors.black87, fontSize: 14)),
      ],
    );
  }

  Widget _settingsTile(IconData icon, String title,
      {Color color = Colors.black87, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title:
      Text(title, style: GoogleFonts.dmSans(color: color, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios,
          color: Colors.black26, size: 16),
      onTap: onTap,
    );
  }
}
