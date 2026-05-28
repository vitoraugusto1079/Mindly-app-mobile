import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  UserModel? _user;
  Session? _session;
  bool _loading = true;

  UserModel? get user => _user;
  Session? get session => _session;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _session = _service.currentSession;
    if (_session?.user != null) {
      await _loadProfile(_session!.user.id);
    }
    _loading = false;
    notifyListeners();

    _service.authStateChanges.listen((data) async {
      _session = data.session;
      if (_session?.user != null) {
        await _loadProfile(_session!.user.id);
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadProfile(String userId) async {
    try {
      _user = await _service.getProfile(userId);
    } catch (_) {
      _user = null;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await _service.signUp(email: email, password: password, name: name);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _service.signIn(email: email, password: password);
    _session = response.session;
    if (_session?.user != null) {
      await _loadProfile(_session!.user.id);
    }
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    await _service.signInWithGoogle();
  }

  Future<void> logout() async {
    await _service.signOut();
    _user = null;
    _session = null;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_session?.user == null) return;
    _user = await _service.updateProfile(_session!.user.id, updates);
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_session?.user != null) {
      await _loadProfile(_session!.user.id);
      notifyListeners();
    }
  }
}
