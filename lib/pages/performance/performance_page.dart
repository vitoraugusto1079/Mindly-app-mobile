import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart' show isMobile, kMobileBreak;
import '../../data/models/achievement.dart';
import '../../data/models/subject_progress.dart';
import '../../data/services/progress_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/rewards_panel.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/common/skeleton.dart';

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  final _service = ProgressService();
  List<Achievement> _achievements = [];
  List<SubjectProgress> _subjects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().session?.user.id;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _service.listAchievements(uid),
        _service.listSubjectPerformance(uid),
      ]);
      setState(() {
        _achievements = results[0] as List<Achievement>;
        _subjects = results[1] as List<SubjectProgress>;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CONQUISTAS
          _SectionTitle(label: 'Conquistas'),
          const SizedBox(height: 20),
          _loading
              ? const SkeletonAchievements()
              : Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: _achievements
                      .map((a) => _AchievementCard(achievement: a))
                      .toList(),
                ),

          const SizedBox(height: 40),

          // DESEMPENHO
          _SectionTitle(label: 'Desempenho'),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (_, c) {
            final narrow = c.maxWidth < kMobileBreak;
            final cardDecor = BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12)
              ],
            );
            final chartCard = Container(
              padding: const EdgeInsets.all(24),
              decoration: cardDecor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Distribuição de tempo',
                      style: GoogleFonts.capriola(
                          fontSize: 16, color: AppColors.navy)),
                  const SizedBox(height: 20),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('—',
                        style: TextStyle(
                            color: AppColors.graySoft, fontSize: 24)),
                  ),
                ],
              ),
            );
            final progressCard = Container(
              padding: const EdgeInsets.all(24),
              decoration: cardDecor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progresso por disciplina',
                      style: GoogleFonts.capriola(
                          fontSize: 16, color: AppColors.navy)),
                  const SizedBox(height: 16),
                  if (_loading)
                    const SkeletonSubjects()
                  else if (_subjects.isEmpty)
                    const Text(
                      'Estude e conclua desafios para ver seu progresso aqui.',
                      style: TextStyle(
                          color: AppColors.graySoft, fontSize: 14),
                    )
                  else
                    ..._subjects.map((s) => _ProgressItem(subject: s)),
                ],
              ),
            );
            return narrow
                ? Column(children: [
                    chartCard,
                    const SizedBox(height: 20),
                    progressCard,
                  ])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: chartCard),
                      const SizedBox(width: 20),
                      Expanded(child: progressCard),
                    ],
                  );
          }),

          const SizedBox(height: 40),

          // RECOMPENSAS
          const RewardsPanel(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 6,
            height: 32,
            decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 15),
        Text(label,
            style: GoogleFonts.capriola(
                fontSize: 26, color: AppColors.navy)),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: achievement.unlocked ? Colors.white : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08), blurRadius: 12)
        ],
      ),
      child: achievement.unlocked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.title,
                    style: GoogleFonts.capriola(
                        fontSize: 15, color: AppColors.navy)),
                const SizedBox(height: 8),
                Text(achievement.description,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.graySoft)),
                const SizedBox(height: 8),
                Text('+${achievement.rewardCoins} coins',
                    style: const TextStyle(
                        color: AppColors.orange,
                        fontWeight: FontWeight.bold)),
              ],
            )
          : Column(
              children: [
                const Icon(Icons.lock, size: 36, color: Color(0xFF999999)),
                const SizedBox(height: 8),
                Text('Bloqueado',
                    style: GoogleFonts.capriola(
                        fontSize: 14, color: AppColors.navy)),
                const SizedBox(height: 4),
                Text(achievement.description,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.graySoft),
                    textAlign: TextAlign.center),
              ],
            ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final SubjectProgress subject;
  const _ProgressItem({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject.subject,
                  style: const TextStyle(fontSize: 14)),
              Text('${subject.percentage}%',
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: subject.percentage / 100,
            backgroundColor: const Color(0xFFEEEEEE),
            color: AppColors.blue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
