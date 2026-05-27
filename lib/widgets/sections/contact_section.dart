import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/services/contact_service.dart';
import '../../providers/auth_provider.dart';
import '../common/primary_button.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _service = ContactService();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  String _feedback = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_emailCtrl.text.isEmpty || _subjectCtrl.text.isEmpty) return;
    final uid = context.read<AuthProvider>().session?.user.id;
    await _service.sendMessage(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      subject: _subjectCtrl.text,
      message: _msgCtrl.text,
      userId: uid,
    );
    _nameCtrl.clear();
    _emailCtrl.clear();
    _subjectCtrl.clear();
    _msgCtrl.clear();
    setState(() => _feedback = 'Mensagem enviada com sucesso!');
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _feedback = '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9F9),
      padding: EdgeInsets.symmetric(horizontal: hPad(context), vertical: 60),
      child: Column(
        children: [
          Text('Fale Conosco',
              style: GoogleFonts.capriola(
                  fontSize: 32, color: AppColors.navy)),
          const SizedBox(height: 20),
          Text(
            'Tem dúvidas ou sugestões? Estamos aqui para ajudar.',
            style: GoogleFonts.openSans(
                fontSize: 18, color: AppColors.grayText),
          ),
          const SizedBox(height: 40),
          if (isMobile(context))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Informações de contato',
                    style: GoogleFonts.capriola(
                        fontSize: 18, color: AppColors.navy)),
                const SizedBox(height: 15),
                const Text('📧 contato@mindly.com',
                    style: TextStyle(fontSize: 15)),
                const SizedBox(height: 8),
                const Text('📱 (11) 9999-9999',
                    style: TextStyle(fontSize: 15)),
                const SizedBox(height: 8),
                const Text('🕐 Seg-Sex, 9h às 18h',
                    style: TextStyle(fontSize: 15)),
                const SizedBox(height: 28),
                _ContactInput(controller: _nameCtrl, hint: 'Seu nome'),
                _ContactInput(
                    controller: _emailCtrl,
                    hint: 'Seu e-mail',
                    type: TextInputType.emailAddress),
                _ContactInput(
                    controller: _subjectCtrl, hint: 'Assunto'),
                TextField(
                  controller: _msgCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Sua mensagem',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                PrimaryButton(label: 'Enviar mensagem', onPressed: _send),
                if (_feedback.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(_feedback,
                      style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ],
              ],
            )
          else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informações de contato',
                        style: GoogleFonts.capriola(
                            fontSize: 18, color: AppColors.navy)),
                    const SizedBox(height: 15),
                    const Text('📧 contato@mindly.com',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('📱 (11) 9999-9999',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('🕐 Seg-Sex, 9h às 18h',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(width: 50),
              // Formulário
              Expanded(
                child: Column(
                  children: [
                    _ContactInput(controller: _nameCtrl, hint: 'Seu nome'),
                    _ContactInput(
                        controller: _emailCtrl,
                        hint: 'Seu e-mail',
                        type: TextInputType.emailAddress),
                    _ContactInput(
                        controller: _subjectCtrl, hint: 'Assunto'),
                    TextField(
                      controller: _msgCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Sua mensagem',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PrimaryButton(
                          label: 'Enviar mensagem', onPressed: _send),
                    ),
                    if (_feedback.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(_feedback,
                          style: const TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType type;
  const _ContactInput(
      {required this.controller,
      required this.hint,
      this.type = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
