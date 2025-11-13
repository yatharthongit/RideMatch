import 'package:flutter/material.dart';
import 'package:ridematch/main.dart';
import 'package:ridematch/services/LocationPermission.dart';
import 'package:ridematch/utils/images.dart';
import 'package:ridematch/views/%20auth/Screens/LoginScreen.dart';
import 'package:ridematch/views/dashboard/Screens/Dashboard.dart';
import 'package:ridematch/views/onboarding/onboardScreen.dart';
import 'package:ridematch/views/ride_detail/ridedetails.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  // void initState() {
  //   super.initState();
  //   // Navigate to onboarding after 3 seconds
  //   Timer(Duration(seconds: 3), () {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => OnboardingScreen()),
  //     );
  //   });
  // }

  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isOnboarded = prefs.getBool('isOnboarded');

    // Wait 2 seconds for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (isOnboarded == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Center(
        child: Image.asset(
          Images.logo, // Your asset image
          width: 300,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
