import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('404',
                style: GoogleFonts.capriola(
                    fontSize: 80,
                    color: AppColors.blue,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Página não encontrada',
                style: GoogleFonts.capriola(
                    fontSize: 24, color: AppColors.navy)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14)),
              child: const Text('Voltar para o início'),
            ),
          ],
        ),
      ),
    );
  }
}
