import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/planner_block.dart';
import '../../widgets/common/skeleton.dart';
import '../../data/services/planner_service.dart';
import '../../providers/auth_provider.dart';

const _dayNames = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'];
const _monthNames = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

String _formatDateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final _service = PlannerService();

  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  List<PlannerBlock> _blocks = [];
  bool _loading = true;

  PlannerBlock? _editing;
  final _timeCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  Color _selectedColor = const Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  @override
  void dispose() {
    _timeCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  String? get _userId =>
      context.read<AuthProvider>().session?.user.id;

  Future<void> _loadBlocks() async {
    final uid = _userId;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final data = await _service.listAll(uid);
      setState(() => _blocks = data);
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Salva o horário; retorna true se bem-sucedido.
  Future<bool> _handleSave(Color selectedColor) async {
    final uid = _userId;
    if (_timeCtrl.text.isEmpty || _subjectCtrl.text.isEmpty || uid == null) {
      return false;
    }
    _selectedColor = selectedColor;
    final colorHex = '#${selectedColor.value.toRadixString(16).substring(2)}';
    final fields = {
      'time': _timeCtrl.text,
      'subject': _subjectCtrl.text,
      'color': colorHex,
    };
    try {
      if (_editing != null) {
        await _service.update(_editing!.id, fields);
      } else {
        await _service.create(uid, {
          'date': _formatDateKey(_selectedDate),
          ...fields,
        });
      }
      await _loadBlocks();
      setState(() {
        _editing = null;
        _timeCtrl.clear();
        _subjectCtrl.clear();
        _selectedColor = const Color(0xFF3B82F6);
      });
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
      return false;
    }
  }

  Future<void> _handleDelete(PlannerBlock block) async {
    await _service.remove(block.id);
    setState(() => _blocks.removeWhere((b) => b.id == block.id));
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.blue;
    }
  }

  List<PlannerBlock> get _todaySchedule {
    final key = _formatDateKey(_selectedDate);
    return _blocks.where((b) => b.date == key).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  // ── Abre o dialog "Adicionar / Editar horário" ──────────────────────────
  void _openAddModal([PlannerBlock? editing]) {
    if (editing != null) {
      _timeCtrl.text = editing.time;
      _subjectCtrl.text = editing.subject;
      _selectedColor = _parseColor(editing.color);
      _editing = editing;
    } else {
      _editing = null;
      _timeCtrl.clear();
      _subjectCtrl.clear();
      _selectedColor = const Color(0xFF3B82F6);
    }
    showDialog(
      context: context,
      builder: (ctx) => _PlannerModal(
        title: editing != null ? 'Editar horário' : 'Adicionar horário',
        timeCtrl: _timeCtrl,
        subjectCtrl: _subjectCtrl,
        initialColor: _selectedColor,
        onSave: (color) async {
          final ok = await _handleSave(color);
          if (ok && ctx.mounted) Navigator.of(ctx).pop();
        },
        onCancel: () {
          setState(() {
            _editing = null;
            _timeCtrl.clear();
            _subjectCtrl.clear();
            _selectedColor = const Color(0xFF3B82F6);
          });
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  // ── Abre o dialog de seleção de duração da pausa ────────────────────────
  void _openPauseModal() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tempo de pausa',
                  style: GoogleFonts.capriola(
                      fontSize: 22, color: AppColors.navy)),
              const SizedBox(height: 20),
              Row(
                children: [5, 10, 15].map((min) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _openTimerDialog(min);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.blue,
                          side: const BorderSide(
                              color: AppColors.blue, width: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('$min min'),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar',
                      style: TextStyle(color: AppColors.graySoft)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Abre o dialog do cronômetro de pausa ────────────────────────────────
  void _openTimerDialog(int minutes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TimerDialog(minutes: minutes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayKey = _formatDateKey(DateTime.now());
    final selectedKey = _formatDateKey(_selectedDate);

    final daysInMonth =
        DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    final firstDay =
        DateTime(_currentDate.year, _currentDate.month, 1).weekday % 7;
    final cells = [
      ...List<int?>.filled(firstDay, null),
      ...List.generate(daysInMonth, (i) => i + 1),
    ];

    return Container(
      color: AppColors.plannerBg,
      constraints: const BoxConstraints(minHeight: 700),
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Text('Monte seu planejamento, organize seus horários',
              style: GoogleFonts.capriola(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy),
              textAlign: TextAlign.center),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            padding: const EdgeInsets.all(30),
            child: LayoutBuilder(builder: (_, constraints) {
              final narrow = constraints.maxWidth < kMobileBreak;

              final calendarWidget = SizedBox(
                width: narrow ? double.infinity : 240,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _NavBtn(
                            icon: Icons.chevron_left,
                            onTap: () => setState(() => _currentDate =
                                DateTime(_currentDate.year,
                                    _currentDate.month - 1))),
                        Expanded(
                          child: Text(
                            '${_monthNames[_currentDate.month - 1]} ${_currentDate.year}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.capriola(
                                fontSize: 14, color: AppColors.navy),
                          ),
                        ),
                        _NavBtn(
                            icon: Icons.chevron_right,
                            onTap: () => setState(() => _currentDate =
                                DateTime(_currentDate.year,
                                    _currentDate.month + 1))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _dayNames
                          .map((d) => SizedBox(
                              width: 28,
                              child: Text(d,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.graySoft))))
                          .toList(),
                    ),
                    const SizedBox(height: 6),
                    GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      children: cells.map((day) {
                        if (day == null) return const SizedBox();
                        final key = _formatDateKey(DateTime(
                            _currentDate.year, _currentDate.month, day));
                        final isSelected = key == selectedKey;
                        final isToday = key == todayKey;
                        final hasSchedule =
                            _blocks.any((b) => b.date == key);
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDate =
                              DateTime(_currentDate.year,
                                  _currentDate.month, day)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.blue
                                  : isToday
                                      ? const Color(0xFFE3F2FD)
                                      : hasSchedule
                                          ? const Color(0xFFFFFBF5)
                                          : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.blueDark
                                    : isToday
                                        ? AppColors.blue
                                        : hasSchedule
                                            ? AppColors.orange
                                            : const Color(0xFFE8E8E8),
                                width: hasSchedule && !isSelected ? 3 : 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                          ? AppColors.blue
                                          : const Color(0xFF888888),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );

              final scheduleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(color: AppColors.orange, width: 3)),
                    ),
                    child: Text(
                      _selectedDate.toLocal().toString().split(' ')[0],
                      style: GoogleFonts.capriola(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const SkeletonSchedule()
                  else if (_todaySchedule.isEmpty)
                    const Text('Nenhum horário cadastrado neste dia.',
                        style: TextStyle(
                            color: AppColors.graySoft,
                            fontStyle: FontStyle.italic))
                  else
                    ..._todaySchedule.map((item) => _ScheduleItem(
                          block: item,
                          color: _parseColor(item.color),
                          onEdit: () => _openAddModal(item),
                          onDelete: () => _handleDelete(item),
                        )),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _openAddModal(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('+ adicionar horário'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _openPauseModal,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.blue,
                            side: const BorderSide(
                                color: AppColors.blue, width: 2),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Fazer pausa'),
                        ),
                      ),
                    ],
                  ),
                ],
              );

              return narrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        calendarWidget,
                        const SizedBox(height: 24),
                        scheduleWidget,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        calendarWidget,
                        const SizedBox(width: 30),
                        Expanded(child: scheduleWidget),
                      ],
                    );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Botão de navegação do calendário ─────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Item de horário ───────────────────────────────────────────────────────────
class _ScheduleItem extends StatelessWidget {
  final PlannerBlock block;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ScheduleItem(
      {required this.block,
      required this.color,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: AppColors.blue, width: 5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(block.time,
                style: const TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(block.subject,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15),
                  textAlign: TextAlign.center),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
              onPressed: onEdit,
              child:
                  const Text('Editar', style: TextStyle(color: AppColors.blue))),
          TextButton(
              onPressed: onDelete,
              child: const Text('Excluir',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
  }
}

// ── Dialog "Adicionar / Editar horário" ───────────────────────────────────────
class _PlannerModal extends StatefulWidget {
  final String title;
  final TextEditingController timeCtrl;
  final TextEditingController subjectCtrl;
  final Color initialColor;
  final Future<void> Function(Color) onSave;
  final VoidCallback onCancel;

  const _PlannerModal({
    required this.title,
    required this.timeCtrl,
    required this.subjectCtrl,
    required this.initialColor,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_PlannerModal> createState() => _PlannerModalState();
}

class _PlannerModalState extends State<_PlannerModal> {
  late Color _color;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.pink, AppColors.navy,
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title,
                      style: GoogleFonts.capriola(
                          fontSize: 20, color: AppColors.navy)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onCancel,
                    color: AppColors.graySoft,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Horário
              TextField(
                controller: widget.timeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Horário (HH:mm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 15),

              // Disciplina
              TextField(
                controller: widget.subjectCtrl,
                decoration: const InputDecoration(
                  labelText: 'Disciplina',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // Seletor de cor
              const Text('Cor:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: colors.map((c) {
                  final selected = _color == c;
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Colors.black, width: 3)
                            : Border.all(
                                color: Colors.transparent, width: 3),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                    color: c.withValues(alpha: 0.5),
                                    blurRadius: 8)
                              ]
                            : [],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving
                          ? null
                          : () async {
                              setState(() => _saving = true);
                              await widget.onSave(_color);
                              if (mounted) setState(() => _saving = false);
                            },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding:
                              const EdgeInsets.symmetric(vertical: 13)),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Salvar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 13)),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dialog do cronômetro de pausa (auto-gerenciado) ───────────────────────────
class _TimerDialog extends StatefulWidget {
  final int minutes;
  const _TimerDialog({required this.minutes});

  @override
  State<_TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<_TimerDialog> {
  late int _timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.minutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 1) {
        _timer?.cancel();
        if (mounted) {
          setState(() => _timeLeft = 0);
          Navigator.of(context).pop();
        }
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(int t) {
    final m = t ~/ 60;
    final s = t % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pausa em andamento',
                style: GoogleFonts.capriola(
                    fontSize: 22, color: AppColors.navy)),
            const SizedBox(height: 24),
            Text(
              _fmt(_timeLeft),
              style: TextStyle(
                fontSize: 76,
                fontWeight: FontWeight.bold,
                color: _timeLeft <= 10 ? AppColors.danger : AppColors.blue,
                fontFamily: 'Courier New',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _timer?.cancel();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(
                    horizontal: 36, vertical: 14),
              ),
              child: const Text('Encerrar pausa'),
            ),
          ],
        ),
      ),
    );
  }
}
