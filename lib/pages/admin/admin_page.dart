import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/skeleton.dart';
import '../../data/models/user_model.dart';
import '../../data/models/plan.dart';
import '../../data/models/challenge.dart';
import '../../data/models/ticket.dart';
import '../../data/models/revenue.dart';
import '../../data/services/admin_service.dart';
import '../../data/services/challenges_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _admin = AdminService();
  final _challenges = ChallengesService();

  String _activeTab = 'Dashboard';
  bool _loading = true;
  String? _toast;

  List<UserModel> _users = [];
  List<Plan> _plans = [];
  List<Challenge> _challengeList = [];
  List<Ticket> _tickets = [];
  List<Revenue> _revenue = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _admin.listUsers(),
        _admin.listPlans(),
        _challenges.listAll(),
        _admin.listTickets(),
        _admin.listRevenue(),
        _admin.getDashboardStats(),
      ]);
      setState(() {
        _users = results[0] as List<UserModel>;
        _plans = results[1] as List<Plan>;
        _challengeList = results[2] as List<Challenge>;
        _tickets = results[3] as List<Ticket>;
        _revenue = results[4] as List<Revenue>;
        _stats = results[5] as Map<String, dynamic>;
      });
    } catch (e) {
      _showToast('Erro ao carregar: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showToast(String msg) {
    setState(() => _toast = msg);
    Future.delayed(const Duration(seconds: 3),
        () => mounted ? setState(() => _toast = null) : null);
  }

  final _tabs = [
    {'key': 'Dashboard', 'icon': Icons.bar_chart},
    {'key': 'Usuários', 'icon': Icons.people},
    {'key': 'Planos', 'icon': Icons.assignment},
    {'key': 'Desafios', 'icon': Icons.emoji_events},
    {'key': 'Tickets', 'icon': Icons.support_agent},
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    final tabItems = _tabs.map((t) {
      final key = t['key'] as String;
      final icon = t['icon'] as IconData;
      final isActive = _activeTab == key;
      return GestureDetector(
        onTap: () => setState(() => _activeTab = key),
        child: Container(
          margin: mobile
              ? const EdgeInsets.only(right: 8)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: EdgeInsets.symmetric(
              horizontal: mobile ? 12 : 14, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.blue.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: isActive ? Colors.white : Colors.white60, size: 18),
              const SizedBox(width: 8),
              Text(key,
                  style: TextStyle(
                      color: isActive ? Colors.white : Colors.white60,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      );
    }).toList();

    return Stack(
      children: [
        Container(
          color: AppColors.bg,
          child: mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: AppColors.navy,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: tabItems),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildPanel(),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      color: AppColors.navy,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(children: tabItems),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: _loading
                            ? const SkeletonAdminPanel()
                            : _buildPanel(),
                      ),
                    ),
                  ],
                ),
        ),

        // Toast
        if (_toast != null)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 26, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text('✅ $_toast',
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPanel() {
    switch (_activeTab) {
      case 'Usuários':
        return _UsersPanel(
          users: _users,
          onUpdate: (u, fields) async {
            final updated = await _admin.updateUser(u.id, fields);
            setState(() =>
                _users = _users.map((x) => x.id == updated.id ? updated : x).toList());
            _showToast('Usuário salvo!');
          },
          onToggleStatus: (u) async {
            final updated = await _admin.toggleUserStatus(u.id, u.status);
            setState(() =>
                _users = _users.map((x) => x.id == updated.id ? updated : x).toList());
            _showToast('Status atualizado!');
          },
        );
      case 'Planos':
        return _PlansPanel(
          plans: _plans,
          onSave: (p, fields) async {
            final updated = await _admin.updatePlan(p.id, fields);
            setState(() =>
                _plans = _plans.map((x) => x.id == updated.id ? updated : x).toList());
            _showToast('Plano salvo!');
          },
          onCreate: (fields) async {
            final created = await _admin.createPlan(fields);
            setState(() => _plans = [..._plans, created]);
            _showToast('Plano criado!');
          },
        );
      case 'Desafios':
        return _ChallengesPanel(
          challenges: _challengeList,
          onSave: (c, fields) async {
            final updated = await _challenges.update(c.id, fields);
            setState(() => _challengeList = _challengeList
                .map((x) => x.id == updated.id ? updated : x)
                .toList());
            _showToast('Desafio salvo!');
          },
          onCreate: (fields) async {
            final created = await _challenges.create(fields);
            setState(() => _challengeList = [..._challengeList, created]);
            _showToast('Desafio criado!');
          },
          onDelete: (id) async {
            await _challenges.remove(id);
            setState(() =>
                _challengeList = _challengeList.where((c) => c.id != id).toList());
            _showToast('Desafio apagado!');
          },
          onToggle: (c) async {
            final updated = await _challenges.update(c.id, {
              'status': c.status == 'Ativo' ? 'Suspenso' : 'Ativo'
            });
            setState(() => _challengeList = _challengeList
                .map((x) => x.id == updated.id ? updated : x)
                .toList());
            _showToast('Status alterado!');
          },
        );
      case 'Tickets':
        return _TicketsPanel(
          tickets: _tickets,
          onReply: (t, reply) async {
            await _admin.replyTicket(t.id, reply);
            setState(() => _tickets = _tickets
                .map((x) =>
                    x.id == t.id ? Ticket.fromMap({...{}, 'status': 'Respondido', 'id': t.id, 'subject': t.subject, 'created_at': t.createdAt.toIso8601String()}) : x)
                .toList());
            _showToast('Resposta enviada!');
          },
        );
      default:
        return _DashboardPanel(
            stats: _stats, plans: _plans, revenue: _revenue, users: _users);
    }
  }
}

// ---- Dashboard ----
class _DashboardPanel extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<Plan> plans;
  final List<Revenue> revenue;
  final List<UserModel> users;
  const _DashboardPanel(
      {required this.stats,
      required this.plans,
      required this.revenue,
      required this.users});

  @override
  Widget build(BuildContext context) {
    final maxRev = revenue.isEmpty
        ? 1.0
        : revenue.map((r) => r.amount).reduce((a, b) => a > b ? a : b);
    final totalPlanUsers =
        plans.fold<int>(0, (acc, p) => acc + p.usersCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Painel Geral',
            style: GoogleFonts.capriola(fontSize: 24, color: AppColors.navy)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatCard(value: '${stats['total_users'] ?? users.length}', label: 'Usuários'),
            _StatCard(
                value: 'R\$ ${((stats['latest_revenue'] ?? 0) / 1000).toStringAsFixed(1)}k',
                label: 'Receita (Mês)',
                highlight: true),
            _StatCard(value: '${stats['active_challenges'] ?? 0}', label: 'Desafios Ativos'),
            _StatCard(value: '${stats['open_tickets'] ?? 0}', label: 'Tickets Abertos'),
          ],
        ),
        const SizedBox(height: 32),
        LayoutBuilder(builder: (_, c) {
          final narrow = c.maxWidth < kMobileBreak;
          final revenueCard = Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Evolução da Receita',
                    style: GoogleFonts.capriola(
                        fontSize: 16, color: AppColors.navy)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: revenue.map((r) {
                      final h = (r.amount / maxRev) * 140;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 28,
                            height: h,
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(r.month,
                              style: const TextStyle(fontSize: 10)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
          final plansCard = Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assinantes por Plano',
                    style: GoogleFonts.capriola(
                        fontSize: 16, color: AppColors.navy)),
                const SizedBox(height: 16),
                ...plans.map((p) {
                  final pct = totalPlanUsers == 0
                      ? 0.0
                      : p.usersCount / totalPlanUsers;
                  final color = p.name == 'Premium'
                      ? AppColors.orange
                      : p.name == 'Institucional'
                          ? AppColors.green
                          : AppColors.blue;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(p.name),
                            Text('${p.usersCount} usuários',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: pct,
                          backgroundColor: const Color(0xFFEEEEEE),
                          color: color,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        Text('${(pct * 100).round()}% do total',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.graySoft)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
          return narrow
              ? Column(children: [
                  revenueCard,
                  const SizedBox(height: 16),
                  plansCard,
                ])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: revenueCard),
                    const SizedBox(width: 16),
                    Expanded(child: plansCard),
                  ],
                );
        }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;
  const _StatCard(
      {required this.value,
      required this.label,
      this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlight ? AppColors.orange : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.capriola(
                  fontSize: 28,
                  color:
                      highlight ? Colors.white : AppColors.navy)),
          Text(label,
              style: TextStyle(
                  color: highlight ? Colors.white70 : AppColors.graySoft)),
        ],
      ),
    );
  }
}

// ---- Usuários ----
class _UsersPanel extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel, Map<String, dynamic>) onUpdate;
  final Function(UserModel) onToggleStatus;
  const _UsersPanel(
      {required this.users,
      required this.onUpdate,
      required this.onToggleStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gerenciar Usuários',
              style: GoogleFonts.capriola(
                  fontSize: 20, color: AppColors.navy)),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(2),
            },
            children: [
              const TableRow(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Color(0xFFEEEEEE)))),
                children: [
                  _TH('Nome'), _TH('Email'), _TH('Plano'),
                  _TH('Moedas'), _TH('Ações'),
                ],
              ),
              ...users.map((u) => TableRow(
                    children: [
                      _TD(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.name ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text(u.status ?? '',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: u.status == 'Ativo'
                                      ? AppColors.green
                                      : AppColors.danger)),
                        ],
                      )),
                      _TD(Text(u.email, style: const TextStyle(fontSize: 13))),
                      _TD(Text(u.plan, style: const TextStyle(fontSize: 13))),
                      _TD(Text('${u.coins}',
                          style: const TextStyle(fontSize: 13))),
                      _TD(Row(children: [
                        TextButton(
                            onPressed: () => onToggleStatus(u),
                            child: Text(
                                u.status == 'Ativo'
                                    ? 'Suspender'
                                    : 'Reativar',
                                style: const TextStyle(
                                    color: AppColors.orange))),
                      ])),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ---- Planos ----
