class Game {
  final String id;
  final String title;
  final String description;
  final String prompt;
  final String? hint;
  final String answer;
  final int reward;
  final String? challengeId;

  const Game({
    required this.id,
    required this.title,
    required this.description,
    required this.prompt,
    this.hint,
    required this.answer,
    required this.reward,
    this.challengeId,
  });

  Game copyWith({String? challengeId}) => Game(
        id: id,
        title: title,
        description: description,
        prompt: prompt,
        hint: hint,
        answer: answer,
        reward: reward,
        challengeId: challengeId ?? this.challengeId,
      );
}
