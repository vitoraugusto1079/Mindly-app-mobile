import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/constants/content.dart';
import '../../data/services/progress_service.dart';
import '../../providers/auth_provider.dart';

class LearningPathPage extends StatefulWidget {
  const LearningPathPage({super.key});

  @override
  State<LearningPathPage> createState() => _LearningPathPageState();
}

class _LearningPathPageState extends State<LearningPathPage> {
  final _service = ProgressService();
  final _tts = FlutterTts();
  int _etapaAtual = 0;
  List<int> _concluidas = [];
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _load();
    _tts.setLanguage('pt-BR');
    _tts.setSpeechRate(0.9);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _ouvir() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    final etapa = learningPath[_etapaAtual];
    final texto = '${etapa.titulo}. ${etapa.conteudo}';
    setState(() => _isSpeaking = true);
    await _tts.speak(texto);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  String? get _userId =>
      context.read<AuthProvider>().session?.user.id;

  Future<void> _load() async {
    final uid = _userId;
    if (uid == null) return;
    final steps = await _service.listCompletedSteps(uid);
    setState(() => _concluidas = steps);
  }

  Future<void> _marcarConcluida() async {
    final etapa = learningPath[_etapaAtual];
    final uid = _userId;
    if (_concluidas.contains(etapa.id) || uid == null) return;
    await _service.completeStep(uid, etapa.id);
    setState(() => _concluidas = [..._concluidas, etapa.id]);
  }

  double get _progresso =>
      (_concluidas.length / learningPath.length) * 100;

  @override
  Widget build(BuildContext context) {
    final etapa = learningPath[_etapaAtual];
    final done = _concluidas.contains(etapa.id);

    final mobile = isMobile(context);

    final sidebar = Container(
      width: mobile ? double.infinity : 260,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trilha',
              style: GoogleFonts.capriola(fontSize: 22, color: AppColors.navy)),
          const SizedBox(height: 16),
          ...learningPath.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final isActive = i == _etapaAtual;
            final isDone = _concluidas.contains(item.id);
            return GestureDetector(
              onTap: () => setState(() => _etapaAtual = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.blue.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isActive ? Border.all(color: AppColors.blue) : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.green
                            : isActive ? AppColors.blue : const Color(0xFFDDDDDD),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          isDone ? '✓' : '${i + 1}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item.titulo,
                          style: TextStyle(
                              fontSize: 13,
                              color: isActive ? AppColors.blue : AppColors.navy,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );

    final content = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(etapa.titulo,
                    style: GoogleFonts.capriola(
                        fontSize: mobile ? 20 : 28, color: AppColors.navy)),
              ),
              Text('Etapa ${_etapaAtual + 1} de ${learningPath.length}',
                  style: const TextStyle(color: AppColors.graySoft)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progresso / 100,
              backgroundColor: const Color(0xFFDDDDDD),
              color: AppColors.blue,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etapa.conteudo,
                    style: const TextStyle(
                        fontSize: 16, color: AppColors.navy, height: 1.6)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Text('💡 ${etapa.dica}',
                      style: const TextStyle(fontSize: 14, color: AppColors.navy)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: _etapaAtual > 0 ? () => setState(() => _etapaAtual--) : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.graySoft),
                child: const Text('Voltar'),
              ),
              ElevatedButton(
                onPressed: _ouvir,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
                child: Text(_isSpeaking ? '⏹ Parar' : '🔊 Ouvir'),
              ),
              ElevatedButton(
                onPressed: done ? null : _marcarConcluida,
                style: ElevatedButton.styleFrom(
                    backgroundColor: done ? AppColors.green : AppColors.blue),
                child: Text(done ? '✔ Concluída' : '✔ Concluir'),
              ),
              ElevatedButton(
                onPressed: _etapaAtual < learningPath.length - 1
                    ? () => setState(() => _etapaAtual++)
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                child: const Text('Próximo'),
              ),
            ],
          ),
        ],
      ),
    );

    return Container(
      color: AppColors.bg,
      child: mobile
          ? SingleChildScrollView(
              child: Column(children: [sidebar, content]),
            )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sidebar,
          Expanded(child: content),
        ],
      ),
    );
  }
}
