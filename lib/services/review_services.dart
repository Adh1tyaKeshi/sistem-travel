import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review.dart';

final supabase = Supabase.instance.client;

class ReviewService {
  static String? get _userId => supabase.auth.currentUser?.id;

  // Ambil semua review untuk satu destinasi
  static Future<List<Review>> getReviews(String destinationId) async {
    // 1. Ambil reviews dulu
    final reviewData = await supabase
        .from('reviews')
        .select()
        .eq('destination_id', destinationId)
        .order('created_at', ascending: false);

    if ((reviewData as List).isEmpty) return [];

    // 2. Ambil user ids dari reviews
    final userIds = reviewData.map((e) => e['user_id']).toList();

    // 3. Ambil profiles berdasarkan user ids
    final profileData = await supabase
        .from('profiles')
        .select('id, full_name, avatar_url')
        .inFilter('id', userIds);

    // 4. Gabungkan data
    final profileMap = {for (var p in (profileData as List)) p['id']: p};

    return reviewData.map((e) {
      final profile = profileMap[e['user_id']];
      return Review.fromJson({...e, 'profiles': profile});
    }).toList();
  }

  // Cek apakah user sudah pernah review destinasi ini
  static Future<bool> hasReviewed(String destinationId) async {
    if (_userId == null) return false;

    final data = await supabase
        .from('reviews')
        .select('id')
        .eq('destination_id', destinationId)
        .eq('user_id', _userId!);

    return (data as List).isNotEmpty;
  }

  // Cek apakah user pernah booking destinasi ini
  static Future<bool> hasBooked(String destinationId) async {
    if (_userId == null) return false;

    final data = await supabase
        .from('bookings')
        .select('id')
        .eq('destination_id', destinationId)
        .eq('user_id', _userId!)
        .inFilter('status', ['completed', 'confirmed']);

    return (data as List).isNotEmpty;
  }

  // Submit review baru
  static Future<void> submitReview({
    required String destinationId,
    required int rating,
    required String comment,
    String? bookingId,
  }) async {
    if (_userId == null) throw Exception('User tidak login');

    await supabase.from('reviews').insert({
      'user_id': _userId,
      'destination_id': destinationId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment.trim(),
    });
  }

  // Update review yang sudah ada
  static Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    await supabase
        .from('reviews')
        .update({'rating': rating, 'comment': comment.trim()})
        .eq('id', reviewId)
        .eq('user_id', _userId!);
  }

  // Hapus review
  static Future<void> deleteReview(String reviewId) async {
    await supabase
        .from('reviews')
        .delete()
        .eq('id', reviewId)
        .eq('user_id', _userId!);
  }
}
