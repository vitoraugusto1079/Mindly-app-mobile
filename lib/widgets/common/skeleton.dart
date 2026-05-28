import 'package:flutter/material.dart';

/// Caixa animada (pulse entre dois cinzas) — bloco base de todos os skeletons.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _color = ColorTween(
      begin: const Color(0xFFE0E0E0),
      end: const Color(0xFFF5F5F5),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _color.value,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Layouts de skeleton para cada seção do app
// ─────────────────────────────────────────────────────────────────────────────

/// 4 cards de conquista (página Desempenho).
class SkeletonAchievements extends StatelessWidget {
  const SkeletonAchievements({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: List.generate(4, (_) => const _AchievementSkeleton()),
    );
  }
}

class _AchievementSkeleton extends StatelessWidget {
  const _AchievementSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), blurRadius: 10),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 120, height: 16),
          SizedBox(height: 10),
          SkeletonBox(width: 160, height: 12),
          SizedBox(height: 6),
          SkeletonBox(width: 100, height: 12),
          SizedBox(height: 10),
          SkeletonBox(width: 80, height: 14),
        ],
      ),
    );
  }
}

/// 3 itens de progresso por disciplina (página Desempenho).
class SkeletonSubjects extends StatelessWidget {
  const SkeletonSubjects({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => const _SubjectSkeleton()),
    );
  }
}

class _SubjectSkeleton extends StatelessWidget {
  const _SubjectSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 120, height: 14),
              SkeletonBox(width: 36, height: 14),
            ],
          ),
          SizedBox(height: 8),
          SkeletonBox(height: 8, radius: 4),
        ],
      ),
    );
  }
}

/// 3 cards de desafio (página Desafios).
class SkeletonChallenges extends StatelessWidget {
  const SkeletonChallenges({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => const _ChallengeSkeleton()),
    );
  }
}

class _ChallengeSkeleton extends StatelessWidget {
  const _ChallengeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 32, height: 32, radius: 16),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 15),
                SizedBox(height: 8),
                SkeletonBox(width: 200, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            children: [
              SkeletonBox(width: 90, height: 24, radius: 20),
              SizedBox(height: 8),
              SkeletonBox(width: 120, height: 8, radius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// 3 itens de horário (página Planner).
class SkeletonSchedule extends StatelessWidget {
  const SkeletonSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => const _ScheduleSkeleton()),
    );
  }
}

class _ScheduleSkeleton extends StatelessWidget {
  const _ScheduleSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
        ],
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 60, height: 40, radius: 8),
          SizedBox(width: 16),
          Expanded(child: SkeletonBox(height: 40, radius: 8)),
        ],
      ),
    );
  }
}

/// Painel genérico de loading (página Admin).
class SkeletonAdminPanel extends StatelessWidget {
  const SkeletonAdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(width: 200, height: 28),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(
            4,
            (_) => const SkeletonBox(width: 160, height: 80, radius: 14),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: const [
            Expanded(child: SkeletonBox(height: 220, radius: 16)),
            SizedBox(width: 16),
            Expanded(child: SkeletonBox(height: 220, radius: 16)),
          ],
        ),
      ],
    );
  }
}
