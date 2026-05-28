import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';

const _supabaseUrl = 'https://knkfkzskfwsiayzfdvia.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtua2ZrenNrZndzaWF5emZkdmlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3MTc4MDAsImV4cCI6MjA5NTI5MzgwMH0.SJudevWWar41NEs2VW0Z_GDUc8DkqBPCZVgVHw-nBIA';

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
