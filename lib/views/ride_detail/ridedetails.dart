import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RideDetailsScreen extends StatefulWidget {
  const RideDetailsScreen({super.key});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  late GoogleMapController _mapController;

  final ride = {
    'driverName': 'Lom Ninem',
    'rating': 4.9,
    'frequentRider': true,
    'fare': 15,
    'seatsRequested': 1,
    'timeAway': '3 mins',
    'distance': '1.2 miles',
    'driverPhone': '+911234567890',
    'pickupLocation': LatLng(28.6139, 77.2090),
    'dropLocation': LatLng(28.7041, 77.1025),
    'pickupLocationName': 'Connaught Place, Delhi',
    'dropLocationName': 'Lajpat Nagar, Delhi',
  };

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: ride['pickupLocation'] as LatLng,
        infoWindow: const InfoWindow(title: 'Pickup'),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('drop'),
        position: ride['dropLocation'] as LatLng,
        infoWindow: const InfoWindow(title: 'Drop'),
      ),
    );
  }

  void _launchCaller(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot make a call')),
      );
    }
  }

  void _launchChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat feature coming soon!')),
    );
  }

  void _proceedToPayment() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 250,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF113F67), Color(0xFF003161)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Payment Method",
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paid via UPI')),
                  );
                },
                icon:
                const Icon(Icons.account_balance_wallet, color: Colors.white),
                label: const Text("Pay via UPI"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paid via Card')),
                  );
                },
                icon: const Icon(Icons.credit_card, color: Colors.white),
                label: const Text("Pay via Card"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: Center(
            child: Text('Ride Details',
                style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20))),
        backgroundColor: const Color(0xFF113F67),
        shadowColor: Colors.black,
        elevation: 5,
      ),
      body: Column(
        children: [
          // Google Map
          Container(
            height: 220,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: ride['pickupLocation'] as LatLng,
                  zoom: 12,
                ),
                markers: _markers,
                onMapCreated: (controller) => _mapController = controller,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
          ),

          // Ride Info Card
          Container(
            width: double.infinity,
            height: 300,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF113F67),
                  Color(0xFF003161),
                  Color(0xFF001F40)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver Info Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          color: Colors.blueAccent, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride['driverName'] as String,
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "${ride['rating']} • ${ride['frequentRider'] != null ? 'Frequent rider' : 'New rider'}",
                                style: GoogleFonts.dmSans(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.message, color: Colors.white),
                          onPressed: _launchChat,
                        ),
                        IconButton(
                          icon: const Icon(Icons.call, color: Colors.white),
                          onPressed: () =>
                              _launchCaller(ride['driverPhone'] as String),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Pickup -> Drop Route Line
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  height: 80,
                  child: Row(
                    children: [
                      // Vertical line with icons
                      Column(
                        children: [
                          const Icon(Icons.circle,
                              color: Colors.greenAccent, size: 16),
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Colors.white54,
                            ),
                          ),
                          const Icon(Icons.circle,
                              color: Colors.redAccent, size: 16),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Location names
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pickup: ${ride['pickupLocationName']}",
                              style: GoogleFonts.dmSans(
                                  color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Drop: ${ride['dropLocationName']}",
                              style: GoogleFonts.dmSans(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Ride Details Row
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Fare",
                              style: GoogleFonts.dmSans(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text("\$${ride['fare']}",
                              style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Seats",
                              style: GoogleFonts.dmSans(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text("${ride['seatsRequested']}",
                              style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Time Away",
                              style: GoogleFonts.dmSans(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text("${ride['timeAway']}",
                              style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Distance",
                              style: GoogleFonts.dmSans(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text("${ride['distance']}",
                              style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Accept & Payment Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Accept & Pay",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
