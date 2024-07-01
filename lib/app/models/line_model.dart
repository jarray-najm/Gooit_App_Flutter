import 'station_model.dart';

class Line {
  int id;
  String lineName;
  int lineNumber;
  double linePrice; // Changed from int to double
  String startTime;
  List<Station> lineStations;

  Line({
    required this.id,
    required this.lineName,
    required this.lineNumber,
    required this.linePrice, // Changed from int to double
    required this.startTime,
    required this.lineStations,
  });

  factory Line.fromJson(Map<String, dynamic> json) {
    var list = json['line_stations_json'] as List;
    List<Station> stationsList = list.map((i) => Station.fromJson(i)).toList();

    return Line(
      id: json['id'] ?? 0, // Provide a default value if null
      lineName: json['line_name'] ?? '',
      lineNumber: json['line_number'] ?? 0, // Provide a default value if null
      linePrice: (json['line_price'] ?? 0).toDouble(), // Ensure it's a double
      startTime: json['start_time'] ?? '',
      lineStations: stationsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'line_name': lineName,
      'line_number': lineNumber,
      'line_price': linePrice, // Changed from int to double
      'start_time': startTime,
      'line_stations_json':
          lineStations.map((station) => station.toJson()).toList(),
    };
  }
}
