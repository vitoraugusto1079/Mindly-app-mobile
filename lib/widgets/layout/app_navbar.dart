import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';

class AppNavbar extends StatefulWidget {
  const AppNavbar({super.key});

  @override
  State<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends State<AppNavbar> {
  OverlayEntry? _entry;
  final _avatarKey = GlobalKey();

  void _showDropdown(AuthProvider auth) {
    _dismissDropdown();
    final box =
        _avatarKey.currentContext!.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final screenW = MediaQuery.of(context).size.width;
    final rightEdge = screenW - offset.dx - box.size.width;

    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // tap-outside dismisses
          GestureDetector(
            onTap: _dismissDropdown,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
          Positioned(
            top: offset.dy + box.size.height + 8,
            right: rightEdge,
            child: _Dropdown(
              userName: auth.user?.name ?? auth.user?.email ?? '',
              onProfile: () {
                _dismissDropdown();
                context.go('/perfil');
              },
              onEdit: () {
                _dismissDropdown();
                context.go('/editar-perfil');
              },
              onLogout: () async {
                _dismissDropdown();
                await auth.logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  void _dismissDropdown() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _dismissDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final location = GoRouterState.of(context).matchedLocation;

    final mobile = isMobile(context);
    final hPadding = mobile ? 16.0 : 80.0;

    Widget userArea = user != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!mobile)
                const Icon(Icons.card_giftcard,
                    size: 20, color: AppColors.navy),
              if (!mobile) const SizedBox(width: 18),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  key: _avatarKey,
                  onTap: () => _showDropdown(auth),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: user.photo != null
                        ? CachedNetworkImage(
                            imageUrl: user.photo!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            color: AppColors.blue,
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 24),
                          ),
                  ),
                ),
              ),
            ],
          )
        : ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            child: Text('Entrar',
                style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
          );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 14),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.go('/'),
              child: Image.asset('assets/images/mindly-logo.png', height: 44),
            ),
          ),
          const Spacer(),
          if (!mobile) ...[
            _NavItem(label: 'Início', path: '/', current: location),
            _NavItem(label: 'Planner', path: '/planner', current: location),
            _NavItem(label: 'Desempenho', path: '/desempenho', current: location),
            _NavItem(label: 'Desafios', path: '/desafios', current: location),
            _NavItem(label: 'Trilha', path: '/trilha', current: location),
            if (user?.role == 'admin')
              _NavItem(
                  label: 'Painel Admin',
                  path: '/admin',
                  current: location,
                  adminStyle: true),
            const SizedBox(width: 30),
          ],
          userArea,
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String path;
  final String current;
  final bool adminStyle;
  const _NavItem(
      {required this.label,
      required this.path,
      required this.current,
      this.adminStyle = false});

  bool get _isActive => current == path;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(path),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.only(bottom: 5),
          decoration: _isActive
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.orange, width: 3),
                  ),
                )
              : null,
          child: Text(
            label,
            style: GoogleFonts.capriola(
              fontSize: 14,
              color: adminStyle
                  ? const Color(0xFFFFCC00)
                  : _isActive
                      ? AppColors.orange
                      : AppColors.navy,
              fontWeight: _isActive || adminStyle
                  ? FontWeight.w600
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String userName;
  final VoidCallback onProfile;
  final VoidCallback onEdit;
  final VoidCallback onLogout;
  const _Dropdown(
      {required this.userName,
      required this.onProfile,
      required this.onEdit,
      required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3B75),
                    fontSize: 14)),
            const SizedBox(height: 10),
            _DropdownBtn(label: 'Perfil', onTap: onProfile),
            _DropdownBtn(label: 'Editar perfil', onTap: onEdit),
            _DropdownBtn(
                label: 'Sair', onTap: onLogout, color: AppColors.danger),
          ],
        ),
      ),
    );
  }
}

class _DropdownBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _DropdownBtn(
      {required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Text(label,
              style: TextStyle(color: color ?? AppColors.navy, fontSize: 14)),
        ),
      ),
    );
  }
}
