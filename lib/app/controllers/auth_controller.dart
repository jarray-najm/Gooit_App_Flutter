import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/auth_model.dart';

class AuthController {
  final String baseUrl = 'https://gooit-app-backend.onrender.com/api/v1/auth';

  Future<int> signup(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      // Successfully signed up
      return response.statusCode;
    } else {
      // Handle errors
      print(
          'Failed to sign up. Error ${response.statusCode}: ${response.body}');
      return response.statusCode; // Return the status code in case of failure
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print('Response body: $body'); // Print the entire response body

      final userModel = AuthModel.fromJson(body);

      return {
        'message': 'Login successful!',
        'userData': {
          'user': {
            'id': userModel.id,
            'username': userModel.username,
            'email': userModel.email,
            'role': userModel.role,
          }
        }
      };
    } else {
      print('Failed to login: ${response.body}');
      throw Exception('Failed to login UserModel');
    }
  }
}
