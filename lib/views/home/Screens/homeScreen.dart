import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ridematch/views/home/Screens/bottomsheets/CreateRequest.dart';
import 'package:ridematch/views/home/Screens/bottomsheets/CreateRide.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  bool isLoading = false;

  List<dynamic> ridePosts = [];
  String? userName;
  String? fullAddress;

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getUserLocation();
    await _loadUserData(); // load from prefs first
    await fetchUserData(); // then fetch from backend
    await fetchRides();
  }

  // 🧭 Get User Location
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      fullAddress =
      "${placemarks.first.locality ?? ''}, ${placemarks.first.administrativeArea ?? ''}";
    });
  }

  // 👤 Load Cached User Data
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('username') ?? "User";
    });
  }

  // 👤 Fetch User Data from Backend
  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return;

    try {
      final res = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final fetchedName = data['user']?['name'] ?? data['name'] ?? "User";

        await prefs.setString('username', fetchedName);

        setState(() {
          userName = fetchedName;
        });
      }
    } catch (e) {
      print("❌ Error fetching user data: $e");
    }
  }

  // 🚗 Fetch Available Rides
  Future<void> fetchRides() async {
    setState(() => isLoading = true);
    try {
      final response =
      await http.get(Uri.parse('http://127.0.0.1:5000/api/rides'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ridePosts = data['rides'];
          _addRideMarkers();
        });
      }
    } catch (e) {
      print("Error fetching rides: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🗺️ Add Ride Pins to Map
  void _addRideMarkers() {
    _markers.clear();
    for (var ride in ridePosts) {
      final marker = Marker(
        markerId: MarkerId(ride['_id']),
        position: LatLng(
          ride['fromLat'] ?? 0.0,
          ride['fromLong'] ?? 0.0,
        ),
        infoWindow: InfoWindow(
          title: "${ride['from']} → ${ride['to']}",
          snippet: "Rs ${ride['amount']}",
          onTap: () => _showRideDetail(ride),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      _markers.add(marker);
    }
    setState(() {});
  }

  // 📍 Ride Detail BottomSheet
  void _showRideDetail(dynamic ride) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${ride['from']} → ${ride['to']}",
                style: GoogleFonts.dmSans(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Driver: ${ride['driverName'] ?? 'N/A'}",
                style: GoogleFonts.dmSans(fontSize: 16)),
            Text("Amount: Rs ${ride['amount']}",
                style: GoogleFonts.dmSans(fontSize: 16)),
            Text("Seats: ${ride['seats']}",
                style: GoogleFonts.dmSans(fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.group_add),
                  label: const Text("Join Ride"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Chat"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.handshake_outlined),
                  label: const Text("Propose"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ⚡ Quick Actions
  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          runSpacing: 16,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Quick Actions",
                style: GoogleFonts.dmSans(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.directions_car, color: Colors.blue),
              title: const Text("Create a Ride"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateRideScreen()),
              ),
            ),
            ListTile(
              leading:
              const Icon(Icons.add_location_alt, color: Colors.green),
              title: const Text("Create a Location Request"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CreateLocationRequestScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people_alt, color: Colors.orange),
              title: const Text("Nearby Matches"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // 🏗️ BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff113F67),
        toolbarHeight: 90,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hey ${userName ?? 'User'} 👋",
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 18),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    fullAddress ?? "Fetching location...",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: Stack(
        children: [
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 14.5,
            ),
            myLocationEnabled: true,
            markers: _markers,
          ),

          // 🔍 Floating Search Bar
          Positioned(
            top: 16,
            left: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fromController,
                      decoration: InputDecoration(
                        hintText: "From...",
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: toController,
                      decoration: InputDecoration(
                        hintText: "To...",
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_alt_outlined,
                        color: Colors.blueAccent),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton.extended(
          onPressed: _showQuickActions,
          backgroundColor: const Color(0xff113F67),
          label: Text(
            "Quick Actions",
            style: GoogleFonts.dmSans(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          elevation: 8,
        ),
      ),
    );
  }
}
