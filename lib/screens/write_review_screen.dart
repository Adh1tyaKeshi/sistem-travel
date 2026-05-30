import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/review_services.dart';
import '../theme.dart';

class WriteReviewScreen extends StatefulWidget {
  final Destination destination;
  final String? bookingId;

  const WriteReviewScreen({
    super.key,
    required this.destination,
    this.bookingId,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  final List<String> _ratingLabels = [
    '',
    'Buruk',
    'Kurang',
    'Cukup',
    'Bagus',
    'Luar Biasa!',
  ];

  final List<Color> _ratingColors = [
    Colors.transparent,
    const Color(0xFFEF5350),
    const Color(0xFFFF7043),
    const Color(0xFFFFB300),
    const Color(0xFF66BB6A),
    const Color(0xFF4CAF50),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih rating dulu ya!'),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tulis komentar dulu ya!'),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ReviewService.submitReview(
        destinationId: widget.destination.id,
        rating: _rating,
        comment: _commentController.text,
        bookingId: widget.bookingId,
      );

      if (!mounted) return;

      // Tampil success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF4CAF50),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Review Terkirim!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Terima kasih sudah berbagi pengalamanmu di ${widget.destination.name}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // tutup dialog
                  Navigator.pop(context); // kembali ke halaman sebelumnya
                },
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Oke, Makasih!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim review: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF5350),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Tulis Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Destination card
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: SizedBox(
                              width: 90,
                              height: 90,
                              child: Image.network(
                                widget.destination.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.destination.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.white38,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        widget.destination.country,
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Rating stars
                    const Text(
                      'Rating',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final star = i + 1;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = star),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              star <= _rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: star <= _rating
                                  ? const Color(0xFFFFD700)
                                  : Colors.white24,
                              size: 48,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 8),

                    // Rating label
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _rating > 0
                          ? Center(
                              key: ValueKey(_rating),
                              child: Text(
                                _ratingLabels[_rating],
                                style: TextStyle(
                                  color: _ratingColors[_rating],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : const Center(
                              child: Text(
                                'Tap bintang untuk memberi rating',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 32),

                    // Comment
                    const Text(
                      'Komentar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 5,
                        maxLength: 500,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Ceritakan pengalamanmu di sini...\nApa yang kamu suka? Ada yang perlu diperbaiki?',
                          hintStyle: const TextStyle(
                            color: Colors.white24,
                            fontSize: 13,
                            height: 1.6,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          counterStyle: const TextStyle(color: Colors.white24),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    GestureDetector(
                      onTap: _isLoading ? null : _submitReview,
                      child: Container(
                        height: 54,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: _rating > 0
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.primaryLight,
                                    AppColors.primary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: _rating == 0 ? Colors.white12 : null,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _rating > 0
                              ? AppTheme.primaryShadow
                              : null,
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Kirim Review',
                                  style: TextStyle(
                                    color: _rating > 0
                                        ? Colors.white
                                        : Colors.white38,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
