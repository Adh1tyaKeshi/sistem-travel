import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../theme.dart';

// ─────────────────────────────────────────
// BOOKING MODEL (sementara, nanti dari Supabase)
// ─────────────────────────────────────────
enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking {
  final String id;
  final Destination destination;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalPrice;
  final BookingStatus status;

  const Booking({
    required this.id,
    required this.destination,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
  });

  int get nights => checkOut.difference(checkIn).inDays;
}

// Dummy data — nanti diganti Supabase
final List<Booking> dummyBookings = [
  Booking(
    id: 'BK001',
    destination: dummyDestinations[0],
    checkIn: DateTime(2026, 6, 10),
    checkOut: DateTime(2026, 6, 15),
    guests: 2,
    totalPrice: 6250,
    status: BookingStatus.confirmed,
  ),
  Booking(
    id: 'BK002',
    destination: dummyDestinations[1],
    checkIn: DateTime(2026, 7, 1),
    checkOut: DateTime(2026, 7, 5),
    guests: 3,
    totalPrice: 2320,
    status: BookingStatus.pending,
  ),
  Booking(
    id: 'BK003',
    destination: dummyDestinations[2],
    checkIn: DateTime(2026, 3, 5),
    checkOut: DateTime(2026, 3, 10),
    guests: 2,
    totalPrice: 10500,
    status: BookingStatus.completed,
  ),
];

// ─────────────────────────────────────────
// BOOKING SCREEN
// ─────────────────────────────────────────
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = ['All', 'Upcoming', 'Completed', 'Cancelled'];

  List<Booking> _filtered(int index) {
    switch (index) {
      case 1:
        return dummyBookings
            .where(
              (b) =>
                  b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.pending,
            )
            .toList();
      case 2:
        return dummyBookings
            .where((b) => b.status == BookingStatus.completed)
            .toList();
      case 3:
        return dummyBookings
            .where((b) => b.status == BookingStatus.cancelled)
            .toList();
      default:
        return dummyBookings;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bookings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Manage your trips',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Tab bar ──
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final selected = _tabController.index == i;
                  return GestureDetector(
                    onTap: () => _tabController.animateTo(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white54,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── List ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(_tabs.length, (i) {
                  final bookings = _filtered(i);
                  if (bookings.isEmpty) return _EmptyBookings();
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, j) => _BookingCard(
                      booking: bookings[j],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookingDetailScreen(booking: bookings[j]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// BOOKING CARD
// ─────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _BookingCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image + status badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: Image.network(
                      booking.destination.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 70,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [const Color(0xFF1A1A1A), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                // Status badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: _StatusBadge(status: booking.status),
                ),
                // Booking ID
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${booking.id}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.destination.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white38,
                                  size: 12,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  booking.destination.country,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${booking.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${booking.nights} nights',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Date + guests row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _DateInfo(
                            label: 'Check-in',
                            date: booking.checkIn,
                          ),
                        ),
                        Container(width: 1, height: 32, color: Colors.white12),
                        Expanded(
                          child: _DateInfo(
                            label: 'Check-out',
                            date: booking.checkOut,
                          ),
                        ),
                        Container(width: 1, height: 32, color: Colors.white12),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Guests',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${booking.guests}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final DateTime date;
  const _DateInfo({required this.label, required this.date});

  String _format(DateTime d) => '${d.day} ${_month(d.month)} ${d.year}';

  String _month(int m) => [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          _format(date),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      BookingStatus.confirmed => (
        label: 'Confirmed',
        color: const Color(0xFF4CAF50),
      ),
      BookingStatus.pending => (
        label: 'Pending',
        color: const Color(0xFFFFB300),
      ),
      BookingStatus.cancelled => (
        label: 'Cancelled',
        color: const Color(0xFFEF5350),
      ),
      BookingStatus.completed => (label: 'Completed', color: Colors.white54),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.color.withOpacity(0.5)),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No bookings yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your upcoming trips will\nappear here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// BOOKING DETAIL SCREEN
// ─────────────────────────────────────────
class BookingDetailScreen extends StatelessWidget {
  final Booking booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero image
              SliverAppBar(
                expandedHeight: 280,
                pinned: false,
                backgroundColor: Colors.transparent,
                leading: const SizedBox.shrink(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        booking.destination.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              const Color(0xFF0D0D0D),
                              Colors.transparent,
                            ],
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
                      // Title + status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              booking.destination.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          _StatusBadge(status: booking.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white38,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.destination.country,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Booking info card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _InfoRow(
                              label: 'Booking ID',
                              value: '#${booking.id}',
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              label: 'Check-in',
                              value: _formatDate(booking.checkIn),
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              label: 'Check-out',
                              value: _formatDate(booking.checkOut),
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              label: 'Duration',
                              value: '${booking.nights} nights',
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              label: 'Guests',
                              value: '${booking.guests} people',
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(color: Colors.white12),
                            ),
                            _InfoRow(
                              label: 'Total Price',
                              value:
                                  '\$${booking.totalPrice.toStringAsFixed(0)}',
                              valueStyle: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Cancel button (only for upcoming)
                      if (booking.status == BookingStatus.confirmed ||
                          booking.status == BookingStatus.pending)
                        GestureDetector(
                          onTap: () => _showCancelDialog(context),
                          child: Container(
                            height: 52,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFEF5350).withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel Booking',
                                style: TextStyle(
                                  color: Color(0xFFEF5350),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (booking.status == BookingStatus.completed)
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 52,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryLight,
                                  AppColors.primary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppTheme.primaryShadow,
                            ),
                            child: const Center(
                              child: Text(
                                'Write a Review',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
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

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: TextStyle(color: Colors.white54, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep Booking',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel Booking',
              style: TextStyle(
                color: Color(0xFFEF5350),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        Text(
          value,
          style:
              valueStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
