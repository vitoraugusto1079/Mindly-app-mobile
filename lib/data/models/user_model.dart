class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? username;
  final String? photo;
  final String? bio;
  final String? birth;
  final String role;
  final String plan;
  final int coins;
  final int xp;
  final int level;
  final int streak;
  final String? status;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.username,
    this.photo,
    this.bio,
    this.birth,
    this.role = 'user',
    this.plan = 'Grátis',
    this.coins = 0,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.status,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      name: map['name'] as String?,
      username: map['username'] as String?,
      photo: map['photo'] as String?,
      bio: map['bio'] as String?,
      birth: map['birth'] as String?,
      role: map['role'] as String? ?? 'user',
      plan: map['plan'] as String? ?? 'Grátis',
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      status: map['status'] as String?,
    );
  }

  UserModel copyWith({
    String? name,
    String? username,
    String? photo,
    String? bio,
    String? birth,
    String? plan,
    int? coins,
    int? xp,
    int? level,
    int? streak,
    String? status,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      username: username ?? this.username,
      photo: photo ?? this.photo,
      bio: bio ?? this.bio,
      birth: birth ?? this.birth,
      role: role,
      plan: plan ?? this.plan,
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      status: status ?? this.status,
    );
  }
}
