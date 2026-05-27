class PlannerBlock {
  final String id;
  final String userId;
  final String date; // 'yyyy-MM-dd'
  final String time; // 'HH:mm'
  final String subject;
  final String color; // hex, ex: '#3b82f6'

  const PlannerBlock({
    required this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.subject,
    required this.color,
  });

  factory PlannerBlock.fromMap(Map<String, dynamic> map) {
    return PlannerBlock(
      id: map['id'].toString(),
      userId: map['user_id'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      subject: map['subject'] as String,
      color: map['color'] as String? ?? '#3b82f6',
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'date': date,
        'time': time,
        'subject': subject,
        'color': color,
      };
}
