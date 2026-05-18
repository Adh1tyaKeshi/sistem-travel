class Destination {
  final String id;
  final String name;
  final String country;
  final String imageUrl;
  final List<String> galleryImages;
  final double rating;
  final int reviewCount;
  final double pricePerNight;
  final String description;
  final int beds;
  final int baths;
  final bool hasPool;
  final bool hasWifi;

  const Destination({
    required this.id,
    required this.name,
    required this.country,
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
  });

  // Siap untuk JSON nanti
  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      imageUrl: json['image_url'],
      galleryImages: List<String>.from(json['gallery_images'] ?? []),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'],
      pricePerNight: (json['price_per_night'] as num).toDouble(),
      description: json['description'],
      beds: json['beds'],
      baths: json['baths'],
      hasPool: json['has_pool'] ?? false,
      hasWifi: json['has_wifi'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'image_url': imageUrl,
    'gallery_images': galleryImages,
    'rating': rating,
    'review_count': reviewCount,
    'price_per_night': pricePerNight,
    'description': description,
    'beds': beds,
    'baths': baths,
    'has_pool': hasPool,
    'has_wifi': hasWifi,
  };
}

// Data dummy — nanti diganti API call
final List<Destination> dummyDestinations = [
  Destination(
    id: '1',
    name: 'Amalfi Villa Retreat',
    country: 'Positano, Italy',
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
        'Experience the pinnacle of Mediterranean living in this secluded clifftop sanctuary. Our private villa offers panoramic views of the Tyrrhenian Sea, blending traditional Italian craftsmanship with modern minimalist luxury.',
    beds: 3,
    baths: 2,
    hasPool: true,
    hasWifi: true,
  ),
  Destination(
    id: '2',
    name: 'Ubud Retreat',
    country: 'Bali, Indonesia',
    imageUrl:
        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
    galleryImages: [
      'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
    ],
    rating: 4.8,
    reviewCount: 98,
    pricePerNight: 580,
    description:
        'Nestled in the heart of Ubud, this retreat offers a serene escape surrounded by lush rice terraces and tropical gardens.',
    beds: 2,
    baths: 2,
    hasPool: true,
    hasWifi: true,
  ),
  Destination(
    id: '3',
    name: 'Swiss Alps Chalet',
    country: 'Switzerland',
    imageUrl:
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
    galleryImages: [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    ],
    rating: 4.7,
    reviewCount: 76,
    pricePerNight: 2100,
    description:
        'A cozy alpine chalet with breathtaking mountain views, ski-in ski-out access, and a warm fireplace to end your day.',
    beds: 4,
    baths: 3,
    hasPool: false,
    hasWifi: true,
  ),
];
