import 'package:supabase_flutter/supabase_flutter.dart';

class ContactService {
  final _client = Supabase.instance.client;

  Future<void> sendMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
    String? userId,
  }) async {
    await _client.from('contact_tickets').insert({
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      if (userId != null) 'user_id': userId,
      'status': 'Aberto',
    });
  }
}
