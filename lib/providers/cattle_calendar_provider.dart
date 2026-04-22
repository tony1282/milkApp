import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milk_app/models/cattle_feed_model.dart';
import 'package:milk_app/services/cattle_feed_service.dart';

class CattleCalendarProvider extends ChangeNotifier {
  final CattleFeedService _cattleService = CattleFeedService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  final String familyId;

  Map<String, CattleFeedModel> _recordsByDate = {};
  List<DateTime?> _selectedDate = [];
  StreamSubscription? _sub;
  bool _loading = true;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────────────────

  Map<String, CattleFeedModel> get recordsByDate => _recordsByDate;
  List<DateTime?> get selectedDate => _selectedDate;
  bool get loading => _loading;
  String? get error => _error;

  // ── Stats ─────────────────────────────────────────────────────────────────

  double get totalMes {
    final now = DateTime.now();
    return _recordsByDate.values
        .where((r) =>
            r.cattleDate.month == now.month && r.cattleDate.year == now.year)
        .fold(0.0, (sum, r) => sum + r.cattlePrice);
  }

  double get promedioMes {
    final now = DateTime.now();
    final del = _recordsByDate.values.where((r) =>
        r.cattleDate.month == now.month && r.cattleDate.year == now.year);
    if (del.isEmpty) return 0;
    return totalMes / del.length;
  }

  String get precioHoyLabel {
    final key = dateKey(DateTime.now());
    final r = _recordsByDate[key];
    return r != null ? '\$${r.cattlePrice.toStringAsFixed(1)}' : '--';
  }

  int get totalRegistros => _recordsByDate.length;

  // ── Helpers ───────────────────────────────────────────────────────────────

  String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  CattleFeedModel? recordForDate(DateTime d) => _recordsByDate[dateKey(d)];

  // ── Constructor ───────────────────────────────────────────────────────────

  CattleCalendarProvider({required this.familyId}) {
    _loadData();
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

  void setSelectedDate(List<DateTime?> dates) {
    _selectedDate = dates;
    notifyListeners();
  }

  void clearSelection() {
    _selectedDate = [];
    notifyListeners();
  }

  Future<void> addRecord({
    required DateTime date,
    required String name,
    required double price,
  }) async {
    if (_userId == null) throw Exception('Usuario no autenticado');
    if (name.trim().isEmpty) throw Exception('El nombre no puede estar vacío');
    if (price <= 0) throw Exception('El precio debe ser mayor a 0');

    final record = CattleFeedModel(
      cattleId: DateTime.now().millisecondsSinceEpoch.toString(),
      cattleName: name.trim(),
      cattlePrice: price,
      cattleDate: date,
    );
    await _cattleService.addCattleFeed(_userId, familyId, record);
  }

  Future<void> updateRecord({
    required CattleFeedModel original,
    required String name,
    required double price,
  }) async {
    if (_userId == null) throw Exception('Usuario no autenticado');
    if (name.trim().isEmpty) throw Exception('El nombre no puede estar vacío');
    if (price <= 0) throw Exception('El precio debe ser mayor a 0');

    final updated = CattleFeedModel(
      cattleId: original.cattleId,
      cattleName: name.trim(),
      cattlePrice: price,
      cattleDate: original.cattleDate,
    );
    await _cattleService.updateCattleFeed(_userId, familyId, updated);
  }

  Future<void> deleteRecord(String cattleId) async {
    if (_userId == null) throw Exception('Usuario no autenticado');
    await _cattleService.deleteCattleFeed(_userId, familyId, cattleId);
  }

  // ── Carga ─────────────────────────────────────────────────────────────────

  void _loadData() {
    if (_userId == null) {
      _error = 'Usuario no autenticado';
      _loading = false;
      notifyListeners();
      return;
    }

    _sub = _cattleService.getCattleFeed(_userId, familyId).listen(
      (records) {
        _recordsByDate = {
          for (var r in records) dateKey(r.cattleDate): r
        };
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Error al cargar registros';
        _loading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}