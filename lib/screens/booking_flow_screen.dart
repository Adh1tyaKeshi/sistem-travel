import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/destination.dart';
import '../services/saved_booking_services.dart';
import '../services/payment_services.dart';
import '../theme.dart';
import 'package:intl/intl.dart';

final rupiahFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

// ═════════════════════════════════════════
// STEP 1 — BOOKING FORM SCREEN
// ═════════════════════════════════════════
class BookingFormScreen extends StatefulWidget {
  final Destination destination;
  const BookingFormScreen({super.key, required this.destination});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  final _notesController = TextEditingController();

  Destination get dest => widget.destination;

  int get _nights => (_checkIn != null && _checkOut != null)
      ? _checkOut!.difference(_checkIn!).inDays
      : 0;

  double get _totalPrice => _nights * dest.pricePerNight;
  bool get _canProceed => _checkIn != null && _checkOut != null && _nights > 0;

  Future<void> _pickDate(bool isCheckIn) async {
    final now = DateTime.now();
    final initial = isCheckIn
        ? (_checkIn ?? now.add(const Duration(days: 1)))
        : (_checkOut ??
              (_checkIn?.add(const Duration(days: 1)) ??
                  now.add(const Duration(days: 2))));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isCheckIn
          ? now
          : (_checkIn ?? now).add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: Color(0xFF1A1A1A),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkOut != null && !_checkOut!.isAfter(picked))
            _checkOut = null;
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: false,
                backgroundColor: Colors.transparent,
                leading: const SizedBox.shrink(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(dest.imageUrl, fit: BoxFit.cover),
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
                      Text(
                        dest.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white38,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dest.country,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFD700),
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${dest.rating}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _SectionTitle('Pilih Tanggal'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DatePickerCard(
                              label: 'Check-in',
                              date: _checkIn,
                              onTap: () => _pickDate(true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DatePickerCard(
                              label: 'Check-out',
                              date: _checkOut,
                              onTap: () => _pickDate(false),
                            ),
                          ),
                        ],
                      ),
                      if (_nights > 0) ...[
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '$_nights night${_nights > 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _SectionTitle('Tamu'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jumlah tamu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Max ${dest.beds * 2} people',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _CounterBtn(
                                  icon: Icons.remove,
                                  onTap: () {
                                    if (_guests > 1) setState(() => _guests--);
                                  },
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  '$_guests',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                _CounterBtn(
                                  icon: Icons.add,
                                  onTap: () {
                                    if (_guests < dest.beds * 2)
                                      setState(() => _guests++);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle('Permintaan Khusus (opsional)'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _notesController,
                          maxLines: 3,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Ada permintaan atau catatan khusus?',
                            hintStyle: TextStyle(
                              color: Colors.white24,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
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
                        _nights > 0
                            ? rupiahFormat.format(_totalPrice)
                            : rupiahFormat.format(dest.pricePerNight),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _nights > 0 ? '$_nights nights total' : 'per night',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: _canProceed
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingConfirmScreen(
                                  destination: dest,
                                  checkIn: _checkIn!,
                                  checkOut: _checkOut!,
                                  guests: _guests,
                                  totalPrice: _totalPrice,
                                  notes: _notesController.text,
                                ),
                              ),
                            )
                          : null,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: _canProceed
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.primaryLight,
                                    AppColors.primary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: _canProceed ? null : Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _canProceed
                              ? AppTheme.primaryShadow
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Lanjutkan',
                            style: TextStyle(
                              color: _canProceed
                                  ? Colors.white
                                  : Colors.white38,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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

// ═════════════════════════════════════════
// STEP 2 — BOOKING CONFIRMATION SCREEN
// ═════════════════════════════════════════
class BookingConfirmScreen extends StatefulWidget {
  final Destination destination;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalPrice;
  final String notes;

  const BookingConfirmScreen({
    super.key,
    required this.destination,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.notes,
  });

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  bool _isLoading = false;
  String _selectedMethod = 'gopay';

  static const _methods = [
    ('gopay', 'GoPay', 'Scan QR untuk bayar', Color(0xFF00AE11), 'G'),
    ('shopeepay', 'ShopeePay', 'Scan QR untuk bayar', Color(0xFFEE4D2D), 'S'),
    ('dana', 'DANA', 'Bayar dari DANA', Color(0xFF108EE9), 'D'),
    ('ovo', 'OVO', 'Bayar dari OVO', Color(0xFF4C3494), 'O'),
    (
      'bca_va',
      'BCA Virtual Account',
      'Transfer ke nomor VA',
      Color(0xFF003064),
      'BCA',
    ),
    (
      'bni_va',
      'BNI Virtual Account',
      'Transfer ke nomor VA',
      Color(0xFFF15A24),
      'BNI',
    ),
    (
      'bri_va',
      'BRI Virtual Account',
      'Transfer ke nomor VA',
      Color(0xFF1A1464),
      'BRI',
    ),
    (
      'mandiri_va',
      'Mandiri Virtual Account',
      'Transfer ke nomor VA',
      Color(0xFF003087),
      'MDR',
    ),
  ];

  bool get _isVA => _selectedMethod.endsWith('_va');
  bool get _isEWallet =>
      ['gopay', 'shopeepay', 'dana', 'ovo'].contains(_selectedMethod);

  int get _nights => widget.checkOut.difference(widget.checkIn).inDays;

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

  // Generate nomor VA simulasi
  String _generateVANumber(String method) {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    switch (method) {
      case 'bca_va':
        return '8277${random.substring(random.length - 8)}';
      case 'bni_va':
        return '9889${random.substring(random.length - 8)}';
      case 'bri_va':
        return '1234${random.substring(random.length - 8)}';
      case 'mandiri_va':
        return '8908${random.substring(random.length - 8)}';
      default:
        return random.substring(random.length - 12);
    }
  }

  // Generate kode QR simulasi untuk e-wallet
  String _generateQRCode(String method) {
    return 'QR-${method.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);

    try {
      final bookingId = await BookingService.createBookingWithId(
        destinationId: widget.destination.id,
        checkIn: widget.checkIn,
        checkOut: widget.checkOut,
        guests: widget.guests,
        totalPrice: widget.totalPrice,
        notes: widget.notes.isNotEmpty ? widget.notes : null,
      );

      final user = Supabase.instance.client.auth.currentUser;
      final userEmail = user?.email ?? '';
      final userName = user?.userMetadata?['full_name'] ?? 'Explorer';

      final result = await PaymentService.createTransaction(
        bookingId: bookingId,
        amount: widget.totalPrice,
        customerName: userName,
        customerEmail: userEmail,
        itemName: widget.destination.name,
        paymentMethod: _selectedMethod,
      );

      await PaymentService.handlePaymentResult(
        bookingId: bookingId,
        orderId: result['order_id']!,
        paymentStatus: 'settlement',
        paymentMethod: _selectedMethod,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Tampilkan payment screen sesuai metode
      if (_isVA) {
        final vaNumber = _generateVANumber(_selectedMethod);
        final methodName = _methods
            .firstWhere((m) => m.$1 == _selectedMethod)
            .$2;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VAPaymentScreen(
              vaNumber: vaNumber,
              bankName: methodName,
              totalPrice: widget.totalPrice,
              bookingId: bookingId,
              destination: widget.destination,
              checkIn: widget.checkIn,
              checkOut: widget.checkOut,
            ),
          ),
        );
      } else if (_isEWallet) {
        final qrCode = _generateQRCode(_selectedMethod);
        final methodName = _methods
            .firstWhere((m) => m.$1 == _selectedMethod)
            .$2;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EWalletPaymentScreen(
              qrCode: qrCode,
              walletName: methodName,
              totalPrice: widget.totalPrice,
              bookingId: bookingId,
              destination: widget.destination,
              checkIn: widget.checkIn,
              checkOut: widget.checkOut,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking gagal: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF5350),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
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
                    'Konfirmasi Pemesanan',
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
                  children: [
                    // Destination card
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            child: SizedBox(
                              width: 100,
                              height: 100,
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
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Color(0xFFFFD700),
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${widget.destination.rating}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        ' (${widget.destination.reviewCount} reviews)',
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 11,
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
                    const SizedBox(height: 20),

                    // Booking details
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Pemesanan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ConfirmRow('Check-in', _formatDate(widget.checkIn)),
                          const SizedBox(height: 12),
                          _ConfirmRow(
                            'Check-out',
                            _formatDate(widget.checkOut),
                          ),
                          const SizedBox(height: 12),
                          _ConfirmRow(
                            'Durasi',
                            '$_nights night${_nights > 1 ? 's' : ''}',
                          ),
                          const SizedBox(height: 12),
                          _ConfirmRow(
                            'Tamu',
                            '${widget.guests} person${widget.guests > 1 ? 's' : ''}',
                          ),
                          if (widget.notes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _ConfirmRow('Notes', widget.notes),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(color: Colors.white12),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Harga per malam',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                rupiahFormat.format(
                                  widget.destination.pricePerNight,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                rupiahFormat.format(widget.totalPrice),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.25),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Konfirmasi booking akan dikirim ke email kamu. Status booking bisa dicek di tab Bookings.',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Metode Pembayaran
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Metode Pembayaran',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._methods.map(
                            (m) => GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedMethod = m.$1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedMethod == m.$1
                                      ? AppColors.primary.withOpacity(0.1)
                                      : Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedMethod == m.$1
                                        ? AppColors.primary.withOpacity(0.6)
                                        : Colors.white.withOpacity(0.08),
                                    width: _selectedMethod == m.$1 ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: m.$4,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          m.$5,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.$2,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            m.$3,
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _selectedMethod == m.$1
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: _selectedMethod == m.$1
                                              ? AppColors.primary
                                              : Colors.white30,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: _selectedMethod == m.$1
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 13,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Confirm button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
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
              child: GestureDetector(
                onTap: _isLoading ? null : _confirmBooking,
                child: Container(
                  height: 54,
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
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Konfirmasi Pemesanan',
                            style: TextStyle(
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
    );
  }
}

// ═════════════════════════════════════════
// STEP 2B — VA PAYMENT SCREEN
// ═════════════════════════════════════════
class VAPaymentScreen extends StatefulWidget {
  final String vaNumber;
  final String bankName;
  final double totalPrice;
  final String bookingId;
  final Destination destination;
  final DateTime checkIn;
  final DateTime checkOut;

  const VAPaymentScreen({
    super.key,
    required this.vaNumber,
    required this.bankName,
    required this.totalPrice,
    required this.bookingId,
    required this.destination,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  State<VAPaymentScreen> createState() => _VAPaymentScreenState();
}

class _VAPaymentScreenState extends State<VAPaymentScreen> {
  bool _copied = false;

  void _copyVA() {
    Clipboard.setData(ClipboardData(text: widget.vaNumber));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
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
                  Text(
                    'Bayar via ${widget.bankName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Info card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // Bank icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.bankName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Nomor Virtual Account',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // VA Number
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.vaNumber,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _copyVA,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _copied
                                          ? const Color(0xFF4CAF50)
                                          : AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _copied ? 'Tersalin!' : 'Salin',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pembayaran',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                rupiahFormat.format(widget.totalPrice),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Cara bayar
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cara Pembayaran',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _StepItem(
                            '1',
                            'Buka aplikasi ${widget.bankName} atau ATM',
                          ),
                          _StepItem(
                            '2',
                            'Pilih menu Transfer / Virtual Account',
                          ),
                          _StepItem('3', 'Masukkan nomor VA di atas'),
                          _StepItem(
                            '4',
                            'Pastikan nominal sesuai: ${rupiahFormat.format(widget.totalPrice)}',
                          ),
                          _StepItem(
                            '5',
                            'Konfirmasi dan selesaikan pembayaran',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Warning
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFFB300).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Color(0xFFFFB300),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Selesaikan pembayaran dalam 24 jam. Booking akan otomatis dibatalkan jika tidak dibayar.',
                              style: TextStyle(
                                color: Color(0xFFFFB300),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Sudah Bayar button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
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
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingSuccessScreen(
                          destination: widget.destination,
                          checkIn: widget.checkIn,
                          checkOut: widget.checkOut,
                          totalPrice: widget.totalPrice,
                        ),
                      ),
                      (route) => route.isFirst,
                    ),
                    child: Container(
                      height: 54,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryLight, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.primaryShadow,
                      ),
                      child: const Center(
                        child: Text(
                          'Saya Sudah Bayar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    child: const Text(
                      'Bayar Nanti',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
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

// ═════════════════════════════════════════
// STEP 2C — E-WALLET PAYMENT SCREEN
// ═════════════════════════════════════════
class EWalletPaymentScreen extends StatelessWidget {
  final String qrCode;
  final String walletName;
  final double totalPrice;
  final String bookingId;
  final Destination destination;
  final DateTime checkIn;
  final DateTime checkOut;

  const EWalletPaymentScreen({
    super.key,
    required this.qrCode,
    required this.walletName,
    required this.totalPrice,
    required this.bookingId,
    required this.destination,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
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
                  Text(
                    'Bayar via $walletName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            walletName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Scan QR Code untuk membayar',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // QR Code simulasi
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.qr_code_2,
                                    size: 120,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    walletName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pembayaran',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                rupiahFormat.format(totalPrice),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFFB300).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Color(0xFFFFB300),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'QR Code berlaku selama 15 menit. Segera scan sebelum kadaluarsa.',
                              style: TextStyle(
                                color: Color(0xFFFFB300),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
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
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingSuccessScreen(
                          destination: destination,
                          checkIn: checkIn,
                          checkOut: checkOut,
                          totalPrice: totalPrice,
                        ),
                      ),
                      (route) => route.isFirst,
                    ),
                    child: Container(
                      height: 54,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryLight, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.primaryShadow,
                      ),
                      child: const Center(
                        child: Text(
                          'Saya Sudah Bayar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    child: const Text(
                      'Bayar Nanti',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
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

// ═════════════════════════════════════════
// STEP 3 — BOOKING SUCCESS SCREEN
// ═════════════════════════════════════════
class BookingSuccessScreen extends StatelessWidget {
  final Destination destination;
  final DateTime checkIn;
  final DateTime checkOut;
  final double totalPrice;

  const BookingSuccessScreen({
    super.key,
    required this.destination,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
  });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),

              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF4CAF50),
                  size: 52,
                ),
              ),

              const SizedBox(height: 24),

              // FIX: tambah textAlign center dan kurangi fontSize
              const Text(
                'Pemesanan Dikonfirmasi!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Email konfirmasi telah dikirim.\nCek inbox kamu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 28),

              // Booking summary card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Image.network(
                          destination.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      destination.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.country,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryItem('Check-in', _formatDate(checkIn)),
                        Container(width: 1, height: 30, color: Colors.white12),
                        _SummaryItem('Check-out', _formatDate(checkOut)),
                        Container(width: 1, height: 30, color: Colors.white12),
                        _SummaryItem(
                          'Total',
                          rupiahFormat.format(totalPrice),
                          valueColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: Container(
                  height: 54,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.primaryShadow,
                  ),
                  child: const Center(
                    child: Text(
                      'Lihat Pemesananku',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Kembali ke Jelajahi',
                      style: TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────
class _StepItem extends StatelessWidget {
  final String number;
  final String text;
  const _StepItem(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _DatePickerCard extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DatePickerCard({
    required this.label,
    required this.date,
    required this.onTap,
  });

  String _format(DateTime d) {
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
    return '${d.day} ${months[d.month]}\n${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: date != null
                ? AppColors.primary.withOpacity(0.5)
                : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: date != null ? AppColors.primary : Colors.white24,
                  size: 15,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null ? _format(date!) : 'Select',
                  style: TextStyle(
                    color: date != null ? Colors.white : Colors.white38,
                    fontSize: 13,
                    fontWeight: date != null
                        ? FontWeight.w600
                        : FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColors.primary, size: 16),
    ),
  );
}

class _ConfirmRow extends StatelessWidget {
  final String label, value;
  const _ConfirmRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      const SizedBox(width: 16),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _SummaryItem(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          color: valueColor ?? Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
