import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({super.key});

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController seatsController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController carNameController = TextEditingController();
  final TextEditingController carNumberController = TextEditingController();
  final TextEditingController carColorController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;
  double? currentLat;
  double? currentLng;

  // 🌍 Get Current Location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLat = position.latitude;
      currentLng = position.longitude;
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

  // 🚗 Create Ride
  Future<void> _createRide() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select both date and time."),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');

    final rideData = {
      "driverId": userId,
      "from": fromController.text.trim(),
      "to": toController.text.trim(),
      "date": "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
      "time": "${selectedTime!.hour}:${selectedTime!.minute}",
      "availableSeats": int.parse(seatsController.text.trim()),
      "amount": double.parse(amountController.text.trim()),
      "carDetails": {
        "name": carNameController.text.trim(),
        "number": carNumberController.text.trim(),
        "color": carColorController.text.trim(),
      },
      "location": {
        "type": "Point",
        "coordinates": [currentLng ?? 0.0, currentLat ?? 0.0]
      }
    };

    print("🟡 userId: $userId");
    print("🟡 token: $token");
    print("🟡 rideData: ${jsonEncode(rideData)}");




    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/api/rides"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(rideData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newRide = data['ride'];

        ScaffoldMessenger.of(context).showSnackBar( SnackBar(
          content: Text("Ride Published Successfully!",style: GoogleFonts.dmSans(color: Colors.black),),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
        ));

        // 👇 Pass the new ride back to MyRidesScreen
        Navigator.pop(context, newRide);
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed: ${response.body}"),
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
        elevation: 4,
        backgroundColor: const Color(0xff113F67),
        title: Text("Create Ride",
            style: GoogleFonts.dmSans(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Ride Info
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
                    Text("Ride Details",
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
                                  : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"),
                          label: "Select Date",
                          icon: Icons.calendar_today,
                          validator: (_) =>
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
                                  : selectedTime!.format(context)),
                          label: "Select Time",
                          icon: Icons.access_time,
                          validator: (_) =>
                          selectedTime == null ? "Select time" : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: seatsController,
                      label: "Available Seats",
                      icon: Icons.event_seat,
                      type: TextInputType.number,
                      validator: (v) =>
                      v!.isEmpty ? "Enter seat count" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: amountController,
                      label: "Amount (₹)",
                      icon: Icons.currency_rupee,
                      type: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Enter amount" : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // 🔹 Car Details
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
                    Text("Car Details",
                        style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff113F67))),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: carNameController,
                      label: "Car Name",
                      icon: Icons.directions_car_filled_outlined,
                      validator: (v) => v!.isEmpty ? "Enter car name" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: carNumberController,
                      label: "Car Number",
                      icon: Icons.confirmation_num_outlined,
                      validator: (v) =>
                      v!.isEmpty ? "Enter car number" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: carColorController,
                      label: "Car Color",
                      icon: Icons.color_lens_outlined,
                      validator: (v) =>
                      v!.isEmpty ? "Enter car color" : null,
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
                  onPressed: isLoading ? null : _createRide,
                  label: Text(
                    isLoading ? "Creating..." : "Publish Ride",
                    style: GoogleFonts.dmSans(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
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
