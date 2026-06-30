import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentRecord {
  final String id;
  final String planTier;
  final double amountInr;
  final DateTime date;
  final bool isSuccessful;
  final String? transactionId;
  final bool isAutopay;
  final DateTime? nextAutopayDate;

  const PaymentRecord({
    required this.id,
    required this.planTier,
    required this.amountInr,
    required this.date,
    this.isSuccessful = true,
    this.transactionId,
    this.isAutopay = false,
    this.nextAutopayDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'planTier': planTier,
        'amountInr': amountInr,
        'date': date.toIso8601String(),
        'isSuccessful': isSuccessful,
        'transactionId': transactionId,
        'isAutopay': isAutopay,
        'nextAutopayDate': nextAutopayDate?.toIso8601String(),
      };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        id: json['id'] ?? '',
        planTier: json['planTier'] ?? '',
        amountInr: (json['amountInr'] ?? 0).toDouble(),
        date: DateTime.parse(json['date']),
        isSuccessful: json['isSuccessful'] ?? true,
        transactionId: json['transactionId'],
        isAutopay: json['isAutopay'] ?? false,
        nextAutopayDate: json['nextAutopayDate'] != null
            ? DateTime.parse(json['nextAutopayDate'])
            : null,
      );
}

class AutopayConfig {
  final bool enabled;
  final DateTime? nextPaymentDate;
  final String? planTier;
  final double? amount;
  final int daysBeforeNotify;

  const AutopayConfig({
    this.enabled = false,
    this.nextPaymentDate,
    this.planTier,
    this.amount,
    this.daysBeforeNotify = 7,
  });

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'nextPaymentDate': nextPaymentDate?.toIso8601String(),
        'planTier': planTier,
        'amount': amount,
        'daysBeforeNotify': daysBeforeNotify,
      };

  factory AutopayConfig.fromJson(Map<String, dynamic> json) =>
      AutopayConfig(
        enabled: json['enabled'] ?? false,
        nextPaymentDate: json['nextPaymentDate'] != null
            ? DateTime.parse(json['nextPaymentDate'])
            : null,
        planTier: json['planTier'],
        amount: json['amount']?.toDouble(),
        daysBeforeNotify: json['daysBeforeNotify'] ?? 7,
      );

  bool get shouldNotifyNow {
    if (!enabled || nextPaymentDate == null) return false;
    final daysUntil = nextPaymentDate!.difference(DateTime.now()).inDays;
    return daysUntil <= daysBeforeNotify && daysUntil >= 0;
  }

  int get daysUntilPayment {
    if (nextPaymentDate == null) return -1;
    return nextPaymentDate!.difference(DateTime.now()).inDays;
  }

  AutopayConfig copyWith({
    bool? enabled,
    DateTime? nextPaymentDate,
    String? planTier,
    double? amount,
    int? daysBeforeNotify,
  }) =>
      AutopayConfig(
        enabled: enabled ?? this.enabled,
        nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
        planTier: planTier ?? this.planTier,
        amount: amount ?? this.amount,
        daysBeforeNotify: daysBeforeNotify ?? this.daysBeforeNotify,
      );
}

class PaymentService {
  static final PaymentService _instance = PaymentService._();
  factory PaymentService() => _instance;
  PaymentService._();

  // UPI configuration
  static const upiId = 'metherobin@oksbi';
  static const payeeName = 'ContentOS';
  static const merchantCode = 'COS001';

  List<PaymentRecord> _history = [];
  AutopayConfig _autopay = const AutopayConfig();

  List<PaymentRecord> get history => List.unmodifiable(_history);
  AutopayConfig get autopay => _autopay;

  static const _historyKey = 'payment_history';
  static const _autopayKey = 'autopay_config';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      try {
        final list = jsonDecode(historyJson) as List;
        _history = list.map((e) => PaymentRecord.fromJson(e)).toList();
      } catch (_) {
        _history = [];
      }
    }

    final autopayJson = prefs.getString(_autopayKey);
    if (autopayJson != null) {
      try {
        _autopay = AutopayConfig.fromJson(jsonDecode(autopayJson));
      } catch (_) {
        _autopay = const AutopayConfig();
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _history.map((r) => r.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(historyJson));
    await prefs.setString(_autopayKey, jsonEncode(_autopay.toJson()));
  }

  // Generate UPI payment URI
  String generateUpiUri({
    required double amount,
    required String planTier,
    String? transactionNote,
  }) {
    final note = transactionNote ?? 'ContentOS $planTier Plan';
    return 'upi://pay?pa=$upiId&pn=$payeeName&am=${amount.toStringAsFixed(0)}&cu=INR&tn=${Uri.encodeComponent(note)}&mc=$merchantCode';
  }

  // Generate QR code data (UPI URI string)
  String generateQrData({
    required double amount,
    required String planTier,
  }) {
    return generateUpiUri(amount: amount, planTier: planTier);
  }

  // Record a payment
  Future<void> recordPayment({
    required String planTier,
    required double amount,
    String? transactionId,
    bool isAutopay = false,
  }) async {
    final record = PaymentRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      planTier: planTier,
      amountInr: amount,
      date: DateTime.now(),
      isSuccessful: true,
      transactionId: transactionId,
      isAutopay: isAutopay,
      nextAutopayDate: isAutopay
          ? DateTime.now().add(const Duration(days: 30))
          : null,
    );
    _history.insert(0, record);
    await _save();
  }

  // Enable/disable autopay
  Future<void> configureAutopay({
    required bool enabled,
    String? planTier,
    double? amount,
  }) async {
    if (enabled) {
      _autopay = AutopayConfig(
        enabled: true,
        nextPaymentDate: DateTime.now().add(const Duration(days: 30)),
        planTier: planTier,
        amount: amount,
        daysBeforeNotify: 7,
      );
    } else {
      _autopay = const AutopayConfig();
    }
    await _save();
  }

  // Check if autopay notification should be shown
  bool get shouldShowAutopayNotification => _autopay.shouldNotifyNow;
  int get daysUntilAutopay => _autopay.daysUntilPayment;
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});
