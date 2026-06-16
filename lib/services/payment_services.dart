import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PaymentService {
  // ── Midtrans Keys dari .env ──
  static String get _serverKey => dotenv.env['MIDTRANS_SERVER_KEY'] ?? '';
  static String get _clientKey => dotenv.env['MIDTRANS_CLIENT_KEY'] ?? '';
  static const String _baseUrl = 'https://app.sandbox.midtrans.com/snap/v1';
  static const String _statusUrl = 'https://api.sandbox.midtrans.com/v2';

  static String? get _userId => supabase.auth.currentUser?.id;

  // ── Buat transaksi Midtrans + simpan ke tabel payments ──
  static Future<Map<String, String>> createTransaction({
    required String bookingId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String itemName,
    String? paymentMethod,
  }) async {
    final idrAmount = amount.toInt();

    final orderId =
        'LT-${bookingId.substring(0, 8).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

    final credentials = base64Encode(utf8.encode('$_serverKey:'));

    // Build body
    final body = <String, dynamic>{
      'transaction_details': {'order_id': orderId, 'gross_amount': idrAmount},
      'customer_details': {'first_name': customerName, 'email': customerEmail},
      'item_details': [
        {'id': bookingId, 'price': idrAmount, 'quantity': 1, 'name': itemName},
      ],
    };

    // Set metode pembayaran
    if (paymentMethod != null) {
      body['enabled_payments'] = [paymentMethod];
    } else {
      body['enabled_payments'] = [
        'gopay',
        'shopeepay',
        'bank_transfer',
        'credit_card',
        'bca_va',
        'bni_va',
        'bri_va',
        'mandiri_va',
        'permata_va',
        'dana',
        'ovo',
      ];
    }

    // ── HTTP request ke Midtrans ──
    final response = await http.post(
      Uri.parse('$_baseUrl/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $credentials',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal membuat transaksi: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Simpan ke tabel payments
    await _savePayment(
      bookingId: bookingId,
      orderId: orderId,
      idrAmount: idrAmount,
      midtransData: data,
    );

    return {
      'order_id': orderId,
      'redirect_url': data['redirect_url'] as String? ?? '',
      'token': data['token'] as String? ?? '',
    };
  }

  // ── Simpan data payment ke Supabase ──
  static Future<void> _savePayment({
    required String bookingId,
    required String orderId,
    required int idrAmount,
    required Map<String, dynamic> midtransData,
  }) async {
    if (_userId == null) return;
    await supabase.from('payments').insert({
      'booking_id': bookingId,
      'user_id': _userId,
      'order_id': orderId,
      'amount': idrAmount,
      'status': 'pending',
      'midtrans_data': midtransData,
    });
  }

  // ── Update status payment setelah callback ──
  static Future<void> updatePaymentStatus({
    required String orderId,
    required String status,
    String? paymentMethod,
  }) async {
    await supabase
        .from('payments')
        .update({
          'status': status,
          if (paymentMethod != null) 'payment_method': paymentMethod,
          if (status == 'settlement' || status == 'capture')
            'paid_at': DateTime.now().toIso8601String(),
        })
        .eq('order_id', orderId);
  }

  // ── Cek status dari Midtrans ──
  static Future<Map<String, dynamic>> checkStatus(String orderId) async {
    final credentials = base64Encode(utf8.encode('$_serverKey:'));
    final response = await http.get(
      Uri.parse('$_statusUrl/$orderId/status'),
      headers: {'Authorization': 'Basic $credentials'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return {'transaction_status': 'unknown'};
  }

  // ── Handle hasil pembayaran — update booking + payment serentak ──
  static Future<void> handlePaymentResult({
    required String bookingId,
    required String orderId,
    required String paymentStatus,
    String? paymentMethod,
  }) async {
    String bookingStatus;
    switch (paymentStatus) {
      case 'settlement':
      case 'capture':
        bookingStatus = 'confirmed';
        break;
      case 'cancel':
      case 'deny':
      case 'expire':
        bookingStatus = 'cancelled';
        break;
      default:
        bookingStatus = 'pending';
    }

    await Future.wait([
      supabase
          .from('bookings')
          .update({'status': bookingStatus})
          .eq('id', bookingId),
      updatePaymentStatus(
        orderId: orderId,
        status: paymentStatus,
        paymentMethod: paymentMethod,
      ),
    ]);
  }

  // ── Riwayat pembayaran user ──
  static Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    if (_userId == null) return [];
    final data = await supabase
        .from('payments')
        .select('*, bookings(*, destinations(name, cover_image_url))')
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static String get clientKey => _clientKey;
}
