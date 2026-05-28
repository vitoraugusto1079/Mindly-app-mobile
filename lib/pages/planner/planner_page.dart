import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/planner_block.dart';
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

  bool _showAddModal = false;
  bool _showPauseModal = false;
  PlannerBlock? _editing;

  final _timeCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  Color _selectedColor = const Color(0xFF3B82F6);

  int _timeLeft = 0;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  void _startTimer(int minutes) {
    _timer?.cancel();
    setState(() {
      _timeLeft = minutes * 60;
      _isRunning = true;
      _showPauseModal = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 1) {
        _timer?.cancel();
        setState(() {
          _timeLeft = 0;
          _isRunning = false;
        });
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  String _formatTime(int t) {
    final m = t ~/ 60;
    final s = t % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _handleSave() async {
    final uid = _userId;
    if (_timeCtrl.text.isEmpty || _subjectCtrl.text.isEmpty || uid == null) {
      return;
    }
    final colorHex =
        '#${_selectedColor.value.toRadixString(16).substring(2)}';
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
        _showAddModal = false;
        _editing = null;
        _timeCtrl.clear();
        _subjectCtrl.clear();
        _selectedColor = const Color(0xFF3B82F6);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
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

  @override
  Widget build(BuildContext context) {
    final todayKey = _formatDateKey(DateTime.now());
    final selectedKey = _formatDateKey(_selectedDate);

    // Gera células do calendário
    final daysInMonth =
        DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    final firstDay =
        DateTime(_currentDate.year, _currentDate.month, 1).weekday % 7;
    final cells = [
      ...List<int?>.filled(firstDay, null),
      ...List.generate(daysInMonth, (i) => i + 1),
    ];

    return Stack(
      children: [
        Container(
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
                              bottom: BorderSide(
                                  color: AppColors.orange, width: 3)),
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
                        const Center(child: CircularProgressIndicator())
                      else if (_todaySchedule.isEmpty)
                        const Text('Nenhum horário cadastrado neste dia.',
                            style: TextStyle(
                                color: AppColors.graySoft,
                                fontStyle: FontStyle.italic))
                      else
                        ..._todaySchedule.map((item) => _ScheduleItem(
                              block: item,
                              color: _parseColor(item.color),
                              onEdit: () {
                                _timeCtrl.text = item.time;
                                _subjectCtrl.text = item.subject;
                                _selectedColor = _parseColor(item.color);
                                setState(() {
                                  _editing = item;
                                  _showAddModal = true;
                                });
                              },
                              onDelete: () => _handleDelete(item),
                            )),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  setState(() => _showAddModal = true),
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
                              onPressed: () =>
                                  setState(() => _showPauseModal = true),
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
        ),

        // TIMER FULLSCREEN
        if (_isRunning)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Pausa em andamento',
                      style: GoogleFonts.capriola(
                          fontSize: 24, color: AppColors.navy)),
                  const SizedBox(height: 20),
                  Text(
                    _formatTime(_timeLeft),
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 10 ? AppColors.danger : AppColors.blue,
                      fontFamily: 'Courier New',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _timer?.cancel();
                      setState(() => _isRunning = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                    ),
                    child: const Text('Encerrar pausa'),
                  ),
                ],
              ),
            ),
          ),

        // MODAL ADICIONAR/EDITAR
        if (_showAddModal && !_isRunning)
          _PlannerModal(
            title: _editing != null ? 'Editar horário' : 'Adicionar horário',
            timeCtrl: _timeCtrl,
            subjectCtrl: _subjectCtrl,
            selectedColor: _selectedColor,
            onColorChanged: (c) => setState(() => _selectedColor = c),
            onSave: _handleSave,
            onCancel: () => setState(() {
              _showAddModal = false;
              _editing = null;
              _timeCtrl.clear();
              _subjectCtrl.clear();
              _selectedColor = const Color(0xFF3B82F6);
            }),
          ),

        // MODAL PAUSA
        if (_showPauseModal && !_isRunning)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            alignment: Alignment.center,
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16)),
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
                            onPressed: () => _startTimer(min),
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
                      onPressed: () =>
                          setState(() => _showPauseModal = false),
                      child: const Text('Cancelar',
                          style: TextStyle(color: AppColors.graySoft)),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

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
              child: const Text('Editar',
                  style: TextStyle(color: AppColors.blue))),
          TextButton(
              onPressed: onDelete,
              child: const Text('Excluir',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
  }
}

class _PlannerModal extends StatelessWidget {
  final String title;
  final TextEditingController timeCtrl;
  final TextEditingController subjectCtrl;
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _PlannerModal({
    required this.title,
    required this.timeCtrl,
    required this.subjectCtrl,
    required this.selectedColor,
    required this.onColorChanged,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.pink, AppColors.navy,
    ];
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      alignment: Alignment.center,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.capriola(
                    fontSize: 22, color: AppColors.navy)),
            const SizedBox(height: 20),
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(
                labelText: 'Horário (HH:mm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(
                labelText: 'Disciplina',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            const Text('Cor:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: colors.map((c) {
                return GestureDetector(
                  onTap: () => onColorChanged(c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selectedColor == c
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text('Salvar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
