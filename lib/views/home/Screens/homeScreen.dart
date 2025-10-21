import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' show Geolocator, LocationPermission, Position, LocationAccuracy;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ridematch/utils/images.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // 👈 IMPORT GOOGLE FONTS

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final List<String> _bannerImages = [
    Images.banner_one,
    Images.onboard_two,
    Images.onboard_three,
  ];
  int _currentPage = 0;

  List<dynamic> rides = [];
  bool isLoading = true;

  String? userCity;
  String? fullAddress; // 👈 new variable
  double? userLat;
  double? userLong;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _getUserLocation();
    fetchRides();
  }

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
      _startAutoScroll(); // repeat
    });
  }

  // 📍 Get user location and show on screen
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
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Reverse Geocoding
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


  Future<void> fetchRides() async {
    setState(() {
      isLoading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // JWT token

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: const Color(0xff113F67),
        elevation: 4,
        toolbarHeight: 80,
        // 👈 Applying DM Sans to the AppBar title
        title:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(Images.logowhite,height: 40,),
            Text(
            fullAddress ?? "Getting location...",
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis, // avoid overflow if address is long
            maxLines: 1,
                  ),
          ],
        ),

      shadowColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none,color: Colors.white,),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
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
          Expanded(
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
    );
  }

  // Banner Widget
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

  // Ride Card Widget with DM Sans font

  // NOTE: You must have the 'google_fonts' package imported to use GoogleFonts.
// import 'package:google_fonts/google_fonts.dart';

  Widget _buildRideCard(dynamic ride) {
    // Define Colors from the image:
    const Color primaryColor = Color(0xFF003161); // Dark Blue (for text/icons)
    const Color accentColor = Color(0xFF19183B); // Bright Orange (for price tag)
    const Color routeLineColor = Colors.white; // Teal/Cyan (for route line)
    const Color driverInfoBackground = Color(0xFF00C7B0); // Teal/Cyan section

    // Since the background is a complex gradient/image, we'll use a simple
    // dark blue container to represent the main card background.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // This is a placeholder for the complex background image/gradient
        gradient: const LinearGradient(
          colors: [Color(0xFF003161), Color(0xFF113F67)], // Darker Blue to Teal
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
          // RIDE FROM: Header
          Text(
            "RIDE FROM:",
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 10),

          // Row 1: Route and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route (Dewas to Indore)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dewas (Departure)
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
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
                  // The vertical line connecting them
                  Container(
                    height: 25,
                    width: 1,
                    margin: const EdgeInsets.only(left: 4),
                    color: routeLineColor,
                  ),
                  // Indore (Arrival)
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
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

              // Price Tag (Rs: 7000)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: accentColor, // Orange accent background
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Rs: ${ride['amount']}",
                  style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Custom horizontal divider line
          Divider(height: 1, thickness: 1, color: routeLineColor.withOpacity(0.5)),

          const SizedBox(height: 16),

          // Row 2: Driver Info and Ride Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Driver Info (Left Side)
              Row(
                children: [
                  // Driver Image (Placeholder)
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        Images.bgwave, // Placeholder image asset
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
                        "vaibhav joshi", // Hardcoded name from image
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                      Text(
                        "Driver • ${ride['duration']} away", // Using duration as 'time away'
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),

              // Ride Details (Right Side)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      // Car Icon
                      const Icon(Icons.directions_car, color: Colors.white70, size: 20),
                      const SizedBox(width: 4),
                      // Passenger Icon
                      const Icon(Icons.person, color: Colors.orangeAccent, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${ride['seats']} seat available",
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "${ride['duration']} trip",
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}