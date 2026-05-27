import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 42,
        height: 42,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          color: AppColors.blue,
          backgroundColor: Color(0xFFCFE3F7),
        ),
      ),
    );
  }
}
