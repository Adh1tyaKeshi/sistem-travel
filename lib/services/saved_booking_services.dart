import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/destination.dart';

final supabase = Supabase.instance.client;

// ─────────────────────────────────────────
// SAVED SERVICE
// ─────────────────────────────────────────
class SavedService {
  static String? get _userId => supabase.auth.currentUser?.id;

  // Ambil semua saved destinasi user
  static Future<List<Destination>> getSaved() async {
    if (_userId == null) return [];

    final data = await supabase
        .from('saved_destinations')
        .select('destination_id, destinations(*, destination_images(*))')
        .eq('user_id', _userId!);

    return (data as List)
        .map((e) => Destination.fromJson(e['destinations']))
        .toList();
  }

  // Simpan destinasi
  static Future<void> save(String destinationId) async {
    if (_userId == null) return;

    await supabase.from('saved_destinations').insert({
      'user_id': _userId,
      'destination_id': destinationId,
    });
  }

  // Hapus dari saved
  static Future<void> unsave(String destinationId) async {
    if (_userId == null) return;

    await supabase
        .from('saved_destinations')
        .delete()
        .eq('user_id', _userId!)
        .eq('destination_id', destinationId);
  }

  // Cek apakah destinasi sudah di-save
  static Future<bool> isSaved(String destinationId) async {
    if (_userId == null) return false;

    final data = await supabase
        .from('saved_destinations')
        .select('id')
        .eq('user_id', _userId!)
        .eq('destination_id', destinationId);

    return (data as List).isNotEmpty;
  }
}

// ─────────────────────────────────────────
// BOOKING SERVICE
// ─────────────────────────────────────────
class BookingService {
  static String? get _userId => supabase.auth.currentUser?.id;

  // Ambil semua booking user
  static Future<List<Map<String, dynamic>>> getBookings() async {
    if (_userId == null) return [];

    final data = await supabase
        .from('bookings')
        .select('*, destinations(*, destination_images(*))')
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // Buat booking baru
  static Future<void> createBooking({
    required String destinationId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required double totalPrice,
    String? notes,
  }) async {
    if (_userId == null) return;

    await supabase.from('bookings').insert({
      'user_id': _userId,
      'destination_id': destinationId,
      'check_in': checkIn.toIso8601String().split('T').first,
      'check_out': checkOut.toIso8601String().split('T').first,
      'guests': guests,
      'total_price': totalPrice,
      'status': 'pending',
      if (notes != null) 'notes': notes,
    });
  }

  // Batalkan booking
  static Future<void> cancelBooking(String bookingId) async {
    await supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }
}
