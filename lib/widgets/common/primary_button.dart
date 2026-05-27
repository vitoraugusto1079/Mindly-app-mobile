import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

enum ButtonVariant { primary, outline, orange }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle =
        GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 14);

    switch (variant) {
      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.blue,
            side: const BorderSide(color: AppColors.blue, width: 2),
            shape: const StadiumBorder(),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            textStyle: textStyle,
          ),
          child: Text(label),
        );
      case ButtonVariant.orange:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding:
                const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
            textStyle: textStyle,
          ),
          child: Text(label),
        );
      default:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding:
                const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
            textStyle: textStyle,
          ),
          child: Text(label),
        );
    }
  }
}
