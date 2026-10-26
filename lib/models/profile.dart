class Profile {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String address;
  final String phone;
  final String course;
  final String notes;
  final String role;
  final String? avatarUrl;
  final double amountPaid; // <-- ADD THIS
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.address,
    required this.phone,
    required this.course,
    required this.notes,
    required this.role,
    this.avatarUrl,
    required this.amountPaid, // <-- ADD THIS
    required this.createdAt,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      email: map['email'] as String,
      address: (map['address'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      course: (map['course'] as String?) ?? '',
      notes: (map['notes'] as String?) ?? '',
      role: map['role'] as String,
      avatarUrl: map['avatar_url'] as String?,
      amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? 0.0, // <-- ADD THIS
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Helper method to make updating the profile object in our provider easier
  Profile copyWith({
    double? amountPaid,
  }) {
    return Profile(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      address: address,
      phone: phone,
      course: course,
      notes: notes,
      role: role,
      avatarUrl: avatarUrl,
      amountPaid: amountPaid ?? this.amountPaid,
      createdAt: createdAt,
    );
  }
}