import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:milk_app/providers/cattle_calendar_provider.dart';
import 'package:milk_app/widgets/calendar/calendar_day_cell.dart';
import 'package:milk_app/widgets/calendar/calendar_header.dart';
import 'package:milk_app/widgets/calendar/calendar_legend.dart';
import 'package:milk_app/widgets/calendar/cattle_bottom_sheet.dart';

class CattleFeedCalendar extends StatefulWidget {
  final String familyId;
  const CattleFeedCalendar({super.key, required this.familyId});

  @override
  State<CattleFeedCalendar> createState() => _CattleFeedCalendarState();
}

class _CattleFeedCalendarState extends State<CattleFeedCalendar> {
  late final CattleCalendarProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CattleCalendarProvider(familyId: widget.familyId);
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _onDayTapped(DateTime date) async {
    final record = _provider.recordForDate(date);
    if (record != null) {
      await _showEditSheet(record);
    } else {
      await _showAddSheet(date);
    }
    _provider.clearSelection();
  }

  Future<void> _showAddSheet(DateTime date) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      builder: (_) => CattleBottomSheet(
        title: 'Nuevo Registro',
        subtitle: '${date.day}/${date.month}/${date.year}',
        isNew: true,
        onSave: (name, price) =>
            _provider.addRecord(date: date, name: name, price: price),
      ),
    );
  }

  Future<void> _showEditSheet(dynamic record) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      builder: (_) => CattleBottomSheet(
        title: 'Editar Registro',
        subtitle:
            '${record.cattleDate.day}/${record.cattleDate.month}/${record.cattleDate.year}',
        isNew: false,
        initialName: record.cattleName,
        initialPrice: record.cattlePrice,
        onSave: (name, price) =>
            _provider.updateRecord(original: record, name: name, price: price),
        onDelete: () => _provider.deleteRecord(record.cattleId),
      ),
    );
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
          title: const Text('Alimento de Ganado'),
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
        title: const Text('Alimento de Ganado',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        centerTitle: true,
        backgroundColor: const Color(0xFF3D52A0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          CalendarHeader(
            chips: [
              CalendarStatChip(
                  icon: Icons.grass_rounded,
                  label: 'Hoy',
                  value: _provider.precioHoyLabel),
              CalendarStatChip(
                  icon: Icons.calendar_month_rounded,
                  label: 'Registros',
                  value: '${_provider.totalRegistros}'),
            ],
            summaryText:
                'Total: \$${_provider.totalMes.toStringAsFixed(1)}   •   Promedio: \$${_provider.promedioMes.toStringAsFixed(1)}',
          ),
          const SizedBox(height: 12),
          const CalendarLegend(),
          const SizedBox(height: 8),
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              elevation: 2,
              shadowColor: Colors.indigo.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: CalendarDatePicker2(
                config: CalendarDatePicker2Config(
                  calendarType: CalendarDatePicker2Type.single,
                  selectedDayHighlightColor: const Color(0xFF7091E6),
                  dayBuilder: ({
                    required DateTime date,
                    BoxDecoration? decoration,
                    bool? isDisabled,
                    bool? isSelected,
                    bool? isToday,
                    TextStyle? textStyle,
                  }) {
                    final record = _provider.recordForDate(date);
                    return CalendarDayCell(
                      date: date,
                      // ── FIX mismo que milk ──
                      isSelected: (isSelected ?? false) && !(isToday ?? false),
                      isToday: isToday ?? false,
                      hasRecord: record != null,
                      recordLabel: record != null
                          ? '\$${record.cattlePrice.toStringAsFixed(0)}'
                          : null,
                    );
                  },
                ),
                value: _provider.selectedDate,
                onValueChanged: (dates) {
                  if (dates.isEmpty || dates.first == null) return;
                  _provider.setSelectedDate(dates);
                  _onDayTapped(dates.first!);
                },
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}