import 'package:flutter/material.dart';

class MiniBarChart extends StatelessWidget {
  final Map<String, double> data;

  const MiniBarChart({super.key, required this.data});

  static const _monthLabels = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  @override
  Widget build(BuildContext context) {
    final maxVal = data.values.fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Últimos 6 meses',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.entries.map((e) {
                final ratio = maxVal > 0 ? e.value / maxVal : 0.0;
                final monthNum =
                    int.tryParse(e.key.split('-')[1]) ?? 1;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (e.value > 0)
                      Text(
                        '\$${e.value.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3D52A0),
                        ),
                      ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 32,
                      height: (ratio * 70).clamp(2.0, 70.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7091E6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _monthLabels[monthNum - 1],
                      style: const TextStyle(
                          fontSize: 10, color: Colors.black45),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}