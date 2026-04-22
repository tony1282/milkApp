import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milk_app/models/family_milk_model.dart';
import 'package:milk_app/pages/cattle_feed_calendar.dart';
import 'package:milk_app/pages/cattle_finances_page.dart';
import 'package:milk_app/pages/finance_milk_page.dart';
import 'package:milk_app/providers/home_provider.dart';
import 'package:milk_app/services/family_management_service.dart';
import 'package:milk_app/widgets/chart.dart';
import 'package:milk_app/widgets/home/family_picker_sheet.dart';
import 'package:milk_app/widgets/home/hero_banner.dart';
import 'package:milk_app/widgets/home/home_drawer.dart';
import 'package:milk_app/widgets/home/home_empty_state.dart';
import 'package:milk_app/widgets/home/quick_access_grid.dart';
import 'family_management_page.dart';
import 'milk_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeProvider _provider = HomeProvider();

  @override
  void initState() {
    super.initState();
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
    _provider.loadFamilies();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  // ── Navegación con picker de familia ─────────────────────────────────────

  Future<void> _navigate({
    required Widget Function(String familyId) builder,
    bool closeDrawer = false,
  }) async {
    if (closeDrawer) Navigator.pop(context);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final families =
        await FamilyService().getFamiliesOnce(user.uid);
    if (!mounted) return;

    if (families.length == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => builder(families.first.familyId)));
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Selecciona una familia',
            style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: families.length,
            itemBuilder: (context, index) {
              final familia = families[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Text(familia.familyName[0].toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF3D52A0),
                          fontWeight: FontWeight.w700)),
                ),
                title: Text(familia.familyName),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => builder(familia.familyId)));
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFamilyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FamilyPickerSheet(
        families: _provider.families,
        selectedFamily: _provider.selectedFamily,
        onSelect: _provider.selectFamily,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FF),
      drawer: HomeDrawer(
        onFamilies: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const FamilyManagementPage()),
          ).then((_) => _provider.reloadFamilies());
        },
        onMilkCalendar: () => _navigate(
          closeDrawer: true,
          builder: (id) => MilkCalendar(familyId: id),
        ),
        onMilkFinances: () => _navigate(
          closeDrawer: true,
          builder: (id) => FinancesPage(familyId: id),
        ),
        onCattleCalendar: () => _navigate(
          closeDrawer: true,
          builder: (id) => CattleFeedCalendar(familyId: id),
        ),
        onCattleFinances: () => _navigate(
          closeDrawer: true,
          builder: (id) => CattleFinancesPage(familyId: id),
        ),
        onSettings: () {},
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D52A0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: _provider.selectedFamily != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.group_rounded,
                      size: 16, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    _provider.selectedFamily!.familyName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : const Text('Milk App',
                style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          if (_provider.families.length > 1)
            IconButton(
              onPressed: _showFamilyPicker,
              icon: const Icon(Icons.swap_horiz_rounded),
              tooltip: 'Cambiar familia',
            ),
        ],
      ),
      floatingActionButton: _provider.families.length > 1
          ? FloatingActionButton.extended(
              onPressed: _showFamilyPicker,
              backgroundColor: const Color(0xFF3D52A0),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.group_rounded),
              label: Text(
                _provider.selectedFamily?.familyName ?? 'Familia',
                style:
                    const TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
      body: _provider.loadingFamilies
          ? const Center(child: CircularProgressIndicator())
          : _provider.families.isEmpty
              ? const HomeEmptyState()
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      MediaQuery.of(context).padding.bottom + 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Banner hero ────────────────────────────────
                      HeroBanner(
                        litrosHoy: _provider.litrosHoy,
                        totalMes: _provider.totalMes,
                        monthlyAverage: _provider.monthlyAverage,
                      ),

                      const SizedBox(height: 24),

                      // ── Accesos rápidos ────────────────────────────
                      const Text('Accesos rápidos',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      QuickAccessGrid(
                        onMilkTap: () => _navigate(
                          builder: (id) => MilkCalendar(familyId: id),
                        ),
                        onFeedTap: () => _navigate(
                          builder: (id) =>
                              CattleFeedCalendar(familyId: id),
                        ),
                        onFinancesMilkTap: () => _navigate(
                          builder: (id) => FinancesPage(familyId: id),
                        ),
                        onFinancesFeedTap: () => _navigate(
                          builder: (id) =>
                              CattleFinancesPage(familyId: id),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Gráficas ───────────────────────────────────
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Litros por mes',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          Text(
                            '${_provider.records.length} registros',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MilkMonthlyChart(records: _provider.records),

                      const SizedBox(height: 24),

                      const Text('Litros esta semana',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      MilkWeeklyChart(records: _provider.records),
                    ],
                  ),
                ),
    );
  }
}