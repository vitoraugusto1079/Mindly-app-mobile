import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/rewards_service.dart';
import '../../providers/auth_provider.dart';

class RewardsPanel extends StatefulWidget {
  const RewardsPanel({super.key});

  @override
  State<RewardsPanel> createState() => _RewardsPanelState();
}

class _RewardsPanelState extends State<RewardsPanel> {
  final _service = RewardsService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _service.listItems();
      setState(() => _items = data);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _buy(Map<String, dynamic> item) async {
    final auth = context.read<AuthProvider>();
    final uid = auth.session?.user.id;
    final coins = auth.user?.coins ?? 0;
    final cost = (item['cost'] as num).toInt();

    if (uid == null) return;
    if (coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Moedas insuficientes!')),
      );
      return;
    }
    await _service.buyItem(uid, item['id'].toString(), cost);
    await auth.refreshProfile();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item['name']} desbloqueado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<AuthProvider>().user?.coins ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 6,
                height: 32,
                decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 15),
            Text('Recompensas',
                style: GoogleFonts.capriola(
                    fontSize: 26, color: AppColors.navy)),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('🪙 $coins moedas',
                  style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: _items
                .map((item) => _RewardCard(
                    item: item, onBuy: () => _buy(item)))
                .toList(),
          ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onBuy;
  const _RewardCard({required this.item, required this.onBuy});

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
              color: Colors.black.withValues(alpha: 0.08), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['name'] ?? '',
              style: GoogleFonts.capriola(
                  fontSize: 15, color: AppColors.navy)),
          const SizedBox(height: 6),
          Text(item['description'] ?? '',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.graySoft)),
          const SizedBox(height: 12),
          Text('🪙 ${item['cost']} moedas',
              style: const TextStyle(
                  color: AppColors.orange, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(fontSize: 13)),
            child: const Text('Resgatar'),
          ),
        ],
      ),
    );
  }
}
