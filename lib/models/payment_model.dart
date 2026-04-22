class PaymentModel {
  final String paymentId;
  final DateTime dateFrom;
  final DateTime dateTo;
  final double totalLiters;
  final double pricePerLiter;
  final double totalAmount;
  final DateTime createdAt;

  PaymentModel({
    required this.paymentId,
    required this.dateFrom,
    required this.dateTo,
    required this.totalLiters,
    required this.pricePerLiter,
    required this.totalAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'paymentId': paymentId,
        'dateFrom': dateFrom.toIso8601String(),
        'dateTo': dateTo.toIso8601String(),
        'totalLiters': totalLiters,
        'pricePerLiter': pricePerLiter,
        'totalAmount': totalAmount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PaymentModel.fromMap(Map<String, dynamic> map) => PaymentModel(
        paymentId: map['paymentId'] ?? '',
        dateFrom: DateTime.parse(map['dateFrom']),
        dateTo: DateTime.parse(map['dateTo']),
        totalLiters: (map['totalLiters'] ?? 0).toDouble(),
        pricePerLiter: (map['pricePerLiter'] ?? 0).toDouble(),
        totalAmount: (map['totalAmount'] ?? 0).toDouble(),
        createdAt: DateTime.parse(map['createdAt']),
      );
}