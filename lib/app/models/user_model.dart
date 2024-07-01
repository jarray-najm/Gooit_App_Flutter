import 'balance_model.dart';
import 'payment_model.dart';
import 'trip_model.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Trip> trips;
  final List<Payment> payments;
  final Balance? balance;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.trips,
    required this.payments,
    required this.balance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      trips: (json['trips'] as List).map((i) => Trip.fromJson(i)).toList(),
      payments:
          (json['payments'] as List).map((i) => Payment.fromJson(i)).toList(),
      balance:
          json['balance'] != null ? Balance.fromJson(json['balance']) : null,
    );
  }
}
