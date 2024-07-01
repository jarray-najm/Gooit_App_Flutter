// payment_model.dart
class Payment {
  final int id;
  final int userId;
  final double amount;
  final DateTime paymentDate;

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.paymentDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentDate: DateTime.parse(json['payment_Date'] ?? ''),
    );
  }
}
