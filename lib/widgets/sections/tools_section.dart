import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../common/primary_button.dart';

class ToolsSection extends StatelessWidget {
  const ToolsSection({super.key});

  static const _tools = [
    {
      'icon': 'assets/images/iconeplanner.png',
      'title': 'Planner Inteligente',
      'desc':
          'Organize seus estudos com um calendário visual e blocos de tempo personalizáveis.',
      'route': '/planner',
    },
    {
      'icon': 'assets/images/iconegrafico.png',
      'title': 'Desempenho',
      'desc':
          'Acompanhe seu progresso, conquistas e evolução ao longo do tempo.',
      'route': '/desempenho',
    },
    {
      'icon': 'assets/images/iconetrofeu.png',
      'title': 'Desafios',
      'desc':
          'Participe de desafios gamificados e ganhe recompensas enquanto aprende.',
      'route': '/desafios',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final pad = hPad(context);
    return Container(
      color: AppColors.bg,
      padding: EdgeInsets.fromLTRB(pad, 40, pad, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 6,
                height: 32,
                decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 15),
            Text('Nossas Ferramentas',
                style: GoogleFonts.capriola(
                    fontSize: 28, color: AppColors.navy)),
          ]),
          const SizedBox(height: 40),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            children: _tools.map((t) => _ToolCard(tool: t)).toList(),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final Map<String, String> tool;
  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Image.asset(tool['icon']!, width: 42, height: 42),
            const SizedBox(width: 12),
            Text(tool['title']!,
                style: GoogleFonts.capriola(
                    fontSize: 16, color: AppColors.navy)),
          ]),
          const SizedBox(height: 16),
          Text(tool['desc']!,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.graySoft,
                  height: 1.6)),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Acessar',
            onPressed: () => context.go(tool['route']!),
          ),
        ],
      ),
    );
  }
}
