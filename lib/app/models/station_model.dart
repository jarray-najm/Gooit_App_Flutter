class Station {
  int? id; // Make id nullable
  String nameStation;
  String codeStation;
  String addresseStation;

  Station({
    this.id,
    required this.nameStation,
    required this.codeStation,
    required this.addresseStation,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as int?, // Assign nullable int
      nameStation: json['nameStation'] ?? '',
      codeStation: json['codeStation'] ?? '',
      addresseStation: json['addresseStation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameStation': nameStation,
      'codeStation': codeStation,
      'addresseStation': addresseStation,
    };
  }
}
