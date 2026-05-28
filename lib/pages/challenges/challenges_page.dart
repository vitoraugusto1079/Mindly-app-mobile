import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/content.dart';
import '../../data/models/user_challenge.dart';
import '../../data/models/game.dart';
import '../../data/services/challenges_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/skeleton.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final _service = ChallengesService();
  List<UserChallenge> _progressMap = [];
  bool _loading = true;

  Game? _activeGame;
  final _answerCtrl = TextEditingController();
  String _message = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  String? get _userId =>
      context.read<AuthProvider>().session?.user.id;

  Future<void> _load() async {
    final uid = _userId;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final active = await _service.listActive();
      await Future.wait(
          active.map((c) => _service.ensureProgress(uid, c.id)));
      final prog = await _service.listUserProgress(uid);
      setState(() => _progressMap = prog);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkAnswer() async {
    if (_activeGame == null) return;
    final correct = _answerCtrl.text.trim().toLowerCase() ==
        _activeGame!.answer.toLowerCase();

    if (correct) {
      setState(() => _message = '✅ Acertou!!');
      final uid = _userId;
      if (_activeGame!.challengeId != null && uid != null) {
        await _service.addProgress(
            uid, _activeGame!.challengeId!, _activeGame!.reward);
        await _load();
        await context.read<AuthProvider>().refreshProfile();
      }
    } else {
      setState(() => _message = '❌ Errou! Tente novamente.');
    }

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _message = '');
    _answerCtrl.clear();
  }

  List<UserChallenge> get _ongoing =>
      _progressMap.where((p) => p.progress < 100).toList();
  List<UserChallenge> get _completed =>
      _progressMap.where((p) => p.progress >= 100).toList();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: AppColors.bg,
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.track_changes,
                      size: 36, color: AppColors.navy),
                  const SizedBox(width: 10),
                  Text('Trilha de Aprendizagem',
                      style: GoogleFonts.capriola(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy)),
                ],
              ),
              const SizedBox(height: 40),

              // Desafios em andamento
              _ChallengesSection(
                title: 'Desafios em andamento',
                child: _loading
                    ? const SkeletonChallenges()
                    : _ongoing.isEmpty
                        ? const Text(
                            'Nenhum desafio em andamento. Bom trabalho! 🎉',
                            style: TextStyle(color: AppColors.graySoft))
                        : Column(
                            children: _ongoing
                                .map((p) => _ChallengeCard(
                                      userChallenge: p,
                                      isCompleted: false,
                                      onContinue: () => setState(() =>
                                          _activeGame = games[1].copyWith(
                                              challengeId: p.challengeId)),
                                    ))
                                .toList(),
                          ),
              ),
              const SizedBox(height: 40),

              // Desafios concluídos
              _ChallengesSection(
                title: 'Desafios concluídos',
                child: _completed.isEmpty
                    ? const Text(
                        'Você ainda não concluiu desafios. Vá em frente!',
                        style: TextStyle(color: AppColors.graySoft))
                    : Column(
                        children: _completed
                            .map((p) => _ChallengeCard(
                                userChallenge: p, isCompleted: true))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 40),

              // Jogos
              _ChallengesSection(
                title: 'Jogos',
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: games
                      .map((g) => _GameCard(
                          game: g,
                          onFocus: () =>
                              setState(() => _activeGame = g)))
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        // Modal do jogo
        if (_activeGame != null)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            alignment: Alignment.center,
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_activeGame!.title,
                          style: GoogleFonts.capriola(
                              fontSize: 20, color: AppColors.navy)),
                      GestureDetector(
                        onTap: () => setState(() {
                          _activeGame = null;
                          _message = '';
                          _answerCtrl.clear();
                        }),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_activeGame!.prompt,
                      style: const TextStyle(fontSize: 16)),
                  if (_activeGame!.hint != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_activeGame!.hint!,
                          style: const TextStyle(
                              color: AppColors.blue, fontSize: 14)),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _answerCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Sua resposta',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _checkAnswer(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checkAnswer,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue),
                      child: const Text('Enviar'),
                    ),
                  ),
                  if (_message.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_message,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ChallengesSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChallengesSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
              width: 4,
              height: 20,
              color: AppColors.orange,
              margin: const EdgeInsets.only(right: 10)),
          Text(title,
              style: GoogleFonts.capriola(
                  fontSize: 20, color: AppColors.navy)),
        ]),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final UserChallenge userChallenge;
  final bool isCompleted;
  final VoidCallback? onContinue;
  const _ChallengeCard(
      {required this.userChallenge,
      required this.isCompleted,
      this.onContinue});

  @override
  Widget build(BuildContext context) {
    final ch = userChallenge.challenge;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.star, size: 32, color: AppColors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ch?.title ?? '',
                    style: GoogleFonts.capriola(
                        fontSize: 15, color: AppColors.navy)),
                Text(ch?.description ?? '',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.graySoft)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted ? 'Concluído' : 'Em Andamento',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? AppColors.green : AppColors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  value: userChallenge.progress / 100,
                  backgroundColor: const Color(0xFFEEEEEE),
                  color: isCompleted ? AppColors.green : AppColors.blue,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text('${userChallenge.progress}%',
                  style: const TextStyle(fontSize: 12)),
              if (!isCompleted && onContinue != null) ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: const Text('Continuar'),
                ),
              ] else if (isCompleted) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: const Text('Refazer'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onFocus;
  const _GameCard({required this.game, required this.onFocus});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(game.title,
              style: GoogleFonts.capriola(
                  fontSize: 16, color: AppColors.navy)),
          const SizedBox(height: 8),
          Text(game.description,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.graySoft)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onFocus,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: const StadiumBorder()),
            child: const Text('Focar'),
          ),
        ],
      ),
    );
  }
}
