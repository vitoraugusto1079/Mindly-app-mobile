import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name.isNotEmpty ? name : email.split('@')[0]},
    );
    return res;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<UserModel> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromMap(data);
  }

  Future<UserModel> updateProfile(
      String userId, Map<String, dynamic> updates) async {
    final data = await _client
        .from('profiles')
        .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', userId)
        .select()
        .single();
    return UserModel.fromMap(data);
  }
}
