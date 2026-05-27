import 'challenge.dart';

class UserChallenge {
  final String id;
  final String userId;
  final String challengeId;
  final int progress; // 0–100
  final Challenge? challenge;

  const UserChallenge({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.progress,
    this.challenge,
  });

  factory UserChallenge.fromMap(Map<String, dynamic> map) {
    return UserChallenge(
      id: map['id'].toString(),
      userId: map['user_id'] as String,
      challengeId: map['challenge_id'].toString(),
      progress: (map['progress'] as num?)?.toInt() ?? 0,
      challenge: map['challenge'] != null
          ? Challenge.fromMap(map['challenge'] as Map<String, dynamic>)
          : null,
    );
  }
}
