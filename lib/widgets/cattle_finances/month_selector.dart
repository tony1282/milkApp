import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;
  final bool isCurrentMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const _monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.isCurrentMonth,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ArrowButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
          Text(
            '${_monthNames[selectedMonth - 1]} $selectedYear',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700),
          ),
          _ArrowButton(
            icon: Icons.chevron_right_rounded,
            onTap: isCurrentMonth ? null : onNext,
            disabled: isCurrentMonth,
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  const _ArrowButton({
    required this.icon,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: disabled ? Colors.grey[300] : null,
      ),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}