import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/saved_booking_services.dart';
import '../services/review_services.dart';
import '../theme.dart';
import '../widgets/review_section.dart';
import 'booking_flow_screen.dart';
import 'write_review_screen.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  final Destination destination;
  const DetailScreen({super.key, required this.destination});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  bool _isSaved = false;
  bool _isSaveLoading = false;
  int _selectedImageIndex = 0;

  Destination get dest => widget.destination;

  @override
  void initState() {
    super.initState();
    _checkSaved();
  }

  Future<void> _checkSaved() async {
    final saved = await SavedService.isSaved(dest.id);
    if (mounted) {
      setState(() => _isSaved = saved);
    }
  }

  Future<void> _toggleSave() async {
    setState(() => _isSaveLoading = true);
    try {
      if (_isSaved) {
        await SavedService.unsave(dest.id);
      } else {
        await SavedService.save(dest.id);
      }
      if (mounted) {
        setState(() => _isSaved = !_isSaved);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaveLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = dest.galleryImages.isNotEmpty
        ? dest.galleryImages
        : [dest.imageUrl];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero image ──
              SliverAppBar(
                expandedHeight: 360,
                pinned: false,
                backgroundColor: Colors.transparent,
                leading: const SizedBox.shrink(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        images[_selectedImageIndex],
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.white, Colors.transparent],
                          ),
                        ),
                      ),
                      // Type badge
                      Positioned(
                        top: 60,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: dest.isPackage
                                ? const Color(0xFF6C63FF).withOpacity(0.9)
                                : AppColors.primary.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                dest.isPackage
                                    ? Icons.luggage
                                    : Icons.villa_outlined,
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                dest.isPackage ? 'Paket Wisata' : 'Akomodasi',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Rating & name
                      Positioned(
                        left: 20,
                        bottom: 70,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFD700),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${dest.rating}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  ' (${dest.reviewCount} reviews)',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dest.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${dest.city != null ? '${dest.city}, ' : ''}${dest.country}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Image dots
                      if (images.length > 1)
                        Positioned(
                          bottom: 52,
                          right: 20,
                          child: Row(
                            children: List.generate(
                              images.length,
                              (i) => GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImageIndex = i),
                                child: Container(
                                  width: i == _selectedImageIndex ? 20 : 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: i == _selectedImageIndex
                                        ? AppColors.primary
                                        : Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Fasilitas / Info chips ──
                      dest.isPackage
                          ? _PackageInfoChips(dest: dest)
                          : _AccommodationChips(dest: dest),

                      const SizedBox(height: 24),

                      // ── Highlights ──
                      if (dest.highlights.isNotEmpty) ...[
                        const Text(
                          'Yang Sudah Termasuk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: dest.highlights
                              .map(
                                (h) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        color: AppColors.primary,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        h,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Deskripsi ──
                      const Text(
                        'Tentang Destinasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dest.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.7,
                        ),
                      ),

                      // ── Gallery ──
                      if (images.length > 1) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Gallery',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, i) => GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedImageIndex = i),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 90,
                                  decoration: BoxDecoration(
                                    border: i == _selectedImageIndex
                                        ? Border.all(
                                            color: AppColors.primary,
                                            width: 2.5,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.network(
                                    images[i],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // ── Review Section ──
                      ReviewSection(
                        destinationId: dest.id,
                        rating: dest.rating,
                        reviewCount: dest.reviewCount,
                      ),

                      const SizedBox(height: 20),

                      // ── Tombol Write Review ──
                      _WriteReviewButton(destination: dest),

                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Back button ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // ── Save button ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: _isSaveLoading ? null : _toggleSave,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: _isSaveLoading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _isSaved ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: _isSaved
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
              ),
            ),
          ),

          // ── Bottom booking bar ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dest.isPackage ? 'Mulai dari' : 'Per malam',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rupiahFormat.format(dest.pricePerNight),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (dest.isPackage && dest.durationDays != null)
                        Text(
                          '/ ${dest.durationDays} hari',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingFormScreen(destination: dest),
                        ),
                      ),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryLight, AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.primaryShadow,
                        ),
                        child: Center(
                          child: Text(
                            dest.isPackage ? 'Pesan Paket' : 'Book Now',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chips untuk Accommodation ──
class _AccommodationChips extends StatelessWidget {
  final Destination dest;
  const _AccommodationChips({required this.dest});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (dest.beds > 0)
          _Chip(icon: Icons.king_bed_outlined, label: '${dest.beds} Beds'),
        if (dest.baths > 0)
          _Chip(icon: Icons.bathtub_outlined, label: '${dest.baths} Baths'),
        if (dest.hasPool) const _Chip(icon: Icons.pool_outlined, label: 'Pool'),
        if (dest.hasWifi) const _Chip(icon: Icons.wifi, label: 'WiFi'),
      ],
    );
  }
}

// ── Chips untuk Package ──
class _PackageInfoChips extends StatelessWidget {
  final Destination dest;
  const _PackageInfoChips({required this.dest});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (dest.durationDays != null)
          _Chip(
            icon: Icons.schedule_outlined,
            label: '${dest.durationDays} Hari',
          ),
        if (dest.minGroupSize != null && dest.minGroupSize! > 0)
          _Chip(
            icon: Icons.group_outlined,
            label: 'Min ${dest.minGroupSize} orang',
          ),
        if (dest.includesHotel)
          const _Chip(icon: Icons.hotel_outlined, label: 'Hotel'),
        if (dest.includesTransport)
          const _Chip(icon: Icons.directions_bus_outlined, label: 'Transport'),
        if (dest.includesMeals)
          const _Chip(icon: Icons.restaurant_outlined, label: 'Meals'),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Write Review Button ──
class _WriteReviewButton extends StatefulWidget {
  final Destination destination;
  const _WriteReviewButton({required this.destination});

  @override
  State<_WriteReviewButton> createState() => _WriteReviewButtonState();
}

class _WriteReviewButtonState extends State<_WriteReviewButton> {
  bool _canReview = false;
  bool _hasReviewed = false;

  @override
  void initState() {
    super.initState();
    _checkReviewEligibility();
  }

  Future<void> _checkReviewEligibility() async {
    final hasBooked = await ReviewService.hasBooked(widget.destination.id);
    final hasReviewed = await ReviewService.hasReviewed(widget.destination.id);
    if (mounted) {
      setState(() {
        _canReview = hasBooked && !hasReviewed;
        _hasReviewed = hasReviewed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasReviewed) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Color(0xFF4CAF50),
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Kamu sudah memberi ulasan',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (!_canReview) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WriteReviewScreen(destination: widget.destination),
        ),
      ).then((_) => _checkReviewEligibility()),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              color: AppColors.primary,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Tulis Ulasan',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
