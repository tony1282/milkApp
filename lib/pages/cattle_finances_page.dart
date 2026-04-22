import 'package:flutter/material.dart';
import 'package:milk_app/providers/cattle_finances_provider.dart';
import 'package:milk_app/widgets/cattle_finances/alimento_row.dart';
import 'package:milk_app/widgets/cattle_finances/cattle_empty_month.dart';
import 'package:milk_app/widgets/cattle_finances/cattle_finances_header.dart';
import 'package:milk_app/widgets/cattle_finances/cattle_record_tile.dart';
import 'package:milk_app/widgets/cattle_finances/mini_bar_chart.dart';
import 'package:milk_app/widgets/cattle_finances/month_selector.dart';

class CattleFinancesPage extends StatefulWidget {
  final String familyId;
  const CattleFinancesPage({super.key, required this.familyId});

  @override
  State<CattleFinancesPage> createState() => _CattleFinancesPageState();
}

class _CattleFinancesPageState extends State<CattleFinancesPage> {
  late final CattleFinancesProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CattleFinancesProvider(familyId: widget.familyId);
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Loading ──
    if (_provider.loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ── Error ──
    if (_provider.error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        appBar: AppBar(
          title: const Text('Gastos de Alimento'),
          backgroundColor: const Color(0xFF3D52A0),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(_provider.error!,
                  style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text(
          'Gastos de Alimento',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3D52A0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header con stats ──
            CattleFinancesHeader(
              totalMes: _provider.totalMes,
              promedioMes: _provider.promedioMes,
              totalRegistros: _provider.recordsDelMes.length,
              masCaroMes: _provider.masCaroMes,
            ),

            const SizedBox(height: 16),

            // ── Selector de mes ──
            MonthSelector(
              selectedMonth: _provider.selectedMonth,
              selectedYear: _provider.selectedYear,
              isCurrentMonth: _provider.isCurrentMonth,
              onPrev: _provider.prevMonth,
              onNext: _provider.nextMonth,
            ),

            const SizedBox(height: 16),

            // ── Gráfica últimos 6 meses ──
            MiniBarChart(data: _provider.ultimos6Meses),

            const SizedBox(height: 20),

            // ── Desglose por alimento ──
            if (_provider.porAlimento.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Desglose por alimento',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 10),
              ..._provider.porAlimento.entries.map(
                (e) => AlimentoRow(
                  nombre: e.key,
                  total: e.value,
                  porcentaje:
                      _provider.totalMes > 0 ? e.value / _provider.totalMes : 0,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Registros del mes ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Registros del mes',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),

            if (_provider.recordsDelMes.isEmpty)
              const CattleEmptyMonth()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _provider.recordsDelMes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) => CattleRecordTile(
                  record: _provider.recordsDelMes[index],
                ),
              ),
          ],
        ),
      ),
    );
  }
}