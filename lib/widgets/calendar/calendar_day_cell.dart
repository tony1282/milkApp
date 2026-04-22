import 'package:flutter/material.dart';

class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool hasRecord;
  final String? recordLabel; // "12L" o "$50"

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.hasRecord,
    this.recordLabel,
  });

  @override
  Widget build(BuildContext context) {
    // ── FIX: lógica de colores clara y sin ambigüedad ─────────────────────
    // Prioridad: seleccionado > hoy > tiene registro > vacío
    Color? bgColor;
    List<BoxShadow>? shadows;

    if (isSelected) {
      bgColor = const Color(0xFF7091E6);
    } else if (isToday) {
      // Hoy nunca se pinta de azul sólido — solo tiene un ring
      bgColor = const Color(0xFFEEF2FF);
      shadows = [
        const BoxShadow(
          color: Color(0xFF3D52A0),
          spreadRadius: 1.5,
          blurRadius: 0,
        ),
      ];
    } else if (hasRecord) {
      bgColor = const Color(0xFFEEF2FF);
    }

    // ── Color del número del día ──────────────────────────────────────────
    Color dayNumberColor;
    if (isSelected) {
      dayNumberColor = Colors.white;
    } else if (isToday) {
      dayNumberColor = const Color(0xFF3D52A0); // azul pero NO sobre fondo azul
    } else {
      dayNumberColor = Colors.black87;
    }

    // ── Color del label del registro ──────────────────────────────────────
    Color labelColor;
    if (isSelected) {
      labelColor = Colors.white70;
    } else {
      labelColor = const Color(0xFF3D52A0);
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: shadows,
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
              color: dayNumberColor,
            ),
          ),
          if (hasRecord && recordLabel != null)
            Text(
              recordLabel!,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
        ],
      ),
    );
  }
}