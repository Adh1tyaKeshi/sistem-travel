import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/destination.dart';

final supabase = Supabase.instance.client;

class DestinationService {
  // ── Semua destinasi ───────────────────────
  static Future<List<Destination>> getAll() async {
    final data = await supabase
        .from('destinations')
        .select('*, destination_images(*)')
        .order('created_at', ascending: false);

    return (data as List).map((e) => Destination.fromJson(e)).toList();
  }

  // ── Destinasi featured (popular) ─────────
  static Future<List<Destination>> getFeatured() async {
    final data = await supabase.from('destinations').select('''
        *,
        destination_images (
          image_url
        )
      ''');

    print(data);

    return (data as List).map((e) => Destination.fromJson(e)).toList();
  }

  // ── Destinasi by kategori ─────────────────
  static Future<List<Destination>> getByCategory(int categoryId) async {
    final data = await supabase
        .from('destinations')
        .select('*, destination_images(*)')
        .eq('category_id', categoryId)
        .order('rating', ascending: false);

    return (data as List).map((e) => Destination.fromJson(e)).toList();
  }

  // ── Search ────────────────────────────────
  static Future<List<Destination>> search(String query) async {
    final data = await supabase
        .from('destinations')
        .select('*, destination_images(*)')
        .or('name.ilike.%$query%,country.ilike.%$query%,city.ilike.%$query%');

    return (data as List).map((e) => Destination.fromJson(e)).toList();
  }

  // ── Detail by ID ──────────────────────────
  static Future<Destination?> getById(String id) async {
    final data = await supabase
        .from('destinations')
        .select('*, destination_images(*)')
        .eq('id', id)
        .single();

    return Destination.fromJson(data);
  }
}
