import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart'
    show Geolocator, LocationPermission, Position, LocationAccuracy;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ridematch/utils/images.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final List<String> _bannerImages = [
    Images.banner_new,
    Images.onboard_two,
    Images.onboard_three,
  ];
  int _currentPage = 0;

  List<dynamic> rides = [];
  bool isLoading = true;

  String? userCity;
  String? fullAddress;
  double? userLat;
  double? userLong;
  String? userName;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _getUserLocation();
    fetchUserData();
    fetchRides();
  }

  // 👤 Fetch User Data (Name)
  Future<void> fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://192.168.29.206:5000/api/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['name']; // Change field key if different
        });

        // Optional: Save name locally
        await prefs.setString('userName', userName ?? "");
      } else {
        // fallback to saved name if available
        String? savedName = prefs.getString('userName');
        setState(() {
          userName = savedName ?? "User";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // 🌀 Auto Scroll for Banners
  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      int nextPage = (_currentPage + 1) % _bannerImages.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage = nextPage;
      });
      _startAutoScroll();
    });
  }

  // 📍 Get User Location
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String address =
          "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.postalCode ?? ''}";

      setState(() {
        fullAddress = address;
        userCity = place.locality ?? "Unknown";
        userLat = position.latitude;
        userLong = position.longitude;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('userLat', position.latitude);
      await prefs.setDouble('userLong', position.longitude);
      await prefs.setString('userCity', userCity!);
      await prefs.setString('fullAddress', fullAddress!);
    }
  }

  // 🚗 Fetch Rides
  Future<void> fetchRides() async {
    setState(() {
      isLoading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://192.168.29.206:5000/api/rides'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rides = data['rides'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 🏗️ UI BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: const Color(0xff113F67),
        elevation: 4,
        toolbarHeight: 95,
        shadowColor: Colors.black,
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              userName != null
                  ? "Hey $userName 👋, ready to ride today?"
                  : "Hey there 👋, ready to ride today?",
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              fullAddress ?? "Getting location...",
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
      body: Expanded(
        child: Column(
          children: [

            const SizedBox(height: 16),
            _buildSearchBar(),
            SizedBox(height: 21,),
            SizedBox(
              height: 200,
              width: 400,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _bannerImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildBanner(_bannerImages[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Your Rides',style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: Colors.black,
            ),),
            Divider(height: 1,thickness: 2,endIndent: 30,indent: 30,color: Colors.deepOrangeAccent,),
            SizedBox(height: 5,),
            Flexible(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : rides.isEmpty
                  ? const Center(child: Text("No rides available"))
                  : ListView.builder(
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  return _buildRideCard(ride);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎞️ Banner Widget
  Widget _buildBanner(String imagePath) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }

  // 🚘 Ride Card Widget
  Widget _buildRideCard(dynamic ride) {
    const Color accentColor = Color(0xFF19183B);
    const Color routeLineColor = Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003161), Color(0xFF113F67)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "RIDE FROM:",
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: routeLineColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ride['from'],
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 25,
                    width: 1,
                    margin: const EdgeInsets.only(left: 4),
                    color: routeLineColor,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: routeLineColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ride['to'],
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Price Tag
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Rs: ${ride['amount']}",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: routeLineColor.withOpacity(0.5)),
          const SizedBox(height: 16),

          // Driver Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Driver Details
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        Images.bgwave,
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "vaibhav joshi",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Driver • ${ride['duration']} away",
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Ride Details
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.directions_car, color: Colors.white70, size: 20),
                      SizedBox(width: 4),
                      Icon(Icons.person, color: Colors.orangeAccent, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${ride['seats']} seat available",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${ride['duration']} trip",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 370,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: TextField(
        style: GoogleFonts.dmSans(
          color: const Color(0xff113F67),
          fontWeight: FontWeight.w500,
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Search something...",
          hintStyle: GoogleFonts.dmSans(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Color(0xff113F67)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}


