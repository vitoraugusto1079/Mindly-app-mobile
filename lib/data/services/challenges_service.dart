import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/challenge.dart';
import '../models/user_challenge.dart';

class ChallengesService {
  final _client = Supabase.instance.client;

  Future<List<Challenge>> listActive() async {
    final data = await _client
        .from('challenges')
        .select()
        .eq('status', 'Ativo');
    return (data as List).map((e) => Challenge.fromMap(e)).toList();
  }

  Future<List<Challenge>> listAll() async {
    final data = await _client.from('challenges').select().order('id');
    return (data as List).map((e) => Challenge.fromMap(e)).toList();
  }

  Future<void> ensureProgress(String userId, String challengeId) async {
    await _client.from('user_challenges').upsert(
      {'user_id': userId, 'challenge_id': challengeId, 'progress': 0},
      onConflict: 'user_id,challenge_id',
      ignoreDuplicates: true,
    );
  }

  Future<List<UserChallenge>> listUserProgress(String userId) async {
    final data = await _client
        .from('user_challenges')
        .select('*, challenge:challenges(*)')
        .eq('user_id', userId);
    return (data as List).map((e) => UserChallenge.fromMap(e)).toList();
  }

  Future<void> addProgress(
      String userId, String challengeId, int coins) async {
    final existing = await _client
        .from('user_challenges')
        .select('progress')
        .eq('user_id', userId)
        .eq('challenge_id', challengeId)
        .single();

    final current = (existing['progress'] as num?)?.toInt() ?? 0;
    final next = (current + 34).clamp(0, 100);

    await _client.from('user_challenges').update({'progress': next}).match({
      'user_id': userId,
      'challenge_id': challengeId,
    });

    await _client.rpc('add_coins', params: {'uid': userId, 'amount': coins});
  }

  Future<Challenge> create(Map<String, dynamic> fields) async {
    final data =
        await _client.from('challenges').insert(fields).select().single();
    return Challenge.fromMap(data);
  }

  Future<Challenge> update(String id, Map<String, dynamic> fields) async {
    final data = await _client
        .from('challenges')
        .update(fields)
        .eq('id', id)
        .select()
        .single();
    return Challenge.fromMap(data);
  }

  Future<void> remove(String id) async {
    await _client.from('challenges').delete().eq('id', id);
  }
}
