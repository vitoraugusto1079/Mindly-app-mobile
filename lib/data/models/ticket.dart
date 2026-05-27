class Ticket {
  final String id;
  final String? name;
  final String subject;
  final String? message;
  final String status; // 'Aberto' | 'Respondido'
  final DateTime createdAt;
  final Map<String, dynamic>? profile;

  const Ticket({
    required this.id,
    this.name,
    required this.subject,
    this.message,
    required this.status,
    required this.createdAt,
    this.profile,
  });

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'].toString(),
      name: map['name'] as String?,
      subject: map['subject'] as String? ?? '',
      message: map['message'] as String?,
      status: map['status'] as String? ?? 'Aberto',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      profile: map['profile'] as Map<String, dynamic>?,
    );
  }
}
