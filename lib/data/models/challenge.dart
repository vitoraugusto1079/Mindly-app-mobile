class Challenge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String status; // 'Ativo' | 'Suspenso'

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
  });

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'].toString(),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      icon: map['icon'] as String? ?? 'star',
      status: map['status'] as String? ?? 'Ativo',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'icon': icon,
        'status': status,
      };
}
