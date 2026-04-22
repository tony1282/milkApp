import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:milk_app/models/milk_record_model.dart';

// ─── Gráfica mensual ───────────────────────────────────────────────────────
class MilkMonthlyChart extends StatelessWidget {
  final List<MilkRecordModel> records;
  const MilkMonthlyChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    // Agrupa por mes (últimos 6 meses)
    final now = DateTime.now();
    final Map<int, double> monthlyData = {};
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final key = m.month;
      monthlyData[key] = 0;
    }
    for (final r in records) {
      final diff = (now.year - r.milkDate.year) * 12 + (now.month - r.milkDate.month);
      if (diff >= 0 && diff < 6) {
        monthlyData[r.milkDate.month] = (monthlyData[r.milkDate.month] ?? 0) + r.milkLiters;
      }
    }

    final months = <int>[];
    for (int i = 5; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i, 1).month);
    }

    final bars = months.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: monthlyData[e.value] ?? 0,
            color: const Color(0xFF7091E6),
            width: 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          )
        ],
      );
    }).toList();

    final monthNames = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: BarChart(
        BarChartData(
          barGroups: bars,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text('${v.toInt()}L', style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= months.length) return const SizedBox();
                  return Text(monthNames[months[idx] - 1], style: const TextStyle(fontSize: 10, color: Colors.black54));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)} L',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Gráfica semanal ───────────────────────────────────────────────────────
class MilkWeeklyChart extends StatelessWidget {
  final List<MilkRecordModel> records;
  const MilkWeeklyChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Inicio de la semana actual (lunes)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    final Map<int, double> weekData = {for (int i = 0; i < 7; i++) i: 0};
    for (final r in records) {
      final diff = r.milkDate.difference(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)).inDays;
      if (diff >= 0 && diff < 7) {
        weekData[diff] = (weekData[diff] ?? 0) + r.milkLiters;
      }
    }

    final spots = List.generate(7, (i) => FlSpot(i.toDouble(), weekData[i] ?? 0));

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF3D52A0),
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 4,
                  color: spot.y > 0 ? const Color(0xFF3D52A0) : Colors.transparent,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF7091E6).withOpacity(0.15),
              ),
            ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i > 6) return const SizedBox();
                  return Text(dayNames[i], style: const TextStyle(fontSize: 10, color: Colors.black54));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text('${v.toInt()}L', style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                '${s.y.toStringAsFixed(1)} L',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }
}