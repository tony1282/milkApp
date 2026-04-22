import 'package:flutter/material.dart';

class FinancesLegend extends StatelessWidget {
  const FinancesLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: const [
          _LegendDot(color: Color(0xFF7091E6), label: 'Rango seleccionado'),
          _LegendDot(color: Color(0xFFB8F0C8), label: 'Periodo cobrado'),
          _LegendDot(color: Color(0xFFEEF2FF), label: 'Tiene registro'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}