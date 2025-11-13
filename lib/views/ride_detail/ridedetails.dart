import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RideDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? rideData; // Nullable now
  const RideDetailsScreen({super.key, this.rideData});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  late LatLng pickup;
  late LatLng drop;

  @override
  void initState() {
    super.initState();
    // Provide default coordinates if null
    pickup = widget.rideData?['pickupLocation'] ?? const LatLng(28.6139, 77.2090);
    drop = widget.rideData?['dropLocation'] ?? const LatLng(28.7041, 77.1025);
    _setupMap();
  }

  void _setupMap() {
    _markers.add(Marker(
      markerId: const MarkerId('pickup'),
      position: pickup,
      infoWindow: const InfoWindow(title: 'Pickup Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('drop'),
      position: drop,
      infoWindow: const InfoWindow(title: 'Drop Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: [pickup, drop],
      color: Colors.orangeAccent,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    ));
  }

  void _launchCaller(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
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

  void _acceptRide() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 350,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Confirm Ride Payment",
                  style: GoogleFonts.dmSans(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildPaymentButton(Icons.account_balance_wallet, "Pay via UPI"),
              const SizedBox(height: 12),
              _buildPaymentButton(Icons.credit_card, "Pay via Card"),
              const SizedBox(height: 12),
              _buildPaymentButton(Icons.money, "Pay with Cash"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentButton(IconData icon, String text) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$text successful!')),
        );
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: GoogleFonts.dmSans(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff0C2B4E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.rideData ?? {}; // Use empty map if null

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Ride Details",
            style: GoogleFonts.dmSans(
                color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: pickup, zoom: 12),
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${ride['date'] ?? '—'} • ${ride['time'] ?? '—'}",
                        style: GoogleFonts.dmSans(
                            color: Colors.black54, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(
                              ride['driverImage'] ??
                                  'https://cdn-icons-png.flaticon.com/512/219/219969.png'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride['driverName'] ?? "Unknown",
                                  style: GoogleFonts.dmSans(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18)),
                              const SizedBox(height: 5),
                              Text(ride['vehicle'] ?? "Car Info",
                                  style: GoogleFonts.dmSans(color: Colors.black87)),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 18),
                                  Text(" ${ride['rating'] ?? '—'}",
                                      style: GoogleFonts.dmSans(
                                          color: Colors.black87, fontSize: 14)),
                                  const SizedBox(width: 10),
                                  Text(
                                      "(${ride['timeAway'] ?? '—'} away)",
                                      style: GoogleFonts.dmSans(
                                          color: Colors.black54, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (ride['chatEnabled'] == true)
                          IconButton(
                              icon: const Icon(Icons.message,
                                  color: Colors.black87),
                              onPressed: _launchChat),
                        IconButton(
                            icon: const Icon(Icons.call, color: Colors.black87),
                            onPressed: () =>
                                _launchCaller(ride['driverPhone'])),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _locationRow(Icons.my_location, "Pickup",
                        ride['pickupLocationName'] ?? "—"),
                    const SizedBox(height: 10),
                    _locationRow(Icons.location_on, "Drop",
                        ride['dropLocationName'] ?? "—"),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoTile(Icons.event_seat, "Seats",
                            "${ride['seats'] ?? '—'}"),
                        _infoTile(Icons.currency_rupee, "Fare",
                            "₹${ride['fare'] ?? '—'}"),
                        _infoTile(Icons.social_distance, "Distance",
                            "${ride['distance'] ?? '—'}"),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text("Payment Method",
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(ride['paymentMethod'] ?? "—",
                        style: GoogleFonts.dmSans(fontSize: 14)),
                    const SizedBox(height: 20),
                    if (ride['notes'] != null)
                      Text("Notes: ${ride['notes']}",
                          style: GoogleFonts.dmSans(
                              color: Colors.black54, fontSize: 14)),
                    if (ride['promoCode'] != null)
                      Text("Promo Code: ${ride['promoCode']}",
                          style: GoogleFonts.dmSans(
                              color: Colors.black54, fontSize: 14)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _acceptRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0A2647),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("Accept & Pay",
                          style: GoogleFonts.dmSans(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 20),
        const SizedBox(height: 4),
        Text(title,
            style: GoogleFonts.dmSans(color: Colors.black54, fontSize: 13)),
        Text(value,
            style: GoogleFonts.dmSans(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14))
      ],
    );
  }

  Widget _locationRow(IconData icon, String title, String address) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(address,
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}
