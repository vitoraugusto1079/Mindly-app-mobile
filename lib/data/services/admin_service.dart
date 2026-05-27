import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/plan.dart';
import '../models/ticket.dart';
import '../models/revenue.dart';

class AdminService {
  final _client = Supabase.instance.client;

  Future<List<UserModel>> listUsers() async {
    final data = await _client.from('profiles').select().order('name');
    return (data as List).map((e) => UserModel.fromMap(e)).toList();
  }

  Future<UserModel> updateUser(
      String id, Map<String, dynamic> fields) async {
    final data = await _client
        .from('profiles')
        .update(fields)
        .eq('id', id)
        .select()
        .single();
    return UserModel.fromMap(data);
  }

  Future<UserModel> toggleUserStatus(String id, String? current) async {
    final next = current == 'Ativo' ? 'Suspenso' : 'Ativo';
    final data = await _client
        .from('profiles')
        .update({'status': next})
        .eq('id', id)
        .select()
        .single();
    return UserModel.fromMap(data);
  }

  Future<List<Plan>> listPlans() async {
    final data = await _client.from('plans').select().order('id');
    return (data as List).map((e) => Plan.fromMap(e)).toList();
  }

  Future<Plan> createPlan(Map<String, dynamic> fields) async {
    final data = await _client.from('plans').insert(fields).select().single();
    return Plan.fromMap(data);
  }

  Future<Plan> updatePlan(String id, Map<String, dynamic> fields) async {
    final data = await _client
        .from('plans')
        .update(fields)
        .eq('id', id)
        .select()
        .single();
    return Plan.fromMap(data);
  }

  Future<List<Ticket>> listTickets() async {
    final data = await _client
        .from('contact_tickets')
        .select('*, profile:profiles(name)')
        .order('created_at', ascending: false);
    return (data as List).map((e) => Ticket.fromMap(e)).toList();
  }

  Future<void> replyTicket(String id, String reply) async {
    await _client.from('contact_tickets').update({
      'reply': reply,
      'status': 'Respondido',
    }).eq('id', id);
  }

  Future<List<Revenue>> listRevenue() async {
    final data = await _client.from('revenue').select().order('id');
    return (data as List).map((e) => Revenue.fromMap(e)).toList();
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final data =
        await _client.rpc('get_dashboard_stats') as Map<String, dynamic>;
    return data;
  }
}
