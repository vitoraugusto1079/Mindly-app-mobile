import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';

class TopBlueBar extends StatelessWidget {
  const TopBlueBar({super.key});

  String _saudacao() {
    final h = DateTime.now().hour;
    if (h < 12) return '☀️ Bom dia';
    if (h < 18) return '🌤️ Boa tarde';
    return '🌙 Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final mobile = isMobile(context);

    // Não logado → linha decorativa original
    if (!auth.isLoggedIn) {
      return Container(height: 8, color: AppColors.blue);
    }

    final nome = auth.user?.name?.split(' ').first ?? 'você';
    final streak = auth.user?.streak ?? 0;
    final level = auth.user?.level ?? 1;

    return Container(
      height: 44,
      color: AppColors.navy,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 80),
      child: Row(
        mainAxisAlignment: mobile
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          // Saudação
          Text(
            '${_saudacao()}, $nome!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Stats (apenas desktop)
          if (!mobile)
            Row(
              children: [
                _Chip(label: '🔥 $streak ${streak == 1 ? 'dia' : 'dias'}'),
                const SizedBox(width: 16),
                _Chip(label: '⭐ Nível $level'),
              ],
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
