import 'package:flutter/material.dart';

class QuickAccessGrid extends StatelessWidget {
  final VoidCallback onMilkTap;
  final VoidCallback onFeedTap;
  final VoidCallback onFinancesMilkTap;
  final VoidCallback onFinancesFeedTap;

  const QuickAccessGrid({
    super.key,
    required this.onMilkTap,
    required this.onFeedTap,
    required this.onFinancesMilkTap,
    required this.onFinancesFeedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.water_drop_rounded,
            label: 'Registrar\nLeche',
            color: const Color(0xFF3D52A0),
            onTap: onMilkTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.grass_rounded,
            label: 'Registrar\nAlimento',
            color: const Color(0xFF4CAF82),
            onTap: onFeedTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.payments_rounded,
            label: 'Finanzas\nLeche',
            color: const Color(0xFFE67E45),
            onTap: onFinancesMilkTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.bar_chart_rounded,
            label: 'Gastos\nAlimento',
            color: const Color(0xFF7091E6),
            onTap: onFinancesFeedTap,
          ),
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}