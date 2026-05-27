import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  static const _items = [
    {
      'title': 'Para Neurodiversos',
      'desc':
          'Desenvolvido com foco em TDAH, autismo, dislexia e outras variações cognitivas.',
    },
    {
      'title': 'Aprendizagem Adaptativa',
      'desc':
          'Conteúdo que se adapta ao seu ritmo, estilo e preferências de estudo.',
    },
    {
      'title': 'Gamificação',
      'desc':
          'Conquistas, moedas e desafios que tornam o aprendizado mais envolvente.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9F9),
      padding: EdgeInsets.symmetric(horizontal: hPad(context), vertical: 60),
      child: Column(
        children: [
          Text('Sobre o Mindly',
              style: GoogleFonts.capriola(
                  fontSize: 32, color: AppColors.navy)),
          const SizedBox(height: 20),
          Text(
            'Somos uma plataforma criada para apoiar mentes que funcionam de forma diferente — porque todo mundo merece aprender do seu jeito.',
            style: GoogleFonts.openSans(
                fontSize: 18, color: AppColors.grayText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: _items
                .map((item) => Container(
                      width: 300,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title']!,
                              style: GoogleFonts.capriola(
                                  fontSize: 16, color: AppColors.navy)),
                          const SizedBox(height: 10),
                          Text(item['desc']!,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.grayText)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
