import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/line_model.dart';
import '../models/station_model.dart';
import '../models/user_model.dart';

class AdminController {
  static const String baseUrl =
      'https://gooit-app-backend.onrender.com/api/v1/admin/';
  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<User> users =
            body.map((dynamic item) => User.fromJson(item)).toList();
        return users;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<List<Station>> getAllStations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stations'));
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<Station> stations =
            body.map((dynamic item) => Station.fromJson(item)).toList();
        return stations;
      } else {
        throw Exception('Failed to load stations');
      }
    } catch (e) {
      throw Exception('Failed to load stations: $e');
    }
  }

  Future<List<Line>> getAllLines() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lines'));
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<Line> lines =
            body.map((dynamic item) => Line.fromJson(item)).toList();
        return lines;
      } else {
        throw Exception('Failed to load lines');
      }
    } catch (e) {
      throw Exception('Failed to load lines: $e');
    }
  }

  Future<void> addStation(Station station) async {
    try {
      print('Adding Station: ${station.toJson()}');
      final response = await http.post(
        Uri.parse('$baseUrl/stations'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(station.toJson()),
      );
      print('Request Body: ${json.encode(station.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode != 201) {
        throw Exception('Failed to add station: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to add station: $e');
    }
  }

  Future<void> editStation(int id, Station station) async {
    try {
      print('Editing Station with ID $id: ${station.toJson()}');
      final response = await http.put(
        Uri.parse('$baseUrl/stations/$id'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(station.toJson()),
      );
      print('Request Body: ${json.encode(station.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to edit station: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to edit station: $e');
    }
  }

  Future<void> deleteStation(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/stations/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete station');
      }
    } catch (e) {
      throw Exception('Failed to delete station: $e');
    }
  }

  Future<void> addLine(Line line) async {
    try {
      // Create JSON payload for lineStations
      List<Map<String, dynamic>> lineStationsJson =
          line.lineStations.map((station) => station.toJson()).toList();

      // Construct the line object to send
      Map<String, dynamic> lineData = {
        'line_name':
            line.lineName, // Ensure field names match server expectations
        'line_price': line.linePrice,
        'line_number': line.lineNumber,
        'start_time': line.startTime,
        'line_stations_json': lineStationsJson,
      };

      // Print line and stations JSON for debugging
      print(jsonEncode(lineData));

      final response = await http.post(
        Uri.parse('$baseUrl/lines'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(lineData),
      );

      print(response.body); // Print full response body for debugging
      print(response.statusCode); // Print status code

      if (response.statusCode == 201) {
        // Optionally handle success response
        print('Line added successfully');
      } else {
        throw Exception('Failed to add line: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to add line: $e');
      throw Exception('Failed to add line: $e');
    }
  }

  Future<void> editLine(int id, Line line) async {
    try {
      List<Map<String, dynamic>> lineStationsJson =
          line.lineStations.map((station) => station.toJson()).toList();
      print(lineStationsJson);
      // Construct the line object to send
      Map<String, dynamic> updatedLineJson = {
        'line_name':
            line.lineName, // Ensure field names match server expectations
        'line_price': line.linePrice,
        'line_number': line.lineNumber,
        'start_time': line.startTime,
        'line_stations_json': lineStationsJson,
      };
      print(updatedLineJson);
      // Perform the HTTP PUT request to update the line
      final response = await http.put(
        Uri.parse('$baseUrl/lines/$id'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedLineJson),
      );
      print(response.body);
      // Check the response status code
      if (response.statusCode != 200) {
        throw Exception('Failed to edit line');
      }
    } catch (e) {
      throw Exception('Failed to edit line: $e');
    }
  }

  Future<void> deleteLine(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/lines/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete line');
      }
    } catch (e) {
      throw Exception('Failed to delete line: $e');
    }
  }

  Future<double> getSumOfPayments() async {
    final url =
        Uri.parse('$baseUrl/sumPayments'); // Replace with your actual endpoint
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return double.parse(jsonData['sumOfAllPay'].toString());
      } else {
        throw Exception('Failed to load sum of payments');
      }
    } catch (e) {
      throw Exception('Failed to load sum of payments: $e');
    }
  }
}
