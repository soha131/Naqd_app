class AmountPrediction {
  final double total;

  AmountPrediction({required this.total});

  factory AmountPrediction.fromJson(Map<String, dynamic> json) {
    return AmountPrediction(
      total: json['total']?.toDouble() ?? 0.0,  // Assuming the 'total' is part of the response
    );
  }
}
