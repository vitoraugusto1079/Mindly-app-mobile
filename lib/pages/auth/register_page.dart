import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/auth_input.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  String _error = '';
  String _info = '';
  bool _loading = false;

  Future<void> _handleRegister() async {
    setState(() {
      _error = '';
      _info = '';
      _loading = true;
    });
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text;
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      setState(() {
        _error = 'Preencha e-mail e senha.';
        _loading = false;
      });
      return;
    }
    if (senha.length < 6) {
      setState(() {
        _error = 'A senha deve ter pelo menos 6 caracteres.';
        _loading = false;
      });
      return;
    }

    try {
      await context
          .read<AuthProvider>()
          .register(email: email, password: senha, name: name);
      if (mounted) {
        setState(() =>
            _info = 'Conta criada! Verifique seu e-mail para confirmar.');
      }
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
      setState(() => _error = 'Erro ao cadastrar com Google: $e');
    }
  }

  String _traduzErro(String msg) {
    if (msg.contains('already registered') || msg.contains('already been')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (msg.toLowerCase().contains('password')) {
      return 'Senha inválida (mínimo 6 caracteres).';
    }
    return msg;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
              'Crie sua conta\nagora mesmo',
              style: GoogleFonts.capriola(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.loginYellow,
              ),
            ),
            const SizedBox(height: 8),
            const Text('comece a estudar com a gente!',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 24),

            if (_error.isNotEmpty) _Feedback(text: _error, isError: true),
            if (_info.isNotEmpty) _Feedback(text: _info, isError: false),

            const Text('Nome:',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 5),
            AuthInput(
                controller: _nameCtrl,
                placeholder: 'Como devemos te chamar?'),
            const Text('E-mail:',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 5),
            AuthInput(
                controller: _emailCtrl,
                placeholder: 'Digite seu e-mail',
                keyboardType: TextInputType.emailAddress),
            const Text('Senha:',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 5),
            AuthInput(
                controller: _senhaCtrl,
                placeholder: 'Crie uma senha (mín. 6 caracteres)',
                obscure: true),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.loginYellow,
                  foregroundColor: AppColors.loginLeftBg,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _loading ? 'Criando…' : 'Cadastrar',
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
                child: const Text('CADASTRAR COM GOOGLE'),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Text('Já tem conta? ',
                    style: TextStyle(
                        color: AppColors.loginYellow, fontSize: 13)),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text('Entrar',
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
          Text('MINDLY',
              style: GoogleFonts.capriola(
                  fontSize: 40, color: AppColors.loginLeftBg)),
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

class _Feedback extends StatelessWidget {
  final String text;
  final bool isError;
  const _Feedback({required this.text, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.withValues(alpha: 0.18)
            : Colors.green.withValues(alpha: 0.18),
        border: Border.all(
            color: isError ? const Color(0xFFFF8A8A) : const Color(0xFF7DDF7D)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: TextStyle(
              color: isError ? const Color(0xFFFFE0E0) : const Color(0xFFDFFFDF),
              fontSize: 13)),
    );
  }
}
