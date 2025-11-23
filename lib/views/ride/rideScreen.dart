import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridematch/views/ride_detail/ridedetails.dart';
import 'package:ridematch/services/ride_service.dart';

class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  List<Map<String, dynamic>> rides = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final fetchedRides = await RideService.fetchNearbyRides();

      setState(() {
        rides = fetchedRides;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      print('Error loading rides: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        backgroundColor: const Color(0xff113F67),
        title: Text(
          "Nearby Rides",
          style: GoogleFonts.lato(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRides,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xff113F67),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Failed to load rides",
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadRides,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff113F67),
                        ),
                        child: Text(
                          "Retry",
                          style: GoogleFonts.dmSans(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : rides.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.directions_car_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No rides available",
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Check back later for new rides",
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: rides.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
          final ride = rides[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.08),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(ride["driverImage"]?.toString() ?? "https://i.pravatar.cc/150"),
                        radius: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride["driver"]?.toString() ?? "Unknown",
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff09205f),
                              ),
                            ),
                            RatingBarIndicator(
                              rating: (ride["rating"] ?? 0).toDouble(),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 18,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xffe8f0fe),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "₹${ride["amount"]}",
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ride["from"]?.toString() ?? "",
                          style: GoogleFonts.dmSans(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ride["to"]?.toString() ?? "",
                          style: GoogleFonts.dmSans(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoChip(Icons.calendar_today, ride["date"]?.toString() ?? ""),
                      _infoChip(Icons.access_time, ride["time"]?.toString() ?? ""),
                      _infoChip(Icons.airline_seat_recline_normal,
                          "${ride["seats"]} seats"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xfff5f6ff),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car,
                            color: Color(0xff09205f)),
                        const SizedBox(width: 8),
                        Expanded(
                        child: Text(
                          "${ride["carName"]?.toString() ?? ""} • ${ride["carColor"]?.toString() ?? ""}\n${ride["carNumber"]?.toString() ?? ""}",
                          style: GoogleFonts.dmSans(
                              fontSize: 14, color: Colors.black87),
                        ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content:
                        //     Text("Request sent to ${ride["driver"]} 🚗"),
                        //     backgroundColor: const Color(0xff09205f),
                        //   ),
                        // );

                        Navigator.push(context,MaterialPageRoute(builder: (_){
                          return RideDetailsScreen(rideData:
                           {
                          "pickupLocation": LatLng(28.6139, 77.2090), // Delhi
                          "dropLocation": LatLng(28.7041, 77.1025), // Delhi
                          "pickupLocationName": "Rajiv Chowk, Delhi",
                          "dropLocationName": "Indira Gandhi International Airport, Delhi",
                          "driverName": "Rahul Sharma",
                          "driverImage": "https://i.pravatar.cc/150?img=12",
                          "driverPhone": "7898030562",
                          "chatEnabled": true,
                          "vehicle": "Toyota Innova Crysta - White",
                          "seats": 3,
                          "fare": 450,
                          "distance": "18 km",
                          "timeAway": "5 mins",
                          "date": "13 Nov 2025",
                          "time": "4:30 PM",
                          "paymentMethod": "UPI - Paytm",
                          "rating": 4.9,
                          "notes": "Please call when you reach the gate",
                          "promoCode": "WELCOME50"
                          },

                          );
                        }));
                      },
                      icon: const Icon(Icons.navigation,color: Colors.orangeAccent,),
                      label:  Text("View Details",style: GoogleFonts.dmSans(color: Colors.white) ,),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff113F67),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
                      },
                    ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffeef1ff),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xff09205f)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.dmSans(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
