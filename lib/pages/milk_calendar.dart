import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:milk_app/providers/milk_calendar_provider.dart';
import 'package:milk_app/widgets/calendar/calendar_day_cell.dart';
import 'package:milk_app/widgets/calendar/calendar_legend.dart';
import 'package:milk_app/widgets/calendar/milk_bottom_sheet.dart';
import 'package:milk_app/widgets/calendar/calendar_header.dart';

class MilkCalendar extends StatefulWidget {
  final String familyId;
  const MilkCalendar({super.key, required this.familyId});

  @override
  State<MilkCalendar> createState() => _MilkCalendarState();
}

class _MilkCalendarState extends State<MilkCalendar> {
  late final MilkCalendarProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = MilkCalendarProvider(familyId: widget.familyId);
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
      await _showEditSheet(record.milkDate, record);
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
      builder: (_) => MilkBottomSheet(
        title: 'Nuevo Registro',
        subtitle: '${date.day}/${date.month}/${date.year}',
        isNew: true,
        onSave: (liters) => _provider.addRecord(date: date, liters: liters),
      ),
    );
  }

  Future<void> _showEditSheet(DateTime date, dynamic record) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      builder: (_) => MilkBottomSheet(
        title: 'Editar Registro',
        subtitle: '${date.day}/${date.month}/${date.year}',
        isNew: false,
        initialValue: record.milkLiters,
        onSave: (liters) =>
            _provider.updateRecord(original: record, liters: liters),
        onDelete: () => _provider.deleteRecord(record.milkId),
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
          title: const Text('Registro de Leche'),
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
        title: const Text('Registro de Leche',
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
              _chip(Icons.water_drop_rounded, 'Hoy', _provider.litrosHoyLabel),
              _chip(Icons.calendar_month_rounded, 'Registros',
                  '${_provider.totalRegistros}'),
            ],
            summaryText:
                'Total: ${_provider.totalMes.toStringAsFixed(1)} L   •   Promedio: ${_provider.promedioMes.toStringAsFixed(1)} L',
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
                      // ── FIX: nunca marcar hoy como seleccionado visualmente ──
                      isSelected: (isSelected ?? false) && !(isToday ?? false),
                      isToday: isToday ?? false,
                      hasRecord: record != null,
                      recordLabel: record != null
                          ? '${record.milkLiters}L'
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

  // Helper local para construir _ChipData sin exponer la clase privada
  dynamic _chip(IconData icon, String label, String value) =>
      CalendarStatChip(icon: icon, label: label, value: value);
}