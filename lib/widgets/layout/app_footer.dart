import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEEEEE),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      margin: const EdgeInsets.only(top: 50),
      child: Wrap(
        spacing: 60,
        runSpacing: 28,
        alignment: WrapAlignment.spaceAround,
        children: [
          _FooterCol(
            title: 'Mindly',
            items: const [
              'Plataforma de estudos',
              'para neurodiversidade',
            ],
          ),
          _FooterCol(
            title: 'Navegação',
            items: const ['Início', 'Planner', 'Desempenho', 'Desafios', 'Trilha'],
          ),
          _FooterCol(
            title: 'Contato',
            items: const ['contato@mindly.com', 'suporte@mindly.com'],
          ),
        ],
      ),
    );
  }
}

class _FooterCol extends StatelessWidget {
  final String title;
  final List<String> items;
  const _FooterCol({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.capriola(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.navy)),
        const SizedBox(height: 8),
        ...items.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(i,
                  style: const TextStyle(
                      color: AppColors.graySoft, fontSize: 13)),
            )),
      ],
    );
  }
}
