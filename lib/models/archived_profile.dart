class ArchivedProfile {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String course;
  final String role;
  final String notes;
  final double amountPaid;
  final DateTime originalCreatedAt;
  final DateTime archivedAt;
  final String? avatarUrl;

  ArchivedProfile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.course,
    required this.role,
    required this.notes,
    required this.amountPaid,
    required this.originalCreatedAt,
    required this.archivedAt,
    this.avatarUrl,
  });

  factory ArchivedProfile.fromMap(Map<String, dynamic> map) {
    return ArchivedProfile(
      // FIX 1: Look for 'archive_id' first
      id: (map['archive_id'] ?? map['id'])?.toString() ?? '',
      
      userId: map['user_id']?.toString() ?? '',
      firstName: map['first_name']?.toString() ?? '',
      lastName: map['last_name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: (map['phone'] as String?) ?? '',
      course: (map['course'] as String?) ?? '',
      role: map['role']?.toString() ?? 'user',
      notes: (map['notes'] as String?) ?? '',
      
      // FIX 2: Handle 'amount_paid' safely as either String OR Number
      amountPaid: map['amount_paid'] is String
          ? double.tryParse(map['amount_paid']) ?? 0.0
          : (map['amount_paid'] as num?)?.toDouble() ?? 0.0,
          
      originalCreatedAt: DateTime.tryParse(map['original_created_at']?.toString() ?? '') ?? DateTime.now(),
      archivedAt: DateTime.tryParse(map['archived_at']?.toString() ?? '') ?? DateTime.now(),
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}