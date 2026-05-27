class Revenue {
  final String id;
  final String month;
  final double amount;

  const Revenue({
    required this.id,
    required this.month,
    required this.amount,
  });

  factory Revenue.fromMap(Map<String, dynamic> map) {
    return Revenue(
      id: map['id'].toString(),
      month: map['month'] as String? ?? '',
      amount: double.tryParse(map['amount'].toString()) ?? 0,
    );
  }
}
