import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:ridematch/views/profile/cards/myrides.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateLocationRequestScreen extends StatefulWidget {
  const CreateLocationRequestScreen({super.key});

  @override
  State<CreateLocationRequestScreen> createState() =>
      _CreateLocationRequestScreenState();
}

class _CreateLocationRequestScreenState
    extends State<CreateLocationRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;

  // 🌍 Get current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      fromController.text =
      "Current Location (${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})";
    });
  }

  // 📅 Date Picker
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // 🕒 Time Picker
  Future<void> _selectTime() async {
    final picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => selectedTime = picked);
  }

  // 📤 Submit request
  // 📤 Submit Ride Creation Request
  Future<void> _createRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select both date and time."),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userId = prefs.getString('userId');

      // ✅ Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final rideData = {
        "driverId": userId,
        "from": fromController.text.trim(),
        "to": toController.text.trim(),
        "date":
        "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
        "time": "${selectedTime!.hour}:${selectedTime!.minute}",
        "availableSeats": 3, // You can replace with a user input later
        "amount": 150, // Temporary fixed, can be dynamic later
        "carDetails": {
          "name": "Honda City",
          "number": "MP09AB1234",
          "color": "White",
        },
        "location": {
          "type": "Point",
          "coordinates": [position.longitude, position.latitude],
        },
      };

      final response = await http.post(
        Uri.parse("http://192.168.29.206:5000/api/rides"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(rideData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("✅ Ride created successfully!"),
          backgroundColor: Colors.green,
        ));

        // ⏳ Small delay before navigation
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyRidesScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ Failed to create ride: ${response.body}"),
          backgroundColor: Colors.redAccent,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


  // 🧱 Reusable Input Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? type,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      validator: validator,
      style: GoogleFonts.dmSans(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xff113F67)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      appBar: AppBar(
        shadowColor: Colors.black,
        elevation: 4,
        backgroundColor: const Color(0xff113F67),
        title: Text("Request", style: GoogleFonts.dmSans(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Request Details",
                        style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff113F67))),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: fromController,
                      label: "From (Pickup)",
                      icon: Icons.location_on_outlined,
                      validator: (v) =>
                      v!.isEmpty ? "Enter pickup location" : null,
                      suffix: IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: _getCurrentLocation,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: toController,
                      label: "To (Destination)",
                      icon: Icons.flag_outlined,
                      validator: (v) =>
                      v!.isEmpty ? "Enter destination" : null,
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: TextEditingController(
                            text: selectedDate == null
                                ? ""
                                : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                          ),
                          label: "Select Date",
                          icon: Icons.calendar_today,
                          validator: (v) =>
                          selectedDate == null ? "Select date" : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: _selectTime,
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: TextEditingController(
                            text: selectedTime == null
                                ? ""
                                : selectedTime!.format(context),
                          ),
                          label: "Select Time",
                          icon: Icons.access_time,
                          validator: (v) =>
                          selectedTime == null ? "Select time" : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: noteController,
                      label: "Note / Purpose",
                      icon: Icons.comment_outlined,
                      validator: (v) =>
                      v!.isEmpty ? "Enter short note" : null,
                      type: TextInputType.text,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send_rounded,
                      size: 22, color: Colors.white),
                  onPressed: isLoading ? null : _createRequest,
                  label: Text(
                    isLoading ? "Posting..." : "Post",
                    style: GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff113F67),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
