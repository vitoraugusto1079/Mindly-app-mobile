import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../common/primary_button.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

  static const _plans = [
    {
      'name': 'Grátis',
      'price': 'R\$ 0/mês',
      'features': ['Planner básico', 'Trilha de aprendizagem', '3 desafios/mês'],
      'popular': false,
    },
    {
      'name': 'Premium',
      'price': 'R\$ 19,90/mês',
      'features': ['Tudo do Grátis', 'Desempenho avançado', 'Desafios ilimitados', 'Recompensas exclusivas'],
      'popular': true,
    },
    {
      'name': 'Institucional',
      'price': 'R\$ 49,90/mês',
      'features': ['Tudo do Premium', 'Múltiplos usuários', 'Relatórios', 'Suporte prioritário'],
      'popular': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: EdgeInsets.symmetric(horizontal: hPad(context), vertical: 60),
      child: Column(
        children: [
          Text('Planos e Preços',
              style: GoogleFonts.capriola(
                  fontSize: 32, color: AppColors.navy)),
          const SizedBox(height: 20),
          Text(
            'Escolha o plano ideal para o seu jeito de aprender.',
            style: GoogleFonts.openSans(
                fontSize: 18, color: AppColors.grayText),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: _plans
                .map((p) => _PricingCard(plan: p))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  const _PricingCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isPopular = plan['popular'] as bool;
    return Container(
      width: 290,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isPopular
            ? Border.all(color: AppColors.orange, width: 3)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Text(plan['name'] as String,
              style: GoogleFonts.capriola(
                  fontSize: 22, color: AppColors.navy)),
          const SizedBox(height: 10),
          Text(plan['price'] as String,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue)),
          const SizedBox(height: 20),
          ...(plan['features'] as List<String>).map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                const Icon(Icons.check, size: 16, color: AppColors.green),
                const SizedBox(width: 8),
                Text(f, style: const TextStyle(fontSize: 14)),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Assinar',
            variant:
                isPopular ? ButtonVariant.orange : ButtonVariant.primary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
