class Balance {
  final int id;
  final int userId;
  final double balanceAmount;
  final DateTime rechargeDate;

  Balance({
    required this.id,
    required this.userId,
    required this.balanceAmount,
    required this.rechargeDate,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      balanceAmount: json['balanceAmount']?.toDouble() ?? 0.0,
      rechargeDate: json['recharge_Date'] != null
          ? DateTime.parse(json['recharge_Date'])
          : DateTime.now(),
    );
  }
}
