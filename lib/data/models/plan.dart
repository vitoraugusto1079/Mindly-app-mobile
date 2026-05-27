class Plan {
  final String id;
  final String name;
  final String price;
  final String? description;
  final int usersCount;

  const Plan({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.usersCount,
  });

  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      id: map['id'].toString(),
      name: map['name'] as String? ?? '',
      price: map['price'] as String? ?? '',
      description: map['description'] as String?,
      usersCount: (map['users_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'description': description,
      };

  Plan copyWith({String? name, String? price, String? description}) => Plan(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        description: description ?? this.description,
        usersCount: usersCount,
      );
}
