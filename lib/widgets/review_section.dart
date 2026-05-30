import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_services.dart';
import '../theme.dart';

class ReviewSection extends StatefulWidget {
  final String destinationId;
  final double rating;
  final int reviewCount;

  const ReviewSection({
    super.key,
    required this.destinationId,
    required this.rating,
    required this.reviewCount,
  });

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  List<Review> _reviews = [];
  bool _isLoading = true;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final data = await ReviewService.getReviews(widget.destinationId);
      if (mounted)
        setState(() {
          _reviews = data;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _showAll ? _reviews : _reviews.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + rating summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ulasan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (_reviews.isNotEmpty)
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFD700),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.rating}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    ' (${widget.reviewCount})',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Rating bars summary
        if (_reviews.isNotEmpty) ...[
          _RatingSummary(reviews: _reviews),
          const SizedBox(height: 20),
        ],

        // Reviews list
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (_reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    color: AppColors.textMuted,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada ulasan',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Jadilah yang pertama memberi ulasan!',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          ...displayed.map((r) => _ReviewCard(review: r)),

        // Show more / less
        if (_reviews.length > 3) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _showAll = !_showAll),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _showAll
                      ? 'Sembunyikan ulasan'
                      : 'Lihat semua ${_reviews.length} ulasan',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Rating Summary Bars ──
class _RatingSummary extends StatelessWidget {
  final List<Review> reviews;
  const _RatingSummary({required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Average score
        Column(
          children: [
            Text(
              (reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                      reviews.length)
                  .toStringAsFixed(1),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 48,
                fontWeight: FontWeight.w800,
              ),
            ),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  Icons.star_rounded,
                  color:
                      i <
                          (reviews
                                      .map((r) => r.rating)
                                      .reduce((a, b) => a + b) /
                                  reviews.length)
                              .round()
                      ? const Color(0xFFFFD700)
                      : Colors.grey.shade300,
                  size: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${reviews.length} ulasan',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),

        const SizedBox(width: 20),

        // Bar chart per bintang
        Expanded(
          child: Column(
            children: List.generate(5, (i) {
              final star = 5 - i;
              final count = reviews.where((r) => r.rating == star).length;
              final percent = reviews.isEmpty ? 0.0 : count / reviews.length;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(
                      '$star',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD700),
                      size: 11,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFD700),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 20,
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Review Card ──
class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} bulan lalu';
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    return 'Baru saja';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: review.userAvatar != null
                    ? ClipOval(
                        child: Image.network(
                          review.userAvatar!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          (review.userName ?? 'A')[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Anonymous',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _timeAgo(review.createdAt),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFFFD700),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
