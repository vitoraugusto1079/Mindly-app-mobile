import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/planner_block.dart';

class PlannerService {
  final _client = Supabase.instance.client;

  Future<List<PlannerBlock>> listAll(String userId) async {
    final data = await _client
        .from('study_blocks')
        .select()
        .eq('user_id', userId)
        .order('time');
    return (data as List).map((e) => PlannerBlock.fromMap(e)).toList();
  }

  Future<PlannerBlock> create(
      String userId, Map<String, dynamic> fields) async {
    final data = await _client
        .from('study_blocks')
        .insert({'user_id': userId, ...fields})
        .select()
        .single();
    return PlannerBlock.fromMap(data);
  }

  Future<PlannerBlock> update(String id, Map<String, dynamic> fields) async {
    final data = await _client
        .from('study_blocks')
        .update(fields)
        .eq('id', id)
        .select()
        .single();
    return PlannerBlock.fromMap(data);
  }

  Future<void> remove(String id) async {
    await _client.from('study_blocks').delete().eq('id', id);
  }
}
