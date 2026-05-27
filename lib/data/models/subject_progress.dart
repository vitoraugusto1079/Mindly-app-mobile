class SubjectProgress {
  final String id;
  final String subject;
  final int percentage;

  const SubjectProgress({
    required this.id,
    required this.subject,
    required this.percentage,
  });

  factory SubjectProgress.fromMap(Map<String, dynamic> map) {
    return SubjectProgress(
      id: map['id'].toString(),
      subject: map['subject'] as String? ?? '',
      percentage: (map['percentage'] as num?)?.toInt() ?? 0,
    );
  }
}
