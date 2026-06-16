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

    // 1. Ambil destination_id dari saved_destinations
    final savedData = await supabase
        .from('saved_destinations')
        .select('destination_id')
        .eq('user_id', _userId!);

    if ((savedData as List).isEmpty) return [];

    // 2. Ambil list destination_id
    final destinationIds = savedData
        .map((e) => e['destination_id'] as String)
        .toList();

    // 3. Ambil data destinations berdasarkan id
    final destinationsData = await supabase
        .from('destinations')
        .select('*, destination_images(*)')
        .inFilter('id', destinationIds);

    return (destinationsData as List)
        .map((e) => Destination.fromJson(e))
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

  // Buat booking baru dan kembalikan ID booking
  static Future<String> createBookingWithId({
    required String destinationId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required double totalPrice,
    String? notes,
  }) async {
    if (_userId == null) {
      throw Exception('User belum login');
    }

    final result = await supabase
        .from('bookings')
        .insert({
          'user_id': _userId,
          'destination_id': destinationId,
          'check_in': checkIn.toIso8601String().split('T').first,
          'check_out': checkOut.toIso8601String().split('T').first,
          'guests': guests,
          'total_price': totalPrice,
          'status': 'pending',
          if (notes != null) 'notes': notes,
        })
        .select('id')
        .single();

    return result['id'] as String;
  }

  // Batalkan booking
  static Future<void> cancelBooking(String bookingId) async {
    await supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }
}
