import 'package:flutter/material.dart';
import '../../widgets/sections/hero_section.dart';
import '../../widgets/sections/tools_section.dart';
import '../../widgets/sections/banner_section.dart';
import '../../widgets/sections/about_section.dart';
import '../../widgets/sections/pricing_section.dart';
import '../../widgets/sections/contact_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        HeroSection(),
        ToolsSection(),
        BannerSection(),
        AboutSection(),
        PricingSection(),
        ContactSection(),
      ],
    );
  }
}
