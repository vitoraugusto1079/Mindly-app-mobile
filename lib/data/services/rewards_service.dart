import 'package:supabase_flutter/supabase_flutter.dart';

class RewardsService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listItems() async {
    final data = await _client.from('rewards').select().order('cost');
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<void> buyItem(String userId, String itemId, int cost) async {
    await _client.rpc('buy_reward', params: {
      'uid': userId,
      'reward_id': itemId,
      'cost': cost,
    });
  }
}
