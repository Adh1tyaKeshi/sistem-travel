import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/destination.dart';
import '../widgets/filter_bar.dart';

final supabase = Supabase.instance.client;

class DestinationService {
  // ── Semua destinasi ──
  static Future<List<Destination>> getAll({DestinationFilter? filter}) async {
    var query = supabase
        .from('destinations')
        .select('*, destination_images(*)');

    query = _applyFilter(query, filter);

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => Destination.fromJson(e)).toList();
  }

  // ── Featured ──
  static Future<List<Destination>> getFeatured() async {
    final data = await supabase
        .from('destinations')
        .select('*, destination_images(*)')
        .eq('is_featured', true)
        .order('rating', ascending: false);

    return (data as List).map((e) => Destination.fromJson(e)).toList();
  }

  // ── Search dengan filter ──
  static Future<List<Destination>> search(
    String query, {
    DestinationFilter? filter,
  }) async {
    var q = supabase.from('destinations').select('*, destination_images(*)');

    if (query.isNotEmpty) {
      q = q.or(
        'name.ilike.%$query%,country.ilike.%$query%,city.ilike.%$query%',
      );
    }

    q = _applyFilter(q, filter);

    final data = await q.order('rating', ascending: false);
    return (data as List).map((e) => Destination.fromJson(e)).toList();
  }

  // ── By kategori ──
  static Future<List<Destination>> getByCategory(int categoryId) async {
    final data = await supabase
        .from('destinations')
        .select('*, destination_images(*)')
        .eq('category_id', categoryId)
        .order('rating', ascending: false);

    return (data as List).map((e) => Destination.fromJson(e)).toList();
  }

  // ── Detail ──
  static Future<Destination?> getById(String id) async {
    final data = await supabase
        .from('destinations')
        .select('*, destination_images(*)')
        .eq('id', id)
        .single();

    return Destination.fromJson(data);
  }

  // ── Apply filter helper ──
  static dynamic _applyFilter(dynamic query, DestinationFilter? filter) {
    if (filter == null) return query;

    if (filter.type != null) {
      query = query.eq('type', filter.type!);
    }
    if (filter.minPrice != null) {
      query = query.gte('price_per_night', filter.minPrice!);
    }
    if (filter.maxPrice != null) {
      query = query.lte('price_per_night', filter.maxPrice!);
    }
    if (filter.minRating != null) {
      query = query.gte('rating', filter.minRating!);
    }

    return query;
  }

  // Get Category
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final data = await supabase
        .from('categories')
        .select('id, name, icon')
        .order('id', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }
}
