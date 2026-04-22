import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milk_app/models/cattle_feed_model.dart';
import 'package:milk_app/services/cattle_feed_service.dart';

class CattleFinancesProvider extends ChangeNotifier {
  final CattleFeedService _cattleService = CattleFeedService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  final String familyId;

  List<CattleFeedModel> _records = [];
  StreamSubscription? _sub;
  bool _loading = true;
  String? _error;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // ── Getters básicos ───────────────────────────────────────────────────────

  List<CattleFeedModel> get records => _records;
  bool get loading => _loading;
  String? get error => _error;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  bool get isCurrentMonth =>
      _selectedMonth == DateTime.now().month &&
      _selectedYear == DateTime.now().year;

  // ── Computed ──────────────────────────────────────────────────────────────

  List<CattleFeedModel> get recordsDelMes => _records
      .where((r) =>
          r.cattleDate.month == _selectedMonth &&
          r.cattleDate.year == _selectedYear)
      .toList()
    ..sort((a, b) => b.cattleDate.compareTo(a.cattleDate));

  double get totalMes =>
      recordsDelMes.fold(0.0, (sum, r) => sum + r.cattlePrice);

  double get promedioMes {
    if (recordsDelMes.isEmpty) return 0;
    return totalMes / recordsDelMes.length;
  }

  CattleFeedModel? get masCaroMes {
    if (recordsDelMes.isEmpty) return null;
    return recordsDelMes
        .reduce((a, b) => a.cattlePrice > b.cattlePrice ? a : b);
  }

  Map<String, double> get porAlimento {
    final Map<String, double> map = {};
    for (final r in recordsDelMes) {
      map[r.cattleName] = (map[r.cattleName] ?? 0) + r.cattlePrice;
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Map<String, double> get ultimos6Meses {
    final now = DateTime.now();
    final Map<String, double> map = {};
    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}';
      map[key] = 0;
    }
    for (final r in _records) {
      final key =
          '${r.cattleDate.year}-${r.cattleDate.month.toString().padLeft(2, '00')}';
      if (map.containsKey(key)) {
        map[key] = map[key]! + r.cattlePrice;
      }
    }
    return map;
  }

  // ── Constructor ───────────────────────────────────────────────────────────

  CattleFinancesProvider({required this.familyId}) {
    _loadData();
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

  void prevMonth() {
    if (_selectedMonth == 1) {
      _selectedMonth = 12;
      _selectedYear--;
    } else {
      _selectedMonth--;
    }
    notifyListeners();
  }

  void nextMonth() {
    if (isCurrentMonth) return;
    if (_selectedMonth == 12) {
      _selectedMonth = 1;
      _selectedYear++;
    } else {
      _selectedMonth++;
    }
    notifyListeners();
  }

  // ── Carga de datos ────────────────────────────────────────────────────────

  void _loadData() {
    if (_userId == null) {
      _error = 'Usuario no autenticado';
      _loading = false;
      notifyListeners();
      return;
    }

    _sub = _cattleService
        .getCattleFeed(_userId, familyId)
        .listen(
          (records) {
            _records = records;
            _loading = false;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            _error = 'Error al cargar registros de alimento';
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