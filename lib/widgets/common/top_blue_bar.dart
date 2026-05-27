import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Barra azul fixa de 8px no topo — equivale ao body::before do global.css
class TopBlueBar extends StatelessWidget {
  const TopBlueBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 8, color: AppColors.blue);
  }
}