class _PlansPanel extends StatelessWidget {
  final List<Plan> plans;
  final Function(Plan, Map<String, dynamic>) onSave;
  final Function(Map<String, dynamic>) onCreate;
  const _PlansPanel(
      {required this.plans, required this.onSave, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gerenciar Planos',
                  style: GoogleFonts.capriola(
                      fontSize: 20, color: AppColors.navy)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue),
                child: const Text('+ Novo Plano'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: plans
                .map((p) => Container(
                      width: 240,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: p.name == 'Premium'
                            ? Border.all(
                                color: AppColors.orange, width: 3)
                            : null,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: GoogleFonts.capriola(
                                  fontSize: 20,
                                  color: AppColors.navy)),
                          Text(p.price,
                              style: const TextStyle(
                                  fontSize: 22,
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.bold)),
                          if (p.description != null)
                            Text(p.description!,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.graySoft)),
                          const SizedBox(height: 8),
                          Text('${p.usersCount} assinantes ativos',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.graySoft)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ---- Desafios ----
class _ChallengesPanel extends StatelessWidget {
  final List<Challenge> challenges;
  final Function(Challenge, Map<String, dynamic>) onSave;
  final Function(Map<String, dynamic>) onCreate;
  final Function(String) onDelete;
  final Function(Challenge) onToggle;
  const _ChallengesPanel(
      {required this.challenges,
      required this.onSave,
      required this.onCreate,
      required this.onDelete,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gerenciar Desafios',
                  style: GoogleFonts.capriola(
                      fontSize: 20, color: AppColors.navy)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue),
                child: const Text('+ Criar Desafio'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...challenges.map((c) => ListTile(
                leading:
                    const Icon(Icons.emoji_events, color: AppColors.orange),
                title: Text(c.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(c.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                        onPressed: () => onToggle(c),
                        child: Text(
                            c.status == 'Ativo' ? 'Suspender' : 'Reativar',
                            style: const TextStyle(
                                color: AppColors.orange))),
                    TextButton(
                        onPressed: () => onDelete(c.id),
                        child: const Text('Apagar',
                            style: TextStyle(color: AppColors.danger))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ---- Tickets ----
class _TicketsPanel extends StatelessWidget {
  final List<Ticket> tickets;
  final Function(Ticket, String) onReply;
  const _TicketsPanel(
      {required this.tickets, required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tickets de Suporte',
              style: GoogleFonts.capriola(
                  fontSize: 20, color: AppColors.navy)),
          const SizedBox(height: 16),
          ...tickets.map((t) => ListTile(
                title: Text(t.subject,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    t.profile?['name'] ?? t.name ?? 'Visitante'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: t.status == 'Aberto'
                            ? AppColors.orange.withValues(alpha: 0.15)
                            : AppColors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(t.status,
                          style: TextStyle(
                              color: t.status == 'Aberto'
                                  ? AppColors.orange
                                  : AppColors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// Helpers de tabela
class _TH extends StatelessWidget {
  final String label;
  const _TH(this.label);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.navy)),
      );
}

class _TD extends StatelessWidget {
  final Widget child;
  const _TD(this.child);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: child,
      );
}
