import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milk_app/models/milk_record_model.dart';
import 'package:milk_app/models/payment_model.dart';
import 'package:milk_app/services/milk_record_service.dart';
import 'package:milk_app/services/payment_service.dart';

class FinancesProvider extends ChangeNotifier {
  final MilkService _milkService = MilkService();
  final PaymentService _paymentService = PaymentService();

  final String familyId;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  Map<String, MilkRecordModel> _milkByDate = {};
  List<PaymentModel> _payments = [];
  List<DateTime?> _selectedRange = [];
  bool _loading = true;
  String? _error;

  StreamSubscription? _milkSub;
  StreamSubscription? _paymentSub;

  // ── Getters ──────────────────────────────────────────────────────────────

  Map<String, MilkRecordModel> get milkByDate => _milkByDate;
  List<PaymentModel> get payments => _payments;
  List<DateTime?> get selectedRange => _selectedRange;
  bool get loading => _loading;
  String? get error => _error;

  FinancesProvider({required this.familyId}) {
    _loadData();
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  double get litersInRange {
    if (_selectedRange.length < 2) return 0;
    final from = _selectedRange.first;
    final to = _selectedRange.last;
    if (from == null || to == null) return 0;
    return _milkByDate.values
        .where((r) => !r.milkDate.isBefore(from) && !r.milkDate.isAfter(to))
        .fold(0.0, (sum, r) => sum + r.milkLiters);
  }

  double get totalCobradoMes {
    final now = DateTime.now();
    return _payments
        .where((p) =>
            p.createdAt.month == now.month && p.createdAt.year == now.year)
        .fold(0.0, (sum, p) => sum + p.totalAmount);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool dateInAnyPayment(DateTime date) => _payments.any(
      (p) => !date.isBefore(p.dateFrom) && !date.isAfter(p.dateTo));

  // ── Acciones ──────────────────────────────────────────────────────────────

  void setSelectedRange(List<DateTime?> range) {
    _selectedRange = range;
    notifyListeners();
  }

  void clearSelectedRange() {
    _selectedRange = [];
    notifyListeners();
  }

  Future<void> addPayment({
    required DateTime from,
    required DateTime to,
    required double pricePerLiter,
  }) async {
    if (_userId == null) throw Exception('Usuario no autenticado');

    final liters = litersInRange;
    if (liters <= 0) throw Exception('No hay litros registrados en ese rango');
    if (pricePerLiter <= 0) throw Exception('El precio debe ser mayor a 0');

    final payment = PaymentModel(
      paymentId: DateTime.now().millisecondsSinceEpoch.toString(),
      dateFrom: from,
      dateTo: to,
      totalLiters: liters,
      pricePerLiter: pricePerLiter,
      totalAmount: liters * pricePerLiter,
      createdAt: DateTime.now(),
    );

    await _paymentService.addPayment(_userId, familyId, payment);
    clearSelectedRange();
  }

  Future<void> deletePayment(String paymentId) async {
    if (_userId == null) throw Exception('Usuario no autenticado');
    await _paymentService.deletePayment(_userId, familyId, paymentId);
  }

  // ── Carga de datos ────────────────────────────────────────────────────────

  void _loadData() {
    if (_userId == null) {
      _error = 'Usuario no autenticado';
      _loading = false;
      notifyListeners();
      return;
    }

    _milkSub = _milkService
        .getMilkRecords(_userId, familyId)
        .listen(
          (records) {
            _milkByDate = {for (var r in records) dateKey(r.milkDate): r};
            _loading = false;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            _error = 'Error al cargar registros de leche';
            _loading = false;
            notifyListeners();
          },
        );

    _paymentSub = _paymentService
        .getPayments(_userId, familyId)
        .listen(
          (payments) {
            _payments = payments;
            notifyListeners();
          },
          onError: (e) {
            _error = 'Error al cargar cortes';
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _milkSub?.cancel();
    _paymentSub?.cancel();
    super.dispose();
  }
}