import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milk_app/models/family_milk_model.dart';
import 'package:milk_app/models/milk_record_model.dart';
import 'package:milk_app/services/family_management_service.dart';
import 'package:milk_app/services/milk_record_service.dart';

class HomeProvider extends ChangeNotifier {
  final MilkService _milkService = MilkService();
  final FamilyService _familyService = FamilyService();

  List<FamilyMilkModel> _families = [];
  FamilyMilkModel? _selectedFamily;
  List<MilkRecordModel> _records = [];
  StreamSubscription? _subscription;
  bool _loadingFamilies = true;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<FamilyMilkModel> get families => _families;
  FamilyMilkModel? get selectedFamily => _selectedFamily;
  List<MilkRecordModel> get records => _records;
  bool get loadingFamilies => _loadingFamilies;

  // ── Stats calculadas ─────────────────────────────────────────────────────

  double get totalMes {
    final now = DateTime.now();
    return _records
        .where((r) =>
            r.milkDate.month == now.month && r.milkDate.year == now.year)
        .fold(0.0, (sum, r) => sum + r.milkLiters);
  }

  double get litrosHoy {
    final now = DateTime.now();
    return _records
        .where((r) =>
            r.milkDate.day == now.day &&
            r.milkDate.month == now.month &&
            r.milkDate.year == now.year)
        .fold(0.0, (sum, r) => sum + r.milkLiters);
  }

  double get monthlyAverage {
    final now = DateTime.now();
    final delMes = _records
        .where((r) =>
            r.milkDate.month == now.month && r.milkDate.year == now.year)
        .toList();
    if (delMes.isEmpty) return 0;
    return totalMes / delMes.length;
  }

  // ── Métodos ──────────────────────────────────────────────────────────────

  Future<void> loadFamilies() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _loadingFamilies = false;
      notifyListeners();
      return;
    }

    final families = await _familyService.getFamiliesOnce(user.uid);
    _families = families;
    _loadingFamilies = false;
    notifyListeners();

    if (families.isNotEmpty) selectFamily(families.first);
  }

  void selectFamily(FamilyMilkModel family) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _subscription?.cancel();
    _selectedFamily = family;
    _records = [];
    notifyListeners();

    _subscription = _milkService
        .getMilkRecords(user.uid, family.familyId)
        .listen((records) {
      _records = records;
      notifyListeners();
    });
  }

  // Recarga las familias (útil al volver de FamilyManagementPage)
  Future<void> reloadFamilies() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _families = await _familyService.getFamiliesOnce(user.uid);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}