import 'package:flutter/widgets.dart';

const double kMobileBreak = 600;

bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < kMobileBreak;

double hPad(BuildContext context) => isMobile(context) ? 20.0 : 80.0;
