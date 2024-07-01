// controllers/line_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/line_model.dart';
import '../models/station_model.dart';
import '../models/trip_model.dart';
import '../models/user_model.dart';

class UserController {
  static const String BaseUrl =
      'https://gooit-app-backend.onrender.com/api/v1/users/';
  Future<User> fetchUser(int userId) async {
    try {
      final response = await http.get(Uri.parse('$BaseUrl/$userId'));

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData);
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      // Handle network or decoding errors here
      print('Error fetching user: $e');
      throw Exception('Failed to fetch user');
    }
  }

  Future<void> deleteUserProfile(int userId) async {
    try {
      final response = await http.delete(Uri.parse('$BaseUrl/kill/$userId'));
      print(response.body);
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print(responseData['message']); // Log success message
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to delete profile');
      }
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }

  Future<List<Line>> fetchLines() async {
    try {
      final response = await http.get(Uri.parse("$BaseUrl/lines/all"));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((line) => Line.fromJson(line)).toList();
      } else {
        throw Exception('Failed to load lines');
      }
    } catch (e) {
      throw Exception('Failed to load lines: $e');
    }
  }

  Future<List<Station>> fetchStations() async {
    try {
      final response = await http.get(Uri.parse("$BaseUrl/stations/all"));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((station) => Station.fromJson(station))
            .toList();
      } else {
        throw Exception('Failed to load stations');
      }
    } catch (e) {
      throw Exception('Failed to load stations: $e');
    }
  }

  Future<void> rechargeBalance(int amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('userID');

    if (userID == null) {
      throw Exception('User ID not found');
    }

    final response = await http.post(
      Uri.parse('$BaseUrl/balance/recharge'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userID, 'amount': amount}),
    );

    if (response.statusCode == 200) {
      // Handle successful response
      final data = jsonDecode(response.body);
      print('Balance recharged successfully: ${data['balance']}');
    } else {
      // Handle error response
      throw Exception('Failed to recharge balance: ${response.body}');
    }
  }

  Future<List<dynamic>> getLinesByNumber(int lineNumber) async {
    final url = Uri.parse('$BaseUrl/lines/number?line_number=$lineNumber');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print(response.body);
        return json.decode(response.body) as List<dynamic>;
      } else if (response.statusCode == 404) {
        // print('No lines found with the given number : invalid QrCode');
        return []; // Return an empty list to signify no lines found
      } else {
        print(response.body);
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  Future<String> deductPayment(int userId, double amount) async {
    final url = Uri.parse('$BaseUrl/trips/payment');

    try {
      final response = await http.post(
        url,
        body: json.encode({'user_id': userId, 'amount': amount}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return response.body;
        // Handle success response as needed
      } else {
        return response.body;
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  Future<Trip> addTrips({
    required int userId,
    required String tripName,
    required int tripNumber,
    required double tripPrice,
    required String startTime,
    required List<Map<String, dynamic>> tripStationsJson,
  }) async {
    final Uri uri = Uri.parse('$BaseUrl/addTrips');
    final Map<String, dynamic> requestBody = {
      'user_id': userId,
      'trip_name': tripName,
      'trip_number': tripNumber,
      'trip_price': tripPrice,
      'start_time': startTime,
      'trip_stations_json': tripStationsJson,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return Trip.fromJson(jsonResponse['trip']);
    } else {
      throw Exception('Failed to add trip: ${response.body}');
    }
  }
}
