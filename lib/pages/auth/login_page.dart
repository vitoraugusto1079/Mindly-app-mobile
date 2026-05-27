import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/auth_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  String _error = '';
  bool _loading = false;

  Future<void> _handleLogin() async {
    setState(() {
      _error = '';
      _loading = true;
    });
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text;

    if (email.isEmpty || senha.isEmpty) {
      setState(() {
        _error = 'Preencha todos os campos.';
        _loading = false;
      });
      return;
    }

    try {
      await context.read<AuthProvider>().login(email: email, password: senha);
      if (mounted) context.go('/planner');
    } catch (e) {
      setState(() => _error = _traduzErro(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogle() async {
    setState(() => _error = '');
    try {
      await context.read<AuthProvider>().loginWithGoogle();
    } catch (e) {
      setState(() => _error = 'Erro ao logar com Google: $e');
    }
  }

  String _traduzErro(String msg) {
    if (msg.contains('Invalid login')) return 'E-mail ou senha incorretos.';
    if (msg.contains('Email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    return msg;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Widget _buildForm() {
    return Container(
      color: AppColors.loginLeftBg,
      padding: const EdgeInsets.all(40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Já estuda com\na gente?',
              style: GoogleFonts.capriola(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.loginYellow,
              ),
            ),
            const SizedBox(height: 8),
            const Text('faça seu login e boa aula!',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 24),

            if (_error.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.18),
                  border: Border.all(color: const Color(0xFFFF8A8A)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_error,
                    style: const TextStyle(
                        color: Color(0xFFFFE0E0), fontSize: 13)),
              ),

            const Text('E-mail:',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 5),
            AuthInput(
                controller: _emailCtrl,
                placeholder: 'Digite seu e-mail',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 4),
            const Text('Senha:',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 5),
            AuthInput(
                controller: _senhaCtrl,
                placeholder: 'Digite sua senha',
                obscure: true),
            const SizedBox(height: 8),
            const Text('esqueci minha senha',
                style: TextStyle(
                    color: AppColors.loginYellow, fontSize: 12)),
            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.loginYellow,
                  foregroundColor: AppColors.loginLeftBg,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _loading ? 'Entrando…' : 'Entrar',
                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _handleGoogle,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('LOGAR COM GOOGLE'),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Text('Ainda não é cadastrado? ',
                    style: TextStyle(
                        color: AppColors.loginYellow, fontSize: 13)),
                GestureDetector(
                  onTap: () => context.go('/cadastro'),
                  child: const Text('Criar conta',
                      style: TextStyle(
                          color: AppColors.loginYellow,
                          fontSize: 13,
                          decoration: TextDecoration.underline)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Container(
      color: AppColors.loginRightBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'MINDLY',
            style: GoogleFonts.capriola(
              fontSize: 40,
              color: AppColors.loginLeftBg,
            ),
          ),
          const SizedBox(height: 20),
          Image.asset('assets/images/lapismindly.png', width: 250),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    if (mobile) {
      return SizedBox.expand(child: _buildForm());
    }
    return SizedBox.expand(
      child: Row(
        children: [
          Expanded(child: _buildForm()),
          Expanded(child: _buildBranding()),
        ],
      ),
    );
  }
}
