import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
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
import '../../widgets/common/top_blue_bar.dart';

// Rotas sem navbar/bottom nav (telas cheias)
const _noLayoutRoutes = ['/login', '/cadastro'];

// Rotas mapeadas na bottom nav (na ordem dos itens)
const _bottomNavRoutes = [
  '/planner',
  '/desafios',
  '/trilha',
  '/desempenho',
  '/perfil',
];

class _RootShell extends StatelessWidget {
  final Widget child;
  final String location;
  const _RootShell({required this.child, required this.location});

  /// Retorna o índice ativo na bottom nav com base na rota atual.
  int get _navIndex {
    if (location.startsWith('/planner')) return 0;
    if (location.startsWith('/desafios')) return 1;
    if (location.startsWith('/trilha')) return 2;
    if (location.startsWith('/desempenho')) return 3;
    // perfil, editar-perfil, admin → aba Perfil
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final hide = _noLayoutRoutes.contains(location);
    if (hide) return child;

    final mobile = isMobile(context);

    return Column(
      children: [
        const TopBlueBar(),
        const AppNavbar(),
        Expanded(child: SingleChildScrollView(child: child)),
        if (mobile)
          BottomNavigationBar(
            currentIndex: _navIndex,
            onTap: (i) => context.go(_bottomNavRoutes[i]),
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.blue,
            unselectedItemColor: AppColors.graySoft,
            type: BottomNavigationBarType.fixed,
            elevation: 12,
            selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Planner',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_outlined),
                activeIcon: Icon(Icons.emoji_events),
                label: 'Desafios',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: 'Trilha',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Desempenho',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
      ],
    );
  }
}

/// Fade suave de 250ms entre páginas dentro do ShellRoute.
Page<void> _fadePage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurveTween(curve: Curves.easeIn).animate(animation),
        child: child,
      ),
    );

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
          GoRoute(
            path: '/',
            pageBuilder: (_, state) => _fadePage(state, const HomePage()),
          ),
          GoRoute(
            path: '/login',
            pageBuilder: (_, state) => _fadePage(state, const LoginPage()),
          ),
          GoRoute(
            path: '/cadastro',
            pageBuilder: (_, state) => _fadePage(state, const RegisterPage()),
          ),
          GoRoute(
            path: '/planner',
            pageBuilder: (_, state) => _fadePage(state, const PlannerPage()),
          ),
          GoRoute(
            path: '/desempenho',
            pageBuilder: (_, state) =>
                _fadePage(state, const PerformancePage()),
          ),
          GoRoute(
            path: '/desafios',
            pageBuilder: (_, state) =>
                _fadePage(state, const ChallengesPage()),
          ),
          GoRoute(
            path: '/trilha',
            pageBuilder: (_, state) =>
                _fadePage(state, const LearningPathPage()),
          ),
          GoRoute(
            path: '/perfil',
            pageBuilder: (ctx, state) {
              final auth = ctx.read<AuthProvider>();
              return _fadePage(
                state,
                auth.isAdmin ? const AdminPage() : const ProfilePage(),
              );
            },
          ),
          GoRoute(
            path: '/editar-perfil',
            pageBuilder: (_, state) =>
                _fadePage(state, const EditProfilePage()),
          ),
          GoRoute(
            path: '/admin',
            pageBuilder: (_, state) => _fadePage(state, const AdminPage()),
          ),
          GoRoute(
            path: '/:any',
            pageBuilder: (_, state) => _fadePage(state, const NotFoundPage()),
          ),
        ],
      ),
    ],
  );
}
