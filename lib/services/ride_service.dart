import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RideService {
  static const String baseUrl = "http://127.0.0.1:5000"; // Backend URL

  /// Fetch nearby rides from the backend
  static Future<List<Map<String, dynamic>>> fetchNearbyRides({
    double latitude = 0.0,
    double longitude = 0.0,
    int radius = 10,
  }) async {
    try {
      // Get token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Please login to view rides');
      }

      final url = Uri.parse(
        '$baseUrl/api/rides/nearby?latitude=$latitude&longitude=$longitude&radius=$radius',
      );

      print('🔵 Fetching rides from: $url');
      print('🔵 Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout - check if backend is running');
        },
      );

      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['rides']);
        } else {
          throw Exception('Failed to fetch rides: ${data['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Server error ${response.statusCode}: ${response.body}');
      }
    } on http.ClientException catch (e) {
      print('🔴 ClientException: $e');
      throw Exception('Network error - check your connection and backend server');
    } catch (e) {
      print('🔴 Error fetching rides: $e');
      rethrow;
    }
  }
}
