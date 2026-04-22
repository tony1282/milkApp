import 'package:flutter/material.dart';

class CattleEmptyMonth extends StatelessWidget {
  const CattleEmptyMonth({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grass_rounded, size: 48, color: Colors.black12),
            SizedBox(height: 10),
            Text(
              'Sin registros este mes',
              style: TextStyle(color: Colors.black45, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}