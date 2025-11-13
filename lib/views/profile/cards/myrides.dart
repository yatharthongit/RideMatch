import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ridematch/views/home/Screens/bottomsheets/CreateRide.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  List rides = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMyRides();
  }

  Future<void> _fetchMyRides() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse("http://192.168.29.206:5000/api/rides/user/$userId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => rides = data['rides']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to fetch rides: ${response.body}"),
          backgroundColor: Colors.redAccent,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildRideCard(dynamic ride) {
    return GestureDetector(
      onTap: () => _showRideDetails(ride),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "${ride['from']} → ${ride['to']}",
                    style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff113F67)),
                  ),
                ),
                Text(
                  "₹${ride['amount']}",
                  style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xff0A2A66)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Date & Time
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "${ride['date']}",
                  style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "${ride['time']}",
                  style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Seats and Car Info
            Row(
              children: [
                const Icon(Icons.event_seat, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "${ride['availableSeats']} Seats",
                  style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.directions_car, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "${ride['carDetails']?['name'] ?? 'Car'}",
                  style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Driver Info
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "${ride['driverName'] ?? 'Driver'}",
                  style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  void _showRideDetails(dynamic ride) {
    final car = ride['carDetails'] ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    // Route + Fare
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Color(0xff0C2B4E),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "${ride['from']} → ${ride['to']}",
                                style: GoogleFonts.dmSans(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            Text(
                              "₹${ride['amount']}",
                              style: GoogleFonts.dmSans(
                                  fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date & Time
                    Card(
                      elevation: 1,
                      color: Color(0xffAAC4F5),

                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xff0C2B4E)),
                            const SizedBox(width: 8),
                            Text("${ride['date']}", style: GoogleFonts.dmSans(fontSize: 15, color: Color(0xff0C2B4E))),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, color: Color(0xff0C2B4E)),
                            const SizedBox(width: 8),
                            Text("${ride['time']}", style: GoogleFonts.dmSans(fontSize: 15, color: Color(0xff0C2B4E))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Car Info
                    Card(
                      elevation: 1,
                      color: Color(0xffAAC4F5),

                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow(Icons.directions_car, "Car", "${car['name'] ?? 'Unknown'} (${car['color'] ?? 'N/A'})"),
                            _infoRow(Icons.confirmation_number_outlined, "Car Number", car['number'] ?? 'N/A'),
                            _infoRow(Icons.event_seat, "Seats Available", "${ride['availableSeats']}"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Driver Info
                    Card(
                      color: Color(0xffAAC4F5),

                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Driver Details",
                                style: GoogleFonts.dmSans(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xff113F67))),
                            const SizedBox(height: 12),
                            _infoRow(Icons.person, "Driver", "${ride['driverName'] ?? 'N/A'}"),
                            _infoRow(Icons.phone, "Contact", "${ride['driverContact'] ?? 'N/A'}"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            label: const Text("Close"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff113F67),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff113F67)),
          const SizedBox(width: 10),
          Text("$label: ", style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: Colors.black87)),
          Expanded(child: Text(value, style: GoogleFonts.dmSans(color: Color(0xff000000)))),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xff113F67),
        title: Text("My Rides", style: GoogleFonts.dmSans(color: Colors.white)),
        centerTitle: true,
        elevation: 4,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff113F67),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Ride", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        onPressed: () async {
          final newRide = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateRideScreen()),
          );

          if (newRide != null) {
            setState(() => rides.insert(0, newRide));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Ride Published Successfully!", style: GoogleFonts.dmSans(color: Colors.black)),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMyRides,
        color: const Color(0xff113F67),
        backgroundColor: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : rides.isEmpty
            ? Center(
          child: Text("No rides yet 🚗", style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey[600])),
        )
            : ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: rides.length,
          itemBuilder: (context, index) => _buildRideCard(rides[index]),
        ),
      ),
    );
  }
}
