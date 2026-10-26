class Course {
  final String id;
  final String title;
  final double price;

  Course({
    required this.id,
    required this.title,
    required this.price,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String,
      title: map['title'] as String,
      // Handle numeric types safely (Supabase sometimes returns int for whole numbers)
      price: (map['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
    };
  }
}