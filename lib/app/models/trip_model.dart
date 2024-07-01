// trip_model.dart
import 'station_model.dart';

class Trip {
  final int id;
  final int userId;
  final String tripName;
  final int tripNumber;
  final double tripPrice;
  final String startTime;
  final DateTime dateTime;
  final List<Station> tripStations;

  Trip({
    required this.id,
    required this.userId,
    required this.tripName,
    required this.tripNumber,
    required this.tripPrice,
    required this.startTime,
    required this.dateTime,
    required this.tripStations,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      tripName: json['trip_name'] ?? '',
      tripNumber: json['trip_number'] ?? 0,
      tripPrice: (json['trip_price'] ?? 0).toDouble(),
      startTime: json['start_time'] ?? '',
      dateTime: DateTime.parse(json['Date_time'] ?? ''),
      tripStations: (json['trip_stations_json'] as List? ?? [])
          .map((i) => Station.fromJson(i))
          .toList(),
    );
  }
}
