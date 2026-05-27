import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../common/primary_button.dart';

class BannerSection extends StatelessWidget {
  const BannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset(
              'assets/images/banners.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 40,
            bottom: 40,
            child: PrimaryButton(
              label: 'Começar grátis',
              variant: ButtonVariant.orange,
              onPressed: () => context.go('/cadastro'),
            ),
          ),
        ],
      ),
    );
  }
}
