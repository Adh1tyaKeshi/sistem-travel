class Review {
  final String id;
  final String userId;
  final String destinationId;
  final String? bookingId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;

  const Review({
    required this.id,
    required this.userId,
    required this.destinationId,
    this.bookingId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return Review(
      id: json['id'],
      userId: json['user_id'],
      destinationId: json['destination_id'],
      bookingId: json['booking_id'],
      rating: json['rating'] ?? 5,
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      userName: profile?['full_name'] ?? 'Anonymous',
      userAvatar: profile?['avatar_url'],
    );
  }
}