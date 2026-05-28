import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _photoCtrl;
  late TextEditingController _bioCtrl;
  DateTime? _birthDate;
  bool _saving = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _photoCtrl = TextEditingController(text: user?.photo ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
    // Carrega a data salva no perfil (formato yyyy-MM-dd)
    if (user?.birth != null && user!.birth!.isNotEmpty) {
      try {
        _birthDate = DateTime.parse(user.birth!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _photoCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      helpText: 'Data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _handleSave() async {
    setState(() {
      _error = '';
      _saving = true;
    });
    try {
      await context.read<AuthProvider>().updateProfile({
        'name': _nameCtrl.text,
        'username': _usernameCtrl.text,
        'photo': _photoCtrl.text.isNotEmpty ? _photoCtrl.text : null,
        'bio': _bioCtrl.text,
        'birth': _birthDate != null
            ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
            : null,
      });
      if (mounted) context.go('/perfil');
    } catch (e) {
      setState(() => _error = 'Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final photoUrl = _photoCtrl.text.isNotEmpty
        ? _photoCtrl.text
        : 'https://i.pravatar.cc/100';

    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 6,
                height: 32,
                decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 15),
            Text('Editar perfil',
                style: GoogleFonts.capriola(
                    fontSize: 28, color: AppColors.navy)),
          ]),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08), blurRadius: 12)
              ],
            ),
            child: isMobile(context)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                  imageUrl: photoUrl, width: 80, height: 80, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _photoCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'URL da imagem', border: OutlineInputBorder()),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(_error,
                              style: const TextStyle(color: AppColors.danger, fontSize: 14)),
                        ),
                      _Field(label: 'Nome', controller: _nameCtrl),
                      _Field(label: 'Username', controller: _usernameCtrl, hint: '@seuuser'),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                            labelText: 'E-mail', border: const OutlineInputBorder(),
                            hintText: user?.email ?? ''),
                      ),
                      const SizedBox(height: 16),
                      _Field(label: 'Bio', controller: _bioCtrl, maxLines: 3,
                          hint: 'Fale um pouco sobre você...'),
                      _DatePickerField(
                          birthDate: _birthDate, onTap: _pickDate),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.go('/perfil'),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saving ? null : _handleSave,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                              child: Text(_saving ? 'Salvando…' : 'Salvar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar preview
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                          imageUrl: photoUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _photoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'URL da imagem',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Use uma URL para personalizar seu avatar',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.graySoft)),
                  ],
                ),
                const SizedBox(width: 40),

                // Formulário
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Informações básicas',
                          style: GoogleFonts.capriola(
                              fontSize: 16, color: AppColors.navy)),
                      const SizedBox(height: 16),

                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(_error,
                              style: const TextStyle(
                                  color: AppColors.danger, fontSize: 14)),
                        ),

                      _Field(label: 'Nome', controller: _nameCtrl),
                      _Field(label: 'Username', controller: _usernameCtrl,
                          hint: '@seuuser'),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          border: const OutlineInputBorder(),
                          hintText: user?.email ?? '',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Perfil',
                          style: GoogleFonts.capriola(
                              fontSize: 16, color: AppColors.navy)),
                      const SizedBox(height: 16),
                      _Field(
                          label: 'Bio',
                          controller: _bioCtrl,
                          maxLines: 3,
                          hint: 'Fale um pouco sobre você...'),
                      _DatePickerField(
                          birthDate: _birthDate, onTap: _pickDate),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.go('/perfil'),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _saving ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue),
                            child: Text(_saving
                                ? 'Salvando…'
                                : 'Salvar alterações'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? birthDate;
  final VoidCallback onTap;
  const _DatePickerField({required this.birthDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = birthDate != null
        ? '${birthDate!.day.toString().padLeft(2, '0')}/${birthDate!.month.toString().padLeft(2, '0')}/${birthDate!.year}'
        : 'Selecionar data';
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Data de nascimento',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today, size: 18),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: birthDate != null ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  const _Field(
      {required this.label,
      required this.controller,
      this.hint,
      this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
