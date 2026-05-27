import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/achievement.dart';
import '../models/subject_progress.dart';

class ProgressService {
  final _client = Supabase.instance.client;

  Future<List<Achievement>> listAchievements(String userId) async {
    final data = await _client
        .from('achievements')
        .select('*, user_achievements!left(user_id)')
        .order('id');

    return (data as List).map((e) {
      final userAchs = e['user_achievements'] as List? ?? [];
      final unlocked = userAchs.any((ua) => ua['user_id'] == userId);
      return Achievement.fromMap({...e, 'unlocked': unlocked});
    }).toList();
  }

  Future<List<SubjectProgress>> listSubjectPerformance(String userId) async {
    final data = await _client
        .from('subject_performance')
        .select()
        .eq('user_id', userId);
    return (data as List).map((e) => SubjectProgress.fromMap(e)).toList();
  }

  Future<List<int>> listCompletedSteps(String userId) async {
    final data = await _client
        .from('learning_progress')
        .select('step_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['step_id'] as int).toList();
  }

  Future<void> completeStep(String userId, int stepId) async {
    await _client.from('learning_progress').upsert({
      'user_id': userId,
      'step_id': stepId,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }
}
