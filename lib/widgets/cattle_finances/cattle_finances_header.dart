import 'package:flutter/material.dart';
import 'package:milk_app/models/cattle_feed_model.dart';

class CattleFinancesHeader extends StatelessWidget {
  final double totalMes;
  final double promedioMes;
  final int totalRegistros;
  final CattleFeedModel? masCaroMes;

  const CattleFinancesHeader({
    super.key,
    required this.totalMes,
    required this.promedioMes,
    required this.totalRegistros,
    required this.masCaroMes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF3D52A0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip(
                icon: Icons.grass_rounded,
                label: 'Total mes',
                value: '\$${totalMes.toStringAsFixed(0)}',
              ),
              _StatChip(
                icon: Icons.bar_chart_rounded,
                label: 'Promedio',
                value: '\$${promedioMes.toStringAsFixed(0)}',
              ),
              _StatChip(
                icon: Icons.receipt_long_rounded,
                label: 'Registros',
                value: '$totalRegistros',
              ),
            ],
          ),
          if (masCaroMes != null) ...[
            const SizedBox(height: 10),
            Text(
              'Mayor gasto: ${masCaroMes!.cattleName} — \$${masCaroMes!.cattlePrice.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}