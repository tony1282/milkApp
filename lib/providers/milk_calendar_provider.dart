import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milk_app/models/milk_record_model.dart';
import 'package:milk_app/services/milk_record_service.dart';

class MilkCalendarProvider extends ChangeNotifier {
  final MilkService _milkService = MilkService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  final String familyId;

  Map<String, MilkRecordModel> _recordsByDate = {};
  List<DateTime?> _selectedDate = [];
  StreamSubscription? _sub;
  bool _loading = true;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────────────────

  Map<String, MilkRecordModel> get recordsByDate => _recordsByDate;
  List<DateTime?> get selectedDate => _selectedDate;
  bool get loading => _loading;
  String? get error => _error;

  // ── Stats ─────────────────────────────────────────────────────────────────

  double get totalMes {
    final now = DateTime.now();
    return _recordsByDate.values
        .where((r) =>
            r.milkDate.month == now.month && r.milkDate.year == now.year)
        .fold(0.0, (sum, r) => sum + r.milkLiters);
  }

  double get promedioMes {
    final now = DateTime.now();
    final del = _recordsByDate.values.where(
        (r) => r.milkDate.month == now.month && r.milkDate.year == now.year);
    if (del.isEmpty) return 0;
    return totalMes / del.length;
  }

  String get litrosHoyLabel {
    final key = dateKey(DateTime.now());
    final r = _recordsByDate[key];
    return r != null ? '${r.milkLiters}L' : '--';
  }

  int get totalRegistros => _recordsByDate.length;

  // ── Helpers ───────────────────────────────────────────────────────────────

  String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  MilkRecordModel? recordForDate(DateTime d) => _recordsByDate[dateKey(d)];

  // ── Constructor ───────────────────────────────────────────────────────────

  MilkCalendarProvider({required this.familyId}) {
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
    required double liters,
  }) async {
    if (_userId == null) throw Exception('Usuario no autenticado');
    if (liters <= 0) throw Exception('Los litros deben ser mayores a 0');
    if (liters > 9999) throw Exception('Valor demasiado alto');

    final record = MilkRecordModel(
      milkId: DateTime.now().millisecondsSinceEpoch.toString(),
      milkLiters: liters,
      milkDate: date,
    );
    await _milkService.addMilkRecord(_userId, familyId, record);
  }

  Future<void> updateRecord({
    required MilkRecordModel original,
    required double liters,
  }) async {
    if (_userId == null) throw Exception('Usuario no autenticado');
    if (liters <= 0) throw Exception('Los litros deben ser mayores a 0');
    if (liters > 9999) throw Exception('Valor demasiado alto');

    final updated = MilkRecordModel(
      milkId: original.milkId,
      milkLiters: liters,
      milkDate: original.milkDate,
    );
    await _milkService.updateMilkRecord(_userId, familyId, updated);
  }

  Future<void> deleteRecord(String milkId) async {
    if (_userId == null) throw Exception('Usuario no autenticado');
    await _milkService.deleteMilkRecord(_userId, familyId, milkId);
  }

  // ── Carga ─────────────────────────────────────────────────────────────────

  void _loadData() {
    if (_userId == null) {
      _error = 'Usuario no autenticado';
      _loading = false;
      notifyListeners();
      return;
    }

    _sub = _milkService.getMilkRecords(_userId, familyId).listen(
      (records) {
        _recordsByDate = {for (var r in records) dateKey(r.milkDate): r};
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