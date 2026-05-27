import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../pages/home/home_page.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/auth/register_page.dart';
import '../../pages/planner/planner_page.dart';
import '../../pages/performance/performance_page.dart';
import '../../pages/challenges/challenges_page.dart';
import '../../pages/learning_path/learning_path_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/edit_profile/edit_profile_page.dart';
import '../../pages/admin/admin_page.dart';
import '../../pages/not_found/not_found_page.dart';
import '../../widgets/layout/app_navbar.dart';
import '../../widgets/layout/app_footer.dart';
import '../../widgets/common/top_blue_bar.dart';

// Rotas sem navbar/footer (telas cheias)
const _noLayoutRoutes = ['/login', '/cadastro'];

class _RootShell extends StatelessWidget {
  final Widget child;
  final String location;
  const _RootShell({required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    final hide = _noLayoutRoutes.contains(location);
    if (hide) return child;
    return Column(
      children: [
        const TopBlueBar(),
        const AppNavbar(),
        Expanded(child: SingleChildScrollView(child: child)),
        const AppFooter(),
      ],
    );
  }
}

GoRouter buildRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/',
    redirect: (ctx, state) {
      final auth = ctx.read<AuthProvider>();
      if (auth.loading) return null;
      final loc = state.matchedLocation;
      final publicRoutes = ['/', '/login', '/cadastro'];
      if (!auth.isLoggedIn && !publicRoutes.contains(loc)) return '/login';
      if (auth.isLoggedIn && (loc == '/login' || loc == '/cadastro')) {
        return '/planner';
      }
      if (loc == '/admin' && !auth.isAdmin) return '/perfil';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (ctx, state, child) => Scaffold(
          body: _RootShell(
            location: state.matchedLocation,
            child: child,
          ),
        ),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomePage()),
          GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
          GoRoute(path: '/cadastro', builder: (_, __) => const RegisterPage()),
          GoRoute(path: '/planner', builder: (_, __) => const PlannerPage()),
          GoRoute(
              path: '/desempenho',
              builder: (_, __) => const PerformancePage()),
          GoRoute(
              path: '/desafios',
              builder: (_, __) => const ChallengesPage()),
          GoRoute(
              path: '/trilha',
              builder: (_, __) => const LearningPathPage()),
          GoRoute(path: '/perfil', builder: (ctx, __) {
            final auth = ctx.read<AuthProvider>();
            return auth.isAdmin ? const AdminPage() : const ProfilePage();
          }),
          GoRoute(
              path: '/editar-perfil',
              builder: (_, __) => const EditProfilePage()),
          GoRoute(path: '/admin', builder: (_, __) => const AdminPage()),
          GoRoute(path: '/:any', builder: (_, __) => const NotFoundPage()),
        ],
      ),
    ],
  );
}
