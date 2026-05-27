class Achievement {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;
  final bool unlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.unlocked,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'].toString(),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      rewardCoins: (map['reward_coins'] as num?)?.toInt() ?? 0,
      unlocked: map['unlocked'] as bool? ?? false,
    );
  }
}
