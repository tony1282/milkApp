import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:milk_app/providers/finances_provider.dart';
import 'package:milk_app/widgets/finances/create_payment_sheet.dart';
import 'package:milk_app/widgets/finances/finances_header.dart';
import 'package:milk_app/widgets/finances/finances_legend.dart';
import 'package:milk_app/widgets/finances/payment_card.dart';

class FinancesPage extends StatefulWidget {
  final String familyId;
  const FinancesPage({super.key, required this.familyId});

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  late final FinancesProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = FinancesProvider(familyId: widget.familyId);
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _onRangeSelected(List<DateTime?> dates) {
    _provider.setSelectedRange(dates);
    if (dates.length == 2 && dates[0] != null && dates[1] != null) {
      _showCreatePaymentSheet(dates[0]!, dates[1]!);
    }
  }

  void _showCreatePaymentSheet(DateTime from, DateTime to) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      builder: (_) => CreatePaymentSheet(
        from: from,
        to: to,
        liters: _provider.litersInRange,
        onSave: (price) => _provider.addPayment(
          from: from,
          to: to,
          pricePerLiter: price,
        ),
      ),
    );
    // Limpia rango al cerrar (guardó o canceló)
    _provider.clearSelectedRange();
  }

  @override
  Widget build(BuildContext context) {
    if (_provider.loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_provider.error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        appBar: AppBar(
          title: const Text('Finanzas de Leche'),
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
          'Finanzas de Leche',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3D52A0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Header ──
          FinancesHeader(
            totalCobrado: _provider.totalCobradoMes,
            totalCortes: _provider.payments.length,
          ),

          const SizedBox(height: 12),

          // ── Leyenda ──
          const FinancesLegend(),

          const SizedBox(height: 6),

          // ── Calendario ──
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              elevation: 2,
              shadowColor: Colors.indigo.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: CalendarDatePicker2(
                config: CalendarDatePicker2Config(
                  calendarType: CalendarDatePicker2Type.range,
                  selectedDayHighlightColor: const Color(0xFF7091E6),
                  dayBuilder: ({
                    required DateTime date,
                    BoxDecoration? decoration,
                    bool? isDisabled,
                    bool? isSelected,
                    bool? isToday,
                    TextStyle? textStyle,
                  }) {
                    final key = _provider.dateKey(date);
                    final hasRecord = _provider.milkByDate.containsKey(key);
                    final isPaid = _provider.dateInAnyPayment(date);

                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: isSelected == true
                            ? const Color(0xFF7091E6)
                            : isPaid
                                ? const Color(0xFFB8F0C8)
                                : hasRecord
                                    ? const Color(0xFFEEF2FF)
                                    : null,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isToday == true
                            ? [
                                const BoxShadow(
                                  color: Color(0xFF3D52A0),
                                  spreadRadius: 1.5,
                                  blurRadius: 0,
                                )
                              ]
                            : null,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected == true
                                  ? Colors.white
                                  : isToday == true
                                      ? const Color(0xFF3D52A0)
                                      : Colors.black87,
                            ),
                          ),
                          if (hasRecord && !isPaid)
                            Text(
                              '${_provider.milkByDate[key]!.milkLiters.toStringAsFixed(0)}L',
                              style: TextStyle(
                                fontSize: 5,
                                fontWeight: FontWeight.w700,
                                color: isSelected == true
                                    ? Colors.white70
                                    : const Color(0xFF3D52A0),
                              ),
                            ),
                          if (isPaid)
                            const Text(
                              '✓',
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                value: _provider.selectedRange,
                onValueChanged: _onRangeSelected,
              ),
            ),
          ),

          // ── Cortes registrados ──
          if (_provider.payments.isNotEmpty)
            Container(
              height: 155,
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Cortes registrados',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _provider.payments.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final p = _provider.payments[index];
                        return PaymentCard(
                          payment: p,
                          onDelete: () async {
                            try {
                              await _provider.deletePayment(p.paymentId);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Error al eliminar: $e')),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Safe area inferior
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}