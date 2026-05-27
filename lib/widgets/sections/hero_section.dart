import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../common/primary_button.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final pad = hPad(context);

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aprenda do seu jeito,\nno seu ritmo.',
          style: GoogleFonts.capriola(
            fontSize: mobile ? 30 : 44,
            color: AppColors.navy,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'O Mindly é uma plataforma de estudos pensada para mentes neurodiversas. Organize, evolua e se divirta aprendendo.',
          style: GoogleFonts.openSans(
            fontSize: mobile ? 15 : 18,
            color: AppColors.graySoft,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            PrimaryButton(
              label: 'Começar agora',
              onPressed: () => context.go('/cadastro'),
            ),
            PrimaryButton(
              label: 'Saiba mais',
              variant: ButtonVariant.outline,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );

    final imageBlock = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/home.jpg',
        width: mobile ? double.infinity : 460,
        fit: BoxFit.cover,
      ),
    );

    return Container(
      color: AppColors.bg,
      padding: EdgeInsets.fromLTRB(pad, 60, pad, 80),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageBlock,
                const SizedBox(height: 32),
                textBlock,
              ],
            )
          : Row(
              children: [
                Expanded(child: textBlock),
                const SizedBox(width: 40),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: imageBlock,
                  ),
                ),
              ],
            ),
    );
  }
}
