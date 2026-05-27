import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final xpInLevel = (user?.xp ?? 0) % 200;
    final xpPercent = (xpInLevel / 200).clamp(0.0, 1.0);

    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(
                width: 6,
                height: 32,
                decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 15),
            Text('Perfil do jogador',
                style: GoogleFonts.capriola(
                    fontSize: 28, color: AppColors.navy)),
          ]),
          const SizedBox(height: 24),

          // Card principal
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08), blurRadius: 12)
              ],
            ),
            child: isMobile(context)
                ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          imageUrl: user?.photo ?? 'https://i.pravatar.cc/100',
                          width: 80, height: 80, fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(user?.name ?? 'Usuário Mindly',
                          style: GoogleFonts.capriola(fontSize: 20, color: AppColors.navy),
                          textAlign: TextAlign.center),
                      Text(user?.bio ?? 'Aluno Mindly',
                          style: const TextStyle(color: AppColors.graySoft),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('🔥 Ofensiva: ${user?.streak ?? 0} dia(s) seguidos!',
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 6),
                      Text('XP Nível ${user?.level ?? 1} — $xpInLevel / 200 xp',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: xpPercent,
                          backgroundColor: const Color(0xFFDDDDDD),
                          color: AppColors.blue, minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => context.go('/editar-perfil'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                            child: const Text('Editar dados'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () async {
                              await auth.logout();
                              if (context.mounted) context.go('/login');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(color: AppColors.danger),
                            ),
                            child: const Text('Sair'),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: user?.photo != null
                            ? CachedNetworkImage(imageUrl: user!.photo!, width: 90, height: 90, fit: BoxFit.cover)
                            : CachedNetworkImage(imageUrl: 'https://i.pravatar.cc/100', width: 90, height: 90, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? 'Usuário Mindly',
                                style: GoogleFonts.capriola(fontSize: 22, color: AppColors.navy)),
                            Text(user?.bio ?? 'Aluno Mindly',
                                style: const TextStyle(color: AppColors.graySoft)),
                            const SizedBox(height: 8),
                            Text('🔥 Ofensiva: ${user?.streak ?? 0} dia(s) seguidos!',
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 6),
                            Text('XP Nível ${user?.level ?? 1} — $xpInLevel / 200 xp',
                                style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: xpPercent,
                                backgroundColor: const Color(0xFFDDDDDD),
                                color: AppColors.blue, minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => context.go('/editar-perfil'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                            child: const Text('Editar dados'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () async {
                              await auth.logout();
                              if (context.mounted) context.go('/login');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(color: AppColors.danger),
                            ),
                            child: const Text('Sair'),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),

          // Cards inferiores
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoCard(
                  title: 'Continue aprendendo',
                  child: Column(
                    children: [
                      _LearningItem(
                          icon:
                              'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                          label: 'Matemática Básica',
                          progress: 0.45),
                      const Divider(),
                      _LearningItem(
                          icon:
                              'https://cdn-icons-png.flaticon.com/512/3135/3135755.png',
                          label: 'Interpretação de texto',
                          progress: 0.7),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _InfoCard(
                  title: 'Conquistas',
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _BadgeItem(icon: Icons.emoji_events, label: 'Conclua 10 desafios'),
                      _BadgeItem(icon: Icons.star, label: 'Mantenha ofensiva'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(title,
              style: GoogleFonts.capriola(
                  fontSize: 16, color: AppColors.navy)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LearningItem extends StatelessWidget {
  final String icon;
  final String label;
  final double progress;
  const _LearningItem(
      {required this.icon,
      required this.label,
      required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CachedNetworkImage(imageUrl: icon, width: 36, height: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFEEEEEE),
                  color: AppColors.blue,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BadgeItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: AppColors.orange),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.graySoft),
            textAlign: TextAlign.center),
      ],
    );
  }
}
