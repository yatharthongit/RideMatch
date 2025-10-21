import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ridematch/views/%20auth/Screens/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart'; // 👈 For animation (add in pubspec.yaml)

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLoading = false;

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable location services.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Location permission permanently denied.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('userLat', position.latitude);
      await prefs.setDouble('userLng', position.longitude);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff003161), Color(0xff00509E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🌍 Animated location pin
                  // Lottie.asset(
                  //   'assets/images/location.png', // 👈 add your Lottie file
                  //   height: 200,
                  //   repeat: true,
                  // ),
                  const SizedBox(height: 20),

                  Text(
                    "Enable Your Location",
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    "Allow access to your location so we can show nearby rides and drivers.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 40),

                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton.icon(
                    onPressed: _requestLocationPermission,
                    icon: const Icon(Icons.my_location_rounded,
                        color: Colors.white),
                    label: Text(
                      "Turn On Location",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white,
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                            color: Colors.white70, width: 1),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  TextButton.icon(
                    onPressed: _requestLocationPermission,
                    icon: const Icon(Icons.pin_drop_outlined,
                        color: Colors.white70),
                    label: Text(
                      "Select Location Manually",
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
