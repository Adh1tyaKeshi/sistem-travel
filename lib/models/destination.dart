class Destination {
  final String id;
  final String name;
  final String country;
  final String? city;
  final String imageUrl;
  final List<String> galleryImages;
  final double rating;
  final int reviewCount;
  final double pricePerNight;
  final String description;

  // Accommodation fields
  final int beds;
  final int baths;
  final bool hasPool;
  final bool hasWifi;

  // V2 — Travel app fields
  final String type; // 'accommodation', 'package', 'attraction'
  final bool isFeatured;
  final int? categoryId;
  final List<String> highlights;
  final int? durationDays;
  final int? minGroupSize;
  final bool includesHotel;
  final bool includesTransport;
  final bool includesMeals;

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    this.city,
    required this.imageUrl,
    required this.galleryImages,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    required this.description,
    required this.beds,
    required this.baths,
    required this.hasPool,
    required this.hasWifi,
    this.type = 'accommodation',
    this.isFeatured = false,
    this.categoryId,
    this.highlights = const [],
    this.durationDays,
    this.minGroupSize,
    this.includesHotel = false,
    this.includesTransport = false,
    this.includesMeals = false,
  });

  // Helper getters
  bool get isPackage => type == 'package';
  bool get isAccommodation => type == 'accommodation';
  bool get isAttraction => type == 'attraction';

  factory Destination.fromJson(Map<String, dynamic> json) {
    final images = json['destination_images'] as List?;
    final gallery = images != null
        ? images.map((e) => e['image_url'].toString()).toList()
        : <String>[];

    return Destination(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      city: json['city'],
      imageUrl:
          json['cover_image_url'] ?? (gallery.isNotEmpty ? gallery.first : ''),
      galleryImages: gallery,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      pricePerNight: (json['price_per_night'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      beds: json['beds'] ?? 0,
      baths: json['baths'] ?? 0,
      hasPool: json['has_pool'] ?? false,
      hasWifi: json['has_wifi'] ?? false,
      // V2 fields — pakai ?? agar tetap kompatibel dengan data lama
      type: json['type'] ?? 'accommodation',
      isFeatured: json['is_featured'] ?? false,
      categoryId: json['category_id'],
      highlights: List<String>.from(json['highlights'] ?? []),
      durationDays: json['duration_days'],
      minGroupSize: json['min_group_size'],
      includesHotel: json['includes_hotel'] ?? false,
      includesTransport: json['includes_transport'] ?? false,
      includesMeals: json['includes_meals'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'city': city,
    'cover_image_url': imageUrl,
    'gallery_images': galleryImages,
    'rating': rating,
    'review_count': reviewCount,
    'price_per_night': pricePerNight,
    'description': description,
    'beds': beds,
    'baths': baths,
    'has_pool': hasPool,
    'has_wifi': hasWifi,
    'type': type,
    'is_featured': isFeatured,
    'category_id': categoryId,
    'highlights': highlights,
    'duration_days': durationDays,
    'min_group_size': minGroupSize,
    'includes_hotel': includesHotel,
    'includes_transport': includesTransport,
    'includes_meals': includesMeals,
  };
}

// ─────────────────────────────────────────
// PACKAGE MODEL
// ─────────────────────────────────────────
class TravelPackage {
  final String id;
  final String destinationId;
  final String name;
  final int durationDays;
  final int durationNights;
  final double price;
  final int minGroup;
  final int maxGroup;
  final bool includesHotel;
  final bool includesTransport;
  final bool includesMeals;
  final bool includesGuide;
  final String? coverImageUrl;
  final List<PackageDay> itinerary;
  final bool isAvailable;

  const TravelPackage({
    required this.id,
    required this.destinationId,
    required this.name,
    required this.durationDays,
    required this.durationNights,
    required this.price,
    this.minGroup = 1,
    this.maxGroup = 20,
    this.includesHotel = true,
    this.includesTransport = true,
    this.includesMeals = false,
    this.includesGuide = true,
    this.coverImageUrl,
    this.itinerary = const [],
    this.isAvailable = true,
  });

  factory TravelPackage.fromJson(Map<String, dynamic> json) {
    final itineraryJson = json['itinerary'] as List? ?? [];
    return TravelPackage(
      id: json['id'],
      destinationId: json['destination_id'],
      name: json['name'],
      durationDays: json['duration_days'],
      durationNights: json['duration_nights'],
      price: (json['price'] as num).toDouble(),
      minGroup: json['min_group'] ?? 1,
      maxGroup: json['max_group'] ?? 20,
      includesHotel: json['includes_hotel'] ?? true,
      includesTransport: json['includes_transport'] ?? true,
      includesMeals: json['includes_meals'] ?? false,
      includesGuide: json['includes_guide'] ?? true,
      coverImageUrl: json['cover_image_url'],
      itinerary: itineraryJson.map((e) => PackageDay.fromJson(e)).toList(),
      isAvailable: json['is_available'] ?? true,
    );
  }
}

class PackageDay {
  final int day;
  final String title;
  final List<String> activities;

  const PackageDay({
    required this.day,
    required this.title,
    required this.activities,
  });

  factory PackageDay.fromJson(Map<String, dynamic> json) {
    return PackageDay(
      day: json['day'],
      title: json['title'],
      activities: List<String>.from(json['activities'] ?? []),
    );
  }
}

// Data dummy — dipakai saat Supabase belum terhubung
final List<Destination> dummyDestinations = [
  Destination(
    id: '1',
    name: 'Amalfi Villa Retreat',
    country: 'Italy',
    city: 'Positano',
    imageUrl:
        'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=800',
    galleryImages: [
      'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=800',
      'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
    ],
    rating: 4.9,
    reviewCount: 124,
    pricePerNight: 1250,
    description:
        'Experience the pinnacle of Mediterranean living in this secluded clifftop sanctuary.',
    beds: 3,
    baths: 2,
    hasPool: true,
    hasWifi: true,
    type: 'accommodation',
    isFeatured: true,
    highlights: ['Private Pool', 'Ocean View', 'Free WiFi', 'Daily Breakfast'],
  ),
  Destination(
    id: '2',
    name: 'Ubud Rice Terrace Retreat',
    country: 'Indonesia',
    city: 'Ubud',
    imageUrl:
        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
    galleryImages: [
      'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
    ],
    rating: 4.8,
    reviewCount: 98,
    pricePerNight: 580,
    description:
        'Nestled in the heart of Ubud, this retreat offers a serene escape surrounded by lush rice terraces.',
    beds: 2,
    baths: 2,
    hasPool: true,
    hasWifi: true,
    type: 'accommodation',
    isFeatured: true,
    highlights: [
      'Rice Terrace View',
      'Private Pool',
      'Yoga Studio',
      'Organic Meals',
    ],
  ),
  Destination(
    id: '3',
    name: 'Swiss Alps Chalet',
    country: 'Switzerland',
    city: 'Zermatt',
    imageUrl:
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    galleryImages: [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    ],
    rating: 4.7,
    reviewCount: 76,
    pricePerNight: 2100,
    description:
        'A cozy alpine chalet with breathtaking mountain views, ski-in ski-out access.',
    beds: 4,
    baths: 3,
    hasPool: false,
    hasWifi: true,
    type: 'accommodation',
    isFeatured: true,
    highlights: ['Ski-in Ski-out', 'Mountain View', 'Fireplace', 'Heated Pool'],
  ),
  Destination(
    id: '4',
    name: 'Bali Island Explorer',
    country: 'Indonesia',
    city: 'Bali',
    imageUrl:
        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
    galleryImages: [],
    rating: 4.9,
    reviewCount: 210,
    pricePerNight: 450,
    description:
        'Jelajahi keindahan Pulau Dewata — dari sawah hijau Tegallalang hingga keajaiban budaya Ubud.',
    beds: 0,
    baths: 0,
    hasPool: false,
    hasWifi: true,
    type: 'package',
    isFeatured: true,
    durationDays: 4,
    minGroupSize: 1,
    includesHotel: true,
    includesTransport: true,
    includesMeals: true,
    highlights: [
      'Pemandu Lokal',
      'Hotel Bintang 4',
      'Transport AC',
      'Sarapan Harian',
    ],
  ),
];
