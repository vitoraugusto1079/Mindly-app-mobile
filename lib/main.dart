import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';

// Substitua pelos valores do seu projeto Supabase (.env.example)
const _supabaseUrl = 'YOUR_SUPABASE_URL';
const _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MindlyApp(),
    ),
  );
}

// Remove a barra de scroll azul padrão do Flutter Web
class _NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}

class MindlyApp extends StatefulWidget {
  const MindlyApp({super.key});

  @override
  State<MindlyApp> createState() => _MindlyAppState();
}

class _MindlyAppState extends State<MindlyApp> {
  late final _router = buildRouter(context);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mindly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: _router,
      scrollBehavior: _NoThumbScrollBehavior().copyWith(scrollbars: false),
    );
  }
}
